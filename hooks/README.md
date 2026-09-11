# Hooks（harness 层强制）

文本约束是软约束，PreToolUse / PostToolUse hook 是硬约束：零上下文成本，去留只看误报率
（GUIDE §1 原则 4）。部署由 project-bootstrap Step 3 执行；本目录是源码与用例的唯一权威。

## 原则

| 原则 | 说明 |
|---|---|
| 只堵错路，不堵正路 | hook 阻断 / 提醒错误行为；正确路径由文本引导 |
| 通用 | 脚本不含项目特定逻辑；heavy-test 模板的三个占位符是唯一例外 |
| 不造成死锁 | 硬 block 仅限「该项目里永远不合法」的行为；有合法例外的用软提醒 |
| 分层 | Tier 1 硬 block = exit 2 + stderr；Tier 2 软提醒 = exit 0 + JSON additionalContext，或 exit 2 + stderr |

**写法法则**（2026-09-08 / 09-11 实测 Claude Code 2.1.259 + Windows PowerShell 5.1，缘由见
project-bootstrap Step 3）：工具事件下模型看得见的只有 JSON `hookSpecificOutput.additionalContext`
或 exit 2 + stderr，`exit 0 + 纯文本 stdout` 只进 debug 日志；脚本只含 ASCII（检查用 python 读
字节，别用 `grep -P`）；stdin **和 stdout / stderr 都**显式设 UTF-8——只设 InputEncoding 时，
输出里引用的输入原文（如被拦的命令）按 cp936 编码，会话里显示为乱码；坏 JSON 显式 exit 1。
本目录脚本已全部按此写成。

## 清单

| 脚本 | 事件 / matcher | Tier | 行为 |
|---|---|---|---|
| `block-replaced-skills.ps1` | PreToolUse / `Skill` | 1 | 阻断 writing-plans / executing-plans（change-loop 路由与内环替代；OpenSpec 项目对应 propose / apply）|
| `block-superpowers-specs-dir.ps1` | PreToolUse / `Write` | 1 | 阻断写入 `docs/superpowers/specs/`（spec 位置由 change-loop 决定：openspec/changes/ 或根 SPEC.md） |
| `block-unsafe-test-commands-TEMPLATE.ps1` | PreToolUse / `Bash\|PowerShell` | 1 | 阻断裸跑测试命令（无 filter、无 escape var）；填空后去掉 `-TEMPLATE` |
| `warn-destructive-git.ps1` | PreToolUse / `Bash\|PowerShell` | 2 | `reset --hard` / `push -f` / `checkout .` / `restore .` / `clean -f` / `branch -D` 提醒 |
| `warn-route-before-opsx.ps1` | PreToolUse / `Skill` | 2 | `opsx:propose\|new\|ff` 前提醒先做 change-loop 路由声明 |
| `warn-backlog-size.ps1` | PostToolUse / `Write\|Edit\|Bash\|PowerShell` | 2 | backlog.md > 8KB → exit 2 提醒搬内容 |

`warn-apply-phase`（v3）已在 v5 切除（FIELD-LOG 2026-08-14 ablation 台账）。

## 注册（`.claude/settings.json`，MERGE 不覆盖）

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Skill", "hooks": [
        { "type": "command", "command": "powershell -NoProfile -File .claude/scripts/block-replaced-skills.ps1" },
        { "type": "command", "command": "powershell -NoProfile -File .claude/scripts/warn-route-before-opsx.ps1" } ] },
      { "matcher": "Write", "hooks": [
        { "type": "command", "command": "powershell -NoProfile -File .claude/scripts/block-superpowers-specs-dir.ps1" } ] },
      { "matcher": "Bash|PowerShell", "hooks": [
        { "type": "command", "command": "powershell -NoProfile -File .claude/scripts/warn-destructive-git.ps1" },
        { "type": "command", "command": "powershell -NoProfile -File .claude/scripts/block-unsafe-test-commands.ps1" } ] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit|Bash|PowerShell", "hooks": [
        { "type": "command", "command": "powershell -NoProfile -File .claude/scripts/warn-backlog-size.ps1" } ] }
    ]
  }
}
```

命令类 matcher 必须写 `Bash|PowerShell`（2026-08-09 zd-tool 实测：Windows 会话主 shell 是
PowerShell，只写 `Bash` 根本不触发，hook 静默失效）。

## Heavy-test（block-unsafe-test-commands）

问题模式：测试套件含重型测试（GB 级数据 / 容器 / e2e 浏览器），AI 默认裸跑全套，runner
默认并发 → 机器冻结（2026-06-01 实证：一个 subagent 在自审里裸跑 `dotnet test`，RAM 90%+）。
跨栈普遍：`dotnet test` / `pytest` / `npm test` / `go test ./...` / `cargo test`。

**Day-1 三问**（bootstrap Step 3 问；答案可日后回补）：

1. 有没有重型测试（单测 RAM > 200MB / 起外部依赖 / e2e）？没有 → 跳过本节。
2. 测试代码能改吗？能 → 优先测试框架 marker / trait / build tag（结构性，默认就不跑）；
   老测试不能改 → runner 配置默认排除；完全不能改 → 只靠 hook。
3. 会派 subagent 跑测试吗？会 → **必须叠加 hook**（subagent 的文本约束被实证不可靠）。

本工作流 apply 阶段大量派 subagent，绝大多数项目最终都需要 hook（可叠加 marker 做深度防御）。

**填空**：`<TEST_CMD_REGEX>`（非捕获组）、`<SAFE_FILTER_REGEX>`（只对 runner 名之后的尾串匹配，
原因见脚本头注「runner-name split」）、`<ESCAPE_VAR>`（项目特异名）。三个 token 在头注、代码、
提示语里各出现多次，全部替换；填完 `grep -E '<[A-Z_]+>'` 必须为空。填充示例：

| 栈 | TEST_CMD_REGEX | SAFE_FILTER_REGEX | ESCAPE_VAR |
|---|---|---|---|
| .NET | `\bdotnet\s+test\b` | `--filter\b` | `STUTTER_ALLOW_FULL_TEST` |
| Python（zd-tool，2026-08-09 实测 17/17） | `\bpytest\b` | `(^\|\s)-(k\|m)(\s\|=)` | `ZDTOOL_ALLOW_FULL_TEST` |

测试命令纪律同时写进项目 CLAUDE.md Stack & Conventions 与 `openspec/config.yaml` context
（filter flag、escape var、subagent 不许设 escape var）；dispatch-prompt.md Constraints 槽逐字重述。

## Echo 用例（没跑过的 hook 不算部署）

在 PowerShell 里执行；走真实 stdin 并模拟默认代码页；`in.json` 为无 BOM UTF-8 且含中文：

```powershell
$cp = (cmd /c chcp) -replace '\D', ''                      # 先记原始代码页——在本会话任何 chcp 之前
try {
  cmd /c "chcp 936 >nul & powershell -NoProfile -File .claude/scripts/<hook>.ps1 < in.json 2>&1"
  "exit=$LASTEXITCODE"                                     # 2>&1 写在 cmd 字符串内：stderr 与 exit 一次拿到
} finally { cmd /c "chcp $cp >nul" }                       # 恢复；中途出错也恢复
```

两个坑（2026-09-11 sports 部署 + toolkit 会话各实测一次）：单行 `cmd /c "... & echo exit=%errorlevel%"`
里 `%errorlevel%` 在执行前就展开，**永远打印 0**，会把失效的 Tier 1 判成通过——必须读
`$LASTEXITCODE`（或 `cmd /v:on /c "... & echo exit=!errorlevel!"`）；子进程 `chcp` 改的是共享
控制台的代码页，本会话之后的输出全部乱码。记代码页必须在**任何** chcp 之前——泄漏之后再读，
读到的就是泄漏值，「恢复」等于没恢复。已经乱了不用重启：Claude Code 终端默认 65001，
`cmd /c "chcp 65001 >nul"` 即刻恢复。

| hook | 输入 | 期望 |
|---|---|---|
| block-replaced-skills | `{"tool_input":{"skill":"superpowers:writing-plans"}}` | stderr BLOCKED，exit 2 |
| | `{"tool_input":{"skill":"change-loop"}}` | 静默，exit 0 |
| block-superpowers-specs-dir | `{"tool_input":{"file_path":"E:\\p\\docs\\superpowers\\specs\\x.md"}}` | stderr BLOCKED，exit 2 |
| | `{"tool_input":{"file_path":"E:\\p\\openspec\\changes\\x\\design.md"}}` | 静默，exit 0 |
| warn-destructive-git | `{"tool_input":{"command":"git reset --hard HEAD~1"}}` | 一行 JSON additionalContext，exit 0 |
| | `{"tool_input":{"command":"git status"}}` | 静默，exit 0 |
| warn-route-before-opsx | `{"tool_input":{"skill":"opsx:propose"}}` | 一行 JSON，exit 0 |
| | `{"tool_input":{"skill":"change-loop"}}` | 静默，exit 0 |
| warn-backlog-size | 超 8KB 的 backlog.md（路径与内容含中文） | stderr，exit 2 |
| | 小 backlog.md / 其他文件 | 静默，exit 0 |
| | Bash 命令提到 backlog.md 且 cwd 下的超标 | exit 2 |
| block-unsafe-test-commands | 裸 `<TEST_CMD>` | exit 2 |
| | `<TEST_CMD> <SAFE_FILTER_EXAMPLE>` | exit 0 |
| | `<ESCAPE_VAR>=1 <TEST_CMD>` 与 `$env:<ESCAPE_VAR>=1; <TEST_CMD>` | exit 0 |
| | 非测试命令 | exit 0 |
| | **日常真正敲的完整形式**（如 `python -m pytest`） | exit 2；得 0 = SAFE_FILTER 匹配到了 runner 之前的参数，hook 已失效 |
| 所有 hook | 坏 JSON | stderr，exit 1 |

hook 挂载后在会话里真跑一次被拦的命令确认 matcher 生效：echo 只证明脚本对，不证明挂对了 tool。
settings.json 的改动当场生效，不用重启（zd-tool 实测：PostToolUse 挂上后下一次调用就响），
所以这一步可以立刻做。warn-backlog-size 的真跑：备份 backlog.md 到 scratchpad → 用 Write 追加
9KB 中文 → 应出现 PostToolUse 提醒 → 从备份恢复并 cmp 一致。

**已知误报**（命令文本里的字面量也命中）：warn-destructive-git 对写 fixture / 生成文档里的
`git reset --hard` 字样响，Tier 2 无害，不改；**block-unsafe-test-commands 是 Tier 1，同形误报会
真的挡住一次操作**——zd-tool 实测 commit message 里写了「bare pytest」，`\bpytest\b` 命中，
`git commit` 被硬拦。绕法：消息写文件后 `git commit -F <file>`，或换措辞。提示语里已写明。

## 不做 hook 的约束

TDD 先测后码（无法判定一次 Write 是实现还是接口 / 配置）、评审必须 subagent（hook 分不清
主 session 与 subagent）、commit message 格式（因项目而异）、外部 API 查证、checkpoint 时机：
都留在文本层。

## 扩展

新脚本放本目录（ASCII、stdin UTF-8、坏 JSON exit 1），本 README 的清单与用例表各加一行，
bootstrap Step 3 部署清单加一项；改完先跑 echo 用例再提交。
