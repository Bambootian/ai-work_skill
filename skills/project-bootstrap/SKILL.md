---
name: project-bootstrap
description: Use when starting a new project with this workflow (立项 / 新项目 / kick off a project), deploying or updating the toolkit's skills and hooks on a machine or in a project (部署工作流), migrating a v3/v4/v5.0 project (including slimming an oversized backlog.md and re-deploying Tier 2 hooks), or when Session Start finds the project CLAUDE.md missing its North Star section or backlog.md missing / lacking Now and 主线 sections.
---

# Project Bootstrap

AI 执行、人确认：人只回答 brainstorm 问题、逐行确认回填文档。**顺序承重：先 brainstorm，
文档从其结果回填**——先填模板必然是空的或编的。各步幂等，可单独重跑（如 heavy-test
hook 的日后回补）。

## Step 0 — 装机（机器级）

1. toolkit 路径：读 `~/.claude/my-work-skill.toolkit-path`；没有 → 问人 clone 在哪
   （或现场 clone），把路径写入该文件——之后所有引用（附录 G、§5.8、本 skill 更新）
   由它解析。
2. clone 干净则 `git -C <toolkit> pull`；复制 `skills/*` → `~/.claude/skills/`（覆盖——
   部署的是副本，不会自更新；项目级 `.claude/skills/` 有副本的项目同样覆盖）；**同时删除
   工具包已移除的 skill 目录（如 toolchain-refresh）**——覆盖复制不清理死副本，死 skill
   的触发词仍会命中。
3. 前置：superpowers 插件在（brainstorming / systematic-debugging 是循环依赖）；
   中型项目 `npx openspec --version` 可用。缺 → WORKFLOW.md 第 1 部分。

机器已是最新（路径文件在、skills 一致、无死目录）→ 一行说明，继续。

## Step 1 — 立项 brainstorm

**REQUIRED SUB-SKILL: superpowers:brainstorming。** 宣布并调用，不自由采访。已有文档/
代码先读，不问它们已回答的。必须产出（= Step 2 的槽位）：

- North Star 段四要素：谁通过这个项目得到什么（一句话）+ 可观察成功判据 + anti-scope +
  当前阶段重点
- **主线路径**：格式见 `templates/backlog.md` 主线段——从零到成功判据的有序步骤，每步标
  解锁哪条判据；外部事件（专家回信、新版本样本）也是步骤，带到期日或 kill 线
- 规模：小型（R0/R1 为主，无 OpenSpec）vs 中型（OpenSpec）
- Stack、build/test 命令、test filter flags、运行须知
- heavy tests？（单测 >200MB 内存 / 外部依赖 / e2e）→ 喂 Step 3

## Step 2 — 回填（AI 起草 → 人逐行确认 → commit）

1. `CLAUDE.md` 从 toolkit 的 `templates/CLAUDE.md` 起草，North Star 段填 brainstorm 结果。
2. `backlog.md` 从 `templates/backlog.md` 起草（所有规模）：主线段填 brainstorm 的路径，
   Now 段指向第 1 步。
3. 中型：`npx @fission-ai/openspec@latest init` → ARCHITECTURE.md（结构：WORKFLOW.md 第 3 部分）。

无 `<placeholder>` 存活——填不出 = Step 1 没做完，回去。

**存量项目迁移**（幂等；AI 起草 → 人确认后落盘）：

- v3/v4：NORTH_STAR.md 只保留终态 + 判据 + anti-scope 并入 CLAUDE.md North Star 段后删除
  该文件（Review Log 与历史注记进 git）；`openspec/` 与既有 hooks 保留；移除 `$PROFILE` 中的
  `function claude` wrapper；删 PROTOCOL.md 与项目内 WORKFLOW.md 副本；注销 warn-apply-phase、
  warn-toolchain-stale 两个 hook，删 `.claude/last-toolchain-refresh`。
- v5.0 → v5.1 **backlog 瘦身**（超 8KB 即做），按此顺序：① 每个历史段先按 GUIDE §6 归属表
  把读数 / 裁定 / 教训 / 协议抄本各抽成一条，搬到 `docs/notes/<date>-<slug>.md`、
  `docs/decisions.md` 或对应 change 归档（backlog 留一句 + 路径）；② 剩余的交接叙事删
  （git 有）；③ 最新交接压成 Now 四字段；④ watch 压成支线一行，长尾进 `docs/watchlist.md`；
  done 条目压成 Done 段一行；⑤ 无主线段 → 从 North Star + 现有 roadmap 写出。人确认的
  对象 = 新 backlog 全文 + 新建文件清单（路径 + 一句），不逐行。搬，不删信息。
- 项目 CLAUDE.md 对照 `templates/CLAUDE.md` 补齐差异，并 grep 删除与 v5.1 冲突的旧规则：
  subagent「用户确认后再开」类条款、archive 计数触发、四行路由声明、toolchain-refresh 引用。
- 重跑 Step 3 的 Tier 2 hooks（旧写法模型看不见，见下）。

## Step 3 — Hooks（此时 stack 已知）

源码：toolkit 的 WORKFLOW.md 附录 G（本节两个例外内联）。部署到 `.claude/scripts/` +
注册进 `.claude/settings.json`。**MERGE 不覆盖**——别的工具也在里面注册 hooks：先读、
再加、再验 JSON。

**两条写法法则**（2026-09-08 实测 Claude Code 2.1.259 + Windows PowerShell 5.1）：

- 可见性：PreToolUse / PostToolUse 等工具事件下，模型看得见的是 JSON
  `hookSpecificOutput.additionalContext`（exit 0）或 exit 2 + stderr；`exit 0 + 纯文本 stdout`
  只进 debug 日志——附录 G 的 Tier 2 写法模型看不见，部署时按下面改。例外：SessionStart /
  UserPromptSubmit 的纯文本 stdout 会进上下文，照旧。
- 编码：脚本只含 ASCII（无 BOM UTF-8 里的中文可能被按 GBK 解码吞掉后续字节，静默失效或
  解析错误）；读 stdin 前显式设 UTF-8——Claude Code 送的是 UTF-8，PowerShell 5.1 默认按
  控制台代码页（936）解，真实中文载荷会让 JSON 解析失败、hook 静默退出。

部署清单（6 个）：

- `block-unsafe-test-commands`（heavy-test）：走附录 G 的 Day-1 三问填三个空位；
  「暂无重测试」是合法答案，出现时重跑本步。
- `block-replaced-skills`、`block-superpowers-specs-dir`：照附录 G（Tier 1，exit 2 本就可见）。
- `warn-destructive-git`：附录 G 源码，输出行改为 JSON additionalContext（同下例写法）。
- `warn-route-before-opsx`（PreToolUse，matcher Skill；命令名单先核对已装 OpenSpec 版本）：

```powershell
# warn-route-before-opsx.ps1 - Tier 2 (PreToolUse, matcher: Skill)
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
try { $json = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
catch { [Console]::Error.WriteLine('warn-route-before-opsx: bad stdin JSON'); exit 1 }
if ($json.tool_input.skill -cmatch '^opsx:(propose|new|ff)$') {
  $msg = "This project requires a change-loop route declaration (Route / mainline / Next lines) before $($json.tool_input.skill). If none was posted this session, stop and invoke change-loop first."
  @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; additionalContext = $msg } } | ConvertTo-Json -Compress
}
exit 0
```

- `warn-backlog-size`（PostToolUse，matcher `Write|Edit|Bash|PowerShell`，注册在 `"PostToolUse"`
  段；Bash/PowerShell 命令提到 backlog.md 时检查 cwd 下的 backlog.md）：

```powershell
# warn-backlog-size.ps1 - Tier 2 (PostToolUse, matcher: Write|Edit|Bash|PowerShell)
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
try { $json = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
catch { [Console]::Error.WriteLine('warn-backlog-size: bad stdin JSON'); exit 1 }
$p = $json.tool_input.file_path
if (-not $p -and $json.cwd -and ($json.tool_input.command -match 'backlog\.md')) { $p = Join-Path $json.cwd 'backlog.md' }
if ($p -and ($p -match '(^|[\\/])backlog\.md$') -and (Test-Path -LiteralPath $p -PathType Leaf)) {
  $len = (Get-Item -LiteralPath $p).Length
  if ($len -gt 8KB) {
    $kb = '{0:N1}' -f ($len / 1KB)
    [Console]::Error.WriteLine("backlog.md is ${kb}KB; budget is 8KB (about 2.5k tokens). backlog.md is an index, not a body: move readouts, rulings and handoff history to their own files (toolkit GUIDE section 6) and keep one line plus a path here. Do not delete information.")
    exit 2
  }
}
exit 0
```

每个部署的脚本跑 echo 用例并粘贴输出——**没 echo 测过的 hook 不算部署**（静默死掉的
hook 比没有更坏，你以为强制层存在）。echo 从 PowerShell 执行、走真实 stdin 并模拟默认
代码页：`cmd /c "chcp 936 >nul & powershell -NoProfile -File x.ps1 < in.json"`，in.json 为
无 BOM UTF-8 且含中文。warn-backlog-size 用例：超 8KB 的 backlog.md（路径与内容含中文）
→ stderr + exit 2；小 backlog.md → 静默 0；其他文件 → 静默 0；Bash 命令提到 backlog.md 且
cwd 下的超标 → exit 2；坏 JSON → exit 1。warn-route-before-opsx 用例：`opsx:propose` → 一行
JSON；`change-loop` → 静默。

## Step 4 — 收尾

1. 装机级 break-check 一次：`npx openspec --version` + 最便宜的真实命令（如
   `npx openspec list`），确认命令面与工具包文档一致；不一致先改文档再依赖新行为。
   日后工具异常的排查要点见 GUIDE §4。
2. Commit 文档与配置（英文 message，不 push）。
3. 收尾声明：**bootstrap 到此为止——第一个 change 从 change-loop 的路由声明开始，
   不是从 propose 开始。** 然后停下；选第一个 backlog 条目是下一轮的事。

## Common mistakes

- brainstorm 之前手填模板（槽位只能空着或编造——顺序是承重的）。
- 覆盖 settings.json（静默杀掉其他工具的 hooks——必须 merge）。
- 跳过 echo 测试（hook 静默死掉 = 你相信一个不存在的强制层）。
- 把 bootstrap 完成当 propose 许可（第一个 change 与所有 change 一样从路由开始）。
- 迁移时只加新规则不删旧规则（项目 CLAUDE.md 优先级高于 skill，旧计数触发会压过新触发表）。
