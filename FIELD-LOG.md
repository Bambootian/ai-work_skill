# Field Log（实测日志，append-only）

> 工具包自身的 RED/GREEN 证据链，接棒 WORKFLOW.md 附录 H（已冻结）的版本备注职能。
> 记录纪律（README 修改约定的落地点）：改 skill 正文之前，失败证据先记入本文件（RED）；
> 改完补齐修复对照与验证证据，GREEN 观察项进 GUIDE §8 清单。
> 绕规则的原话逐字记录——它们是 rationalization 表的原料。新条目追加在最上方。

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
