# Field Log（实测日志，append-only）

> 工具包自身的 RED/GREEN 证据链，接棒 WORKFLOW.md 附录 H（已冻结）的版本备注职能。
> 记录纪律（README 修改约定的落地点）：改 skill 正文之前，证据先记入本文件（RED——
> 运行时失败、使用投票、官方指导均为合法形态）；改完补齐修复对照与验证证据，
> GREEN 观察项登记在对应条目的 ablation 台账中。
> 绕规则的原话逐字记录——它们是 rationalization 表的原料。新条目追加在最上方。

## 2026-08-14 — v5 减法重构：RED 证据与 ablation 台账

### RED（改前证据；本次形态 = 使用投票 + 官方指导，非运行时失败）

- **使用投票**（43 环节全量标注，2026-08-14 session）：已死 = 双模型架构（#7/#39）、
  toolchain-refresh 常设化（#35/#36）；走过场 = spec 四件套人审（#16）、recitation（#18）、
  证据包格式（#25）、R-revision 仪式（#28）、NORTH_STAR 独立文件（#38，设计为人独占修改，
  实际已授权 AI 自动更新）；真实人工触点仅两个 = spec 前 brainstorm 问答、收尾真机验收。
- **官方指导**：Anthropic《Prompting Claude Fable 5》："Skills developed for prior models
  are often too prescriptive for Claude Fable 5 and can degrade output quality."
  官方点名仍需外部支撑的四样：文件化持久记忆（实测 3x）、fresh-context 验证 subagent、
  进度声明对照 tool result 审计、意图上下文+短指令范围纪律。OpenAI GPT-5.6 指南：
  保留清单（结果/成功判据/停止条件/硬约束）恰为 Loop Contract 四字段；矛盾规则比缺失更伤；
  删减用 ablation 方法论。
- **主观基线**（改后对照用）：Opus 4.6 → Fable 5 用户无明显「变强」体感（与外界普遍体感相反），
  假设为过度约束吞掉了能力增量。
- 设计契约：`docs/specs/2026-08-14-v5-subtraction-design.md`（五段逐段人工确认 + 两轮自检）。

### Ablation 台账（复发 → 记一行含当时模型 → 只定点回装，不整体回滚）

| 切除项 | 守护的失败模式 | 复发信号 | 回装方式 |
|---|---|---|---|
| 四行声明块→两行 | 跳过路由/模式判断 | 无声明出现 opsx/代码（warn-route-before-opsx 报） | 恢复格式块 |
| Mode B 白名单法条 | 未审视意图直奔 spec | spec 返工 / R-revision 上升 | 恢复谓词清单 |
| recitation | 长会话目标漂移 | 产出偏离 Outcome | 恢复每 task 复述 |
| Rationalization/Red flags 表 | 借口式绕规则 | 借口原话再现 | 定点恢复对应条目 |
| warn-apply-phase hook | apply 中途重跑 propose | 契约失效无法归因 | 重新注册 hook |
| toolchain-refresh 常设 | 工具静默腐烂 | 命令突然失效/文档漂移 | 恢复 skill 或例行 |
| 40% 上下文教条 | 上下文过载质量跳水 | 长会话遵循度衰减 | 恢复阈值纪律 |
| NORTH_STAR 独立文件 | 价值锚稀释 | self-indulgence 未被拦截 | 恢复独立文件 |
| cheap-model 规范块 | 降级派发质量事故 | 降级 subagent 产出胡编 | 恢复规范块 |

### GREEN 观察位（下个真实项目 / 首个迁移项目，结果回填本条目）

1. 无格式强制下 brainstorm 是否仍默认先行（头号观察位）
2. 两行路由声明出现率；spec 返工 / R-revision 频次
3. stuck 判据是否仍截住无效重试
4. token 对比：change-loop 注入量（16KB→~5KB）、CLAUDE.md 常驻量
5. 主观对照：「模型是否变聪明」体感 vs 上面的 RED 基线

## 2026-08-09 — bootstrap 三测（zd-tool，small 项目首次立项）

### RED：`SPEC.md` 文件名在 WORKFLOW.md 与 skills 层之间语义冲突

- **观察**：按 WORKFLOW.md 附录 B 的小工程布局，把项目永久设计文档命名为根 `SPEC.md`。
  随后跑 `toolchain-refresh`，Step 0 mid-change guard 立刻误判「有变更进行中」——它把根
  `SPEC.md` 的存在当作 R1 变更的标志。追查发现三处 skills 层定义一致且与 WORKFLOW.md 相反：
  change-loop §「Where SPEC-lite lives (R1)」规定非 OpenSpec 项目的**单次变更** spec-lite 写入
  根 `SPEC.md` 并在收尾时移入 `docs/changes/`；toolchain-refresh mid-change guard 同义；
  `templates/CLAUDE.md` Session Start Protocol 同义。而 WORKFLOW.md 第 6 部分（整节）、附录 B、
  附录 F 把它当项目永久 spec（含 Tasks / Decisions / Progress Notes 段）。
- **未拦截住的后果（若不改）**：① 每次 toolchain-refresh 永远只做 inventory，不做更新，且
  「被 guard 拦下」看起来是正常行为，不会报错；② 第一次 change-loop 收尾会把项目永久设计文档
  移进 `docs/changes/`。两个都是静默失败。
- **修正（减法式）**：不重写流程，只统一文件名 + 标注冲突。小工程永久设计文档改名 `DESIGN.md`
  （WORKFLOW.md 第 6 部分全节、附录 B、附录 F、Layer 图、小工程核心循环图共 11 处）；
  第 6 部分与附录 F 顶部各加一个 ⚠ 块，写明「已修正=文件名 / 未修正=流程语义」，并声明
  冲突时以 skills 为准（依据 project-bootstrap「phase procedure lives in skills, not in this file」）。
- **遗留待决（未动）**：WORKFLOW.md 第 6 部分的流程本身仍是 v3 语义——无 Route Declaration、
  无 `NORTH_STAR.md`、无 `backlog.md`；附录 F 的小工程 CLAUDE.md 模板已被 `templates/CLAUDE.md`
  完全取代。该节是否保留 / 如何对齐，属产品决策，未替用户定。

### GREEN：project-bootstrap Step 3 的 hook 模板在 Windows 上有两个必须适配的点

- **`-m` 歧义**：heavy-test hook 模板的 `<SAFE_FILTER_REGEX>` 对 pytest 栈填 `\s-k\s` 类正则时，
  若一并放行 `-m`，会被 `python -m pytest` 里属于 **Python 的模块参数** `-m` 命中——该 hook 对
  每一条裸跑命令都放行，静默失效。修法：只检查 `pytest` 之后的参数尾串。
- **matcher 只写 `Bash` 会漏**：本机主 shell 是 PowerShell，测试命令走 PowerShell 工具时
  `"matcher": "Bash"` 不触发。改为 `"matcher": "Bash|PowerShell"`。
- 两点均经 17 条 echo 用例验证（含 `-m "not heavy"` / `-k` / 逃生变量 bash 与 pwsh 两种写法 /
  非测试命令），17/17 通过。
- **已回写进附录 G**（2026-08-09 同日）：settings.json 配置段 matcher 改 `Bash|PowerShell` 并加注；
  `<SAFE_FILTER_REGEX>` 说明改为「只匹配 runner 名之后的尾串」；模板脚本本体加入 runner-name
  split（复用 `<TEST_CMD_REGEX>` 作切分点，保持三个占位符）；验证用例从四个扩到五个，
  Test 5 专测 wrapper 短参数陷阱且要求用「日常真正敲的那条命令」；填充示例补 Python/pytest 一组。
- **回写时新发现的第三个坑**：模板复用 `<TEST_CMD_REGEX>` 做 `-split` 切分点，该正则**必须用
  非捕获组** `(?:...)`——PowerShell 的 `-split` 会把捕获组内容塞进结果数组，导致 `[1]` 拿到的是
  捕获文本而非参数尾串。实测：`'x npm run test --testNamePattern y' -split '\bnpm\s+(test|run\s+test)\b',2`
  的 `[1]` = `'run test'`；换成 `(?:...)` 后 `[1]` = `' --testNamePattern y'`。已写入模板 CAUTION 段。

### 附带发现：Opus 注入 wrapper 静默失效（已随用户决定整体移除）

- 2026-07-20 装的 `$PROFILE` wrapper 正则为 `^opus$|opus-4-8`，用户升级默认模型到
  `claude-opus-5[1m]` 后匹配不上；且三个 `settings.json` 均无 `model` 字段、
  `$assumeOpusDefault = $false`，导致裸跑 `claude` 一直未注入。**从 07-20 到 08-09 期间
  所有「以为注入了」的会话实际都没注入**，且无任何可见症状。
- 用户判定注入机制在 Opus 5 后已不需要，wrapper 整体删除（备份
  `Microsoft.PowerShell_profile.ps1.bak-2026-08-09`）。project-bootstrap Step 4 相应作废。
- **教训**：把版本号硬编码进匹配条件的自动化，失效时是静默的。若将来再引入同类机制，
  必须带一条「注入是否生效」的可观察输出。

## 2026-07-09 — v4.1 二测（finance_tool，第二个 change 归档后）

### 用户澄清设计意图：Verify/Polish 是判断项不是必走项，但「未起」必须归档时主动汇报

- **观察**：add-research-report 归档时未跑 /opsx:verify 与 Polish（5.7.1/5.7.2），归档汇报也未说明
  「未起及原因」；用户追问后才对照出实质覆盖矩阵（5.6.1 被 R2 spec reviewer 的 Requirement 覆盖表
  吸收、5.6.2 被契约端到端实跑覆盖、5.7 部分被 findings 驱动的 remediation 覆盖）。
- **用户原话**：「这个verify和polish的流程，也不是说每个change都死板的必走，我在设计这个change-loop
  的skill时也说是希望ai根据任务和状态等自行判断是否要起verify和polish的流程，需要起就直接起，如果
  没有起，在归档后要告诉我一声并说明不需要起的原因。change-loop的skill我们不能在做加法，也应该根据
  实际和真正的便利性，合理的做减法」
- **修复（减法式）**：不加新块、不加新声明格式——只扩写 Step 4 evidence bundle 既有条目
  「Anything skipped or deferred, stated plainly」，点名 §5.6 Verify / §5.7 Polish 为 judgment call：
  需要则直接起，跳过则归档汇报带「未起 + 原因」。

## 2026-07-08 — v4.1 二测（finance_tool，第二个 change propose 前）

### 用户发现：change-loop skill 丢失了 WORKFLOW.md §5.3 的 pre-spec Explore 声明

- **RED（用户原话）**：「一般在进propose前，不是应该判断是否过一轮explore吗，我看上一个change你也没问，是我的这个工作流skill没有写明这一点，还是你已经默认判断这个change到这里已经不需要走explore了？」
- **根因**：v4.1 重写 change-loop 时，§5.3 的显式 Explore 声明被 Route Declaration 的 `Explored:` 行吸收——但两个检查点时机不同：`Explored:` 在 route 前（brainstorm 之前），§5.3 在 brainstorm 之后、spec 之前。brainstorm 可能冒出新依赖/新代码面，合并后没有形式化触发器强制回头再看。实证：add-data-access 含新外部依赖，按 §5.3 判据应答「需要」，其重型 vendor 调研在功能上覆盖了 explore，但声明形式未走，用户无法看到判断发生过。
- **修复**：change-loop skill 补「Pre-spec explore declaration」轻量一行式（needed / not needed + 理由，三触发判据沿用 §5.3），置于 Mode 段之后；Red flags 增补一条。不恢复独立阶段。

## 2026-07-07 — v4.0 首测（Opus 会话，真实新项目立项）→ v4.1

### 用户报告的 8 条发现 → 修复对照

| # | 首测发现 | 根因 | v4.1 修复 |
|---|---|---|---|
| 1 | 部署全手动（复制 skills、手配 hooks） | 立项/部署无 owner——GUIDE §4 是给人的文档，违反自家约束下沉原则 | 新增 `project-bootstrap` skill：AI 执行、人确认 |
| 2 | NORTH_STAR/CLAUDE.md 立项前人填不出 | 部署顺序颠倒：先填模板后 brainstorm | 顺序反转：brainstorm → AI 回填 → 人逐行确认 |
| 3 | heavy-test hook 立项前无法决策 | 同 #2（stack 未定，模板三个空无解） | hooks 移到 bootstrap Step 3（brainstorm 之后），步骤可重入、可回补 |
| 4 | 立项讨论不主动调 superpowers:brainstorming | 立项时项目 CLAUDE.md 尚不存在，无触发路径 | bootstrap Step 1 显式 REQUIRED SUB-SKILL；description 含中文触发词（立项/新项目） |
| 5 | 立项完成后不主动触发 change-loop | description 只覆盖"starting a change"，漏掉"立项→实现"交接时刻 | change-loop description 增补交接与 backlog 触发；bootstrap Step 5 以"下一个动作是 change-loop"收尾 |
| 6 | 跳步：直接 propose，无 Mode 判断、无 explore | 路由输出是散文，可只说一半（结构缺失型失败，per writing-skills Match-the-Form）；且路由表 Process 列把 R2 写成 "Full propose → loop"，把 propose 误导成路由后的下一步、短路了 Mode 判断（追问 #Q1 确认：R2≠Mode B——新外部依赖型 R2 从定义上过不了谓词 2，多数 R2 应为 Mode A） | Route Declaration 四行必填块 + Process 列显式插入 Mode 步骤 + Mode↔Next 绑定（Mode A + Next: propose = 自相矛盾）+ `warn-route-before-opsx` hook（harness 兜底） |
| 7 | OPUS-SYSTEM.md 全程未注入 | 注入依赖人手动执行命令（记忆型约束）；追问 #Q2：独立 `opus` 别名也会被「直接敲 claude、默认模型已是 Opus」的启动习惯绕过 | 模型感知 `claude` wrapper 写入 `$PROFILE`（解析 --model → env → settings 三级，命中 Opus 才注入），注入自动化且不依赖启动习惯 |
| 8 | toolchain-refresh / value-review 未触发 | value-review：未达触发条件（正常，非缺陷）；toolchain-refresh：bootstrap 触发点无人执行，且不覆盖工具包自身 | bootstrap Step 5 显式调用；toolchain-refresh 增加工具包自更新步骤 |

### 同批排查发现的潜在问题（用户未报，已修）

- **引用不可解析**：项目会话里 `dispatch-prompt` / "WORKFLOW.md 附录 G/§5.8" 无处解析（clone 路径没有任何记录）→ dispatch-prompt.md 移入 change-loop skill 随部署走；CLAUDE.md 模板加 Toolkit 行；clone 路径落 `~/.claude/my-work-skill.toolkit-path`。
- **双权威**：OPUS-SYSTEM.md Working loop 自带一套粗粒度路由，Opus 可能照它走而不调 change-loop → 加 authority 让渡行。
- **skills 部署副本永不自更新**：toolchain-refresh 只更新插件不更新工具包自身 → Update 步骤增补。
- **settings.json 覆盖风险**：AI 配 hooks 时整文件覆盖会杀掉其他工具（如 claude-mem）的 hooks → bootstrap 明确 MERGE 纪律。
- **保鲜兜底 hook 只存在于文档**：`warn-toolchain-stale` 写在 toolchain-refresh 里但从未部署 → bootstrap 默认部署。
- **实测记录无落点**（本文件的由来）：README 要求「先有失败证据再改 skill」但没说证据记在哪；首测记录被权宜塞进 GUIDE §8 → 建本文件，README 修改约定补落点。

### 当日验证证据（GREEN 微测，近似——真实证据待下个项目）

- **触发微测**（subagent，3 场景）：空仓立项 → project-bootstrap ✓；有 NORTH_STAR 项目 backlog 取项 → change-loop ✓；v3 项目迁移 → project-bootstrap ✓。
- **防跳步微测**（subagent 复现首测失败场景「立项刚结束，开始第一个 change」，2 遍）：两遍均先只读探索 → 完整四行声明块 → Mode A 判断（逐条核对三个白名单谓词）→ Next 指向 brainstorm 而非 propose。
- **hook 脚本实跑**（5 用例）：opsx:propose 触发提醒 / change-loop 静默 / 40 天 stale 告警 / 新鲜文件静默 / 缺文件基线提示，全过。
- **`claude` wrapper 实跑**（5 用例，本机真实 settings）：显式 `--model opus` 注入 / 全名 `claude-opus-4-8` 注入 / 无参回落 settings（当时为 fable → 正确不注入）/ 环境变量优先于 settings / 显式 fable 覆盖 opus 环境变量，全过。

### 后续规则

- 若 v4.1 复测中 Route Declaration 块仍被跳过 → 按约束下沉原则升级为硬 hook（block 而非 warn）。
- GREEN 观察清单见 GUIDE §8（含 Mode↔Next 自洽率、路由分布、wrapper 行为学证据等本轮新增项）。

涉及文件：新增 skills/project-bootstrap/、FIELD-LOG.md；改 skills/change-loop/SKILL.md、skills/toolchain-refresh/SKILL.md、templates/CLAUDE.md、templates/NORTH_STAR.md、OPUS-SYSTEM.md、GUIDE.md、README.md、quickstart.html；templates/dispatch-prompt.md → skills/change-loop/dispatch-prompt.md。
