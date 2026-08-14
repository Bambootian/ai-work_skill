# my-work-skill v5 减法重构 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 按 `docs/specs/2026-08-14-v5-subtraction-design.md`（唯一契约）把工具包从 v4 法条体系重构为 v5 契约内核体系。

**Architecture:** 纯文档/skill 重写工程，无运行时代码。每个 task = 一个文件的完整重写或删除，验证方式 = 尺寸检查 + 陈旧锚点 grep + 内容比对，逐 task commit（绿 = 验证命令输出符合预期）。

**Tech Stack:** Markdown、PowerShell（验证命令）、git、kb MCP（沉淀）。

## Global Constraints

- 唯一契约：`docs/specs/2026-08-14-v5-subtraction-design.md`。实现与 spec 冲突时先改 spec 再改实现。
- 模型下限 Opus 5；不做单一模型特调；skill 文本对整个 frontier class 有效。
- WORKFLOW.md v3.6 **一字不改**（含附录 G 中已废 hook 的源码段落）。
- FIELD-LOG.md append-only：新条目加在最上方（文件头预告段除外，见 Task 1）。
- commit message 英文，不 push。
- 尺寸目标（硬约束，超出即回去删）：change-loop SKILL.md ≤6.5KB；dispatch-prompt.md ≤2KB；project-bootstrap SKILL.md ≤5KB；GUIDE.md ≤6KB；templates/CLAUDE.md ≤3KB。
  （修订记录：change-loop 原定 ≤6KB 按英文密度校准；中文正文 3 字节/字，同等信息量字节数
  天然更高。真实控制目标是 token 注入量——6.2KB 中文 ≈1.7k token，对比 v4 16KB ≈4k+，
  已达成 ~1/3 目标。为凑字节数肢解可读文本属表演式合规，不做。）
- 所有新文件不得引用已删除的锚点：`NORTH_STAR.md`（迁移语境除外）、`OPUS-SYSTEM`、`toolchain-refresh`（迁移/对照语境除外）、四行声明块（Explored:/Mode:）、recitation、40% 阈值。

---

### Task 1: FIELD-LOG — RED 证据 + ablation 台账

**Files:**
- Modify: `E:\opc_project\my-work-skill\FIELD-LOG.md`（文件头第 5 行 + 顶部追加新条目）

**Interfaces:**
- Produces: ablation 台账（后续所有回归观察的登记处；Task 2 的 GUIDE 不再含验证清单，指向这里）

- [ ] **Step 1: 修正文件头的 GREEN 去向指向**

将第 4–5 行：

```markdown
> 记录纪律（README 修改约定的落地点）：改 skill 正文之前，失败证据先记入本文件（RED）；
> 改完补齐修复对照与验证证据，GREEN 观察项进 GUIDE §8 清单。
```

改为：

```markdown
> 记录纪律（README 修改约定的落地点）：改 skill 正文之前，证据先记入本文件（RED——
> 运行时失败、使用投票、官方指导均为合法形态）；改完补齐修复对照与验证证据，
> GREEN 观察项登记在对应条目的 ablation 台账中。
```

- [ ] **Step 2: 在「## 2026-08-09」条目之前插入新条目**

````markdown
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
````

- [ ] **Step 3: 验证**

Run: `Select-String -Path FIELD-LOG.md -Pattern "GUIDE §8|GUIDE \$8" ; Select-String -Path FIELD-LOG.md -Pattern "2026-08-14" | Select-Object -First 1`
Expected: 第一条无输出（GUIDE §8 指向已清除）；第二条命中新条目标题行。

- [ ] **Step 4: Commit**

```powershell
git add FIELD-LOG.md; git commit -m "docs(field-log): record v5 RED evidence and ablation ledger before skill edits"
```

---

### Task 2: GUIDE.md v5 重写

**Files:**
- Rewrite: `E:\opc_project\my-work-skill\GUIDE.md`（整文件替换）

**Interfaces:**
- Consumes: Task 1 的 ablation 台账（§4 不再含验证清单）
- Produces: v4→v5 对照表（Task 6/7 迁移逻辑的速查依据）；融合决策记录压缩表（Task 10 kb_deposit 的内容源）

- [ ] **Step 1: 用以下完整内容替换 GUIDE.md**

````markdown
# my-work-skill v5 使用指南

> v5 = v4 的契约内核 + 面向 2026 frontier class 模型（能力下限 Opus 5）的减法重构。
> 设计契约与全部证据：`docs/specs/2026-08-14-v5-subtraction-design.md`。
> WORKFLOW.md v3.6 冻结：附录 G（hooks 源码）、5.4.1（R-revision）、5.8（archive）仍是被引权威。

## 1. 设计原理（一页）

**四层工程模型**：Harness（hooks/settings——确定性强制）→ Context（CLAUDE.md 常驻 /
skills 按需 / 持久文件）→ Prompt（skill 正文、dispatch 模板）→ Loop（契约控制迭代与退出）。

**约束下沉原则**（每写一条约束，自底向上问）：能 hook 强制吗 → 能变成模板必填槽位吗 →
能做成 skill 按需注入吗 → 都不能且每步都需要，才进 CLAUDE.md 常驻。

**v5 四原则**：

1. **下限锚定 Opus 5**：保留的约束必须对 Opus 5 有效；切除的必须 Opus 5 也不需要。
2. **不做单一模型特调**：模型校准是厂商的事，不为任何模型建补课层。回归记录标注当时模型。
3. **内核 harness 中立**：契约格式、spec 文件、CLAUDE.md 约定是纯 markdown；
   skills/hooks 是 Claude Code 适配层。不为其他 harness 预写适配器。
4. **提示层做减法，harness 层按误伤率取舍**：「过度约束反噬能力」全部指提示层文本；
   hook 零上下文成本，去留只看误报率。

**官方仍要求外部支撑的四样**（《Prompting Claude Fable 5》，对整个 frontier class 成立）：
文件化持久记忆、fresh-context 验证 subagent、进度声明对照 tool result 审计、
意图上下文 + 短指令形式的范围纪律。本工具包分别以 Loop Contract 与 land-the-plane、
分级 gate 评审、证据 gate、North Star 段承载——这四样是保留项的骨架。

## 2. 循环速查（数值与判据的权威在 change-loop skill，冲突以彼为准）

| 要素 | 内环（task） | change 环 | value 环 |
|---|---|---|---|
| 终止 | 绿+commit；stuck 判据或 5 迭代 → SPLIT/BLOCKED | DONE / BLOCKED / SPLIT | retro 写完交人决策 |
| 回退 | 绿锚点 reset；fix-forward 仅限迭代内 | spec 层 R-revision；计划层重生成 tasks | 人批准前零落地 |
| 粒度 | 一 task 一迭代 | 0.5–2 天；超预算 = SPLIT 不是加班 | 5 archive / 4 周 |
| 验证 | 具名命令 + 期望输出 | Verify 全跑 + 真机验收 | 上轮承诺核销先行 |

## 3. 融合决策记录（为什么不用 X——防止半年后重新调研一遍）

| 候选 | 结论 | 一句话理由 |
|---|---|---|
| BMAD 全套 | 拒 | 实测 6 天 $200 vs 别人 1–2 天；QA agent 对坏构建报 "Perfect"；为 5–20 人团队设计 |
| Gas Town / 20+ agent 编排器 | 拒 | 作者本人劝退大多数开发者；solo 无收益纯成本 |
| beads | 暂缓 | backlog.md + OpenSpec + claude-mem 已覆盖；依赖图真痛了再装（git-native 随时可补） |
| Spec Kit / Kiro 迁移 | 拒 | SDD 横评 OpenSpec 赢 solo 场景（最低摩擦 + 最佳 brownfield）；迁移零增益 |
| ralph 官方插件 | 拒 | 隐藏 hooks、卸载可能破库（HumanLayer 弃用实证） |
| 巨型 subagent fan-out | 拒 | 配额燃烧 + 非确定性；保留主循环单层扁平扇出 |
| 多层 agent 树（孙 agent） | 拒 | token 乘法失控（实测）+ 约束传话失真 + 归因断裂；一层扁平扇出是唯一编排形态 |
| 双模型架构（OPUS-SYSTEM 注入） | 退役 | 模型下限 Opus 5 后失去补课对象；2026-07 实测手动注入必忘 |
| 无人值守 ralph 驱动脚本 | 退役 | frontier class 原生长时程自治 + 异步检查取代土法循环 |

## 4. 工具链排查要点

命令突然失效 / skill 不触发 / 文档与命令面不符时：查版本（`/plugin list`、
`npx openspec --version`）→ 跑最便宜的真实命令做 break-check → hook echo 用例复验
（附录 G 四用例——hook 静默死掉是最坏失败模式）→ 先改文档再改实践（约束先行）。
装机基线由 bootstrap Step 4 的一次 break-check 建立。

## 5. v4 → v5 对照速查

| v4 | v5 |
|---|---|
| NORTH_STAR.md 独立文件 + Review Log 表 | CLAUDE.md North Star 段；节奏锚 = `retros/` 最新文件日期 |
| 四行 Route Declaration（Route/Explored/Mode/Next） | 两行（Route + Next）+ 三条一行规则 |
| Mode A/B 白名单谓词 + tripwire 法条 | 一行：默认 brainstorm，有证据工件或明说才跳过 |
| OPUS-SYSTEM.md + `$PROFILE` claude wrapper | 删除（下限 Opus 5，不做模型特调） |
| toolchain-refresh skill + 定时任务 + staleness hook | bootstrap 一次 break-check + 症状排查（§4） |
| 7 hooks | 5（删 warn-apply-phase、warn-toolchain-stale） |
| recitation / 40% 上下文教条 / 无人值守 recipe | 删除（官方：instruction retention 已达标；数字过时） |
| dispatch 降级白名单 + cheap-model 行动规范 | 默认继承会话模型；web 抓取类必降 Sonnet；禁孙 agent |
| Rationalizations 表 + Red flags 清单 | 删除（官方：短指令与逐条枚举同效；复发走 ablation 台账回装） |
| GUIDE §8 验证计划 | FIELD-LOG ablation 台账 + GREEN 观察位 |
````

- [ ] **Step 2: 验证**

Run: `(Get-Item GUIDE.md).Length; Select-String -Path GUIDE.md -Pattern "OPUS-SYSTEM|Explored:|recitation" | Measure-Object | Select-Object -ExpandProperty Count`
Expected: 长度 ≤ 6144；匹配计数只来自 §5 对照表 v4 列（≤3 处，且全部在表格行内）。

- [ ] **Step 3: Commit**

```powershell
git add GUIDE.md; git commit -m "docs(guide): rewrite as v5 — one-page principles, decision record, v4->v5 map"
```

---

### Task 3: README.md v5 更新

**Files:**
- Rewrite: `E:\opc_project\my-work-skill\README.md`

**Interfaces:**
- Produces: 修改约定新表述（Task 1 已按此执行的「证据形态」条款）

- [ ] **Step 1: 用以下完整内容替换 README.md**

```markdown
# my-work-skill

AI 工程开发工作流 v5：契约内核 + 2026 frontier class 模型适配（能力下限 Opus 5）。
设计契约：`docs/specs/2026-08-14-v5-subtraction-design.md`。

## 目录结构约定

​```
my-work-skill/
├── WORKFLOW.md              # v3.6 冻结参考；附录 G hooks / 5.4.1 R-revision / 5.8 archive 仍是权威
├── README.md                # 本文件：结构与修改约定
├── GUIDE.md                 # v5 使用指南：设计原理、循环速查、决策记录、排查要点、v4→v5 对照
├── FIELD-LOG.md             # 实测日志（append-only）：RED/GREEN 证据链 + ablation 台账
├── docs/specs/              # 设计契约
├── docs/plans/              # 实现计划
├── skills/                  # 由 project-bootstrap 部署到 ~/.claude/skills/
│   ├── project-bootstrap/   # 部署 + 立项：装 skills、brainstorm、回填、hooks、break-check
│   ├── change-loop/         # 核心：风险路由 + 契约循环（含 dispatch-prompt.md 派发模板）
│   └── value-review/        # 价值回顾（触发表 + 压缩流程；深度重设计待独立 change）
└── templates/
    └── CLAUDE.md            # v5 项目模板（含 North Star 段，~40 行常驻）
​```

## 修改约定

- 改流程先改本仓库文档，再改各项目实践（约束先行）。
- skills 修改先有证据再改正文：证据落 `FIELD-LOG.md`（append-only）——运行时失败、
  使用投票、官方指导均为合法证据形态；改后补验证对照。
- 循环机制的数值与判据唯一权威在 `skills/change-loop`；GUIDE 等处速查冲突以 skill 为准。
- WORKFLOW.md v3.6 不再增改；新经验进 GUIDE.md 与 skills，实测证据进 FIELD-LOG.md。
- 模型下限 Opus 5：不为更弱模型加约束，不为特定模型建特调层。

## 部署

对项目说「立项」或「部署工作流」→ `project-bootstrap` 接管。
冷启动（机器无任何 skill）：clone 本仓库 → 让 AI 读 `skills/project-bootstrap/SKILL.md` 照做。
```

（注：上面结构图里的 ​``` 转义仅为本计划嵌套所需，落盘时写正常三反引号。）

- [ ] **Step 2: 验证**

Run: `Select-String -Path README.md -Pattern "NORTH_STAR|OPUS-SYSTEM|toolchain-refresh|quickstart" | Measure-Object | Select-Object -ExpandProperty Count`
Expected: 0

- [ ] **Step 3: Commit**

```powershell
git add README.md; git commit -m "docs(readme): declare v5 — structure, amended evidence rule, model floor"
```

---

### Task 4: change-loop SKILL.md 重写

**Files:**
- Rewrite: `E:\opc_project\my-work-skill\skills\change-loop\SKILL.md`

**Interfaces:**
- Consumes: spec §4 六节结构
- Produces: 两行路由声明格式（Task 7 的 warn-route-before-opsx 文案、Task 6 模板 Hard Rules 与之对齐）；`superpowers:brainstorming` / `superpowers:systematic-debugging` 为仅有的外部 skill 依赖

- [ ] **Step 1: 用以下完整内容替换 SKILL.md**

````markdown
---
name: change-loop
description: Use when starting any development change — feature, bugfix, refactor, or the first change after project bootstrap / 立项 — in a project using this workflow (the project CLAUDE.md has a North Star section or mandates route declaration). Invoke BEFORE any opsx command (propose/apply), spec writing, solution brainstorming, or code; also when picking an item from backlog.md, and when resuming an in-progress change after a session break or context compaction.
---

# Change Loop

每个 change 是一个有契约、有预算、三态出口的循环。人工触点两个：spec 前的 brainstorm
问答、收尾的真机验收；gate 之间由 AI 自治。循环体：**每迭代恰好一个 task，绿进绿出，
逐 task commit。**

## 1. Route（任何 spec / opsx 命令 / 代码之前）

按 novelty × reversibility × blast radius 判断，声明两行：

```
Route: R<0-3> — <一行理由>
Next: <brainstorm | SPEC-lite | opsx propose | test>
```

- **R0 直行**：一次 commit 可逆、无 spec/架构/数据契约影响、≤1 小时 → 测试→代码→commit。
  开工前一句话说明 verify 命令与期望结果，commit 前展示其输出。
- **R1 轻量**：意图 2–3 句说得清、单 capability、无新架构决策/外部依赖 → SPEC-lite。
- **R2 标准**：新 capability、跨模块、或新外部依赖 → OpenSpec propose 四件套；
  spec 经人批准后进循环。
- **R3 架构**：动 ARCHITECTURE 决策、数据契约或 North Star 边界 → 先与人定方向，再走 R2 流程。

三条规则：**没读过要动的代码不路由**——路由判断的是爆炸半径，半径在代码里，先只读
explore 再声明，对既有代码的假设靠读取验证、不靠回忆。**默认先 brainstorm**
（superpowers:brainstorming）——仅当手上已有具体证据工件（bug 复现 / verify 输出 /
评审发现）或用户明说跳过时直接写 spec，跳过前用 ≤3 句复述意图与边界。
**拿不准取高一级**，中途升级正常但要声明，静默降级禁止。

## 2. Loop Contract（R1+，写进 tasks.md 或 SPEC-lite 头部）

```markdown
## Loop Contract
- Outcome: <一句用户可见词汇——用户得到什么>
- Verify: <具名命令 + 期望输出。"测试通过"四个字无效>
- Budget: <max 天数>；每 task 最多 5 次迭代
- Exit: DONE（Verify 全绿 + Outcome 落地）| BLOCKED（blockers 附后，升级给人）
      | SPLIT（超预算或发现复合任务 → 提拆分方案）
```

Outcome 只能用实现词汇写出（重构/统一/抽象/覆盖率）→ 这是 enabling 工作：指名它解锁的
user-value 与落地时点（≤2 个 change）；指不出 → 先走 value-review。

R1 SPEC-lite（Goal / Non-goals / Scenarios / Loop Contract 单文件）位置：OpenSpec 项目
`openspec/changes/<change-id>/spec-lite.md`；其他项目根目录 `SPEC.md`，收尾移入
`docs/changes/`。根目录 `SPEC.md` 属于**一个 change**、不属于项目——项目常设设计文档叫
`DESIGN.md`。

## 3. 内环（自治）

每 task：读 scenario → 有运行时行为先写失败测试 → 最小实现 → 绿 → 自审 diff → commit →
下一个。task 之间不请示，只报进度。

- **只在绿提交**；最后一个绿 commit 是回退锚点（新仓库先把测试骨架跑绿提交，立锚）。
  迭代结束树是坏的：`git reset --hard` 回锚点 → 失败注记（task id + tried / observed /
  hypothesis）append 进契约 → 立即 docs-commit（保注记跨越未来的 reset）→ 换思路重试或
  BLOCKED。fix-forward 仅限迭代内，不跨 task 边界；不从红树开新 task。
- **每次失败尝试都记注记**（不止坏树的）：注记就是尝试计数器——对话记忆不跨 compaction，
  文件跨。
- **Stuck 判据（任一命中即停止换说法重试）**：空 diff 迭代；同一错误签名连续 2 次；
  修 A 坏 B 坏 A 往返一圈。命中（或 5 次上限）→ 写注记 → superpowers:systematic-debugging。
  诊断 = 复合任务 → 拆分（spec 范围内自治改 tasks.md 继续；动 spec/范围/预算 = change 级
  SPLIT，停下交人）；其余未解 → BLOCKED。计划与现实脱节（R-revision 后漂移）→ 从 spec
  重生成剩余 tasks，不逐行补丁。
- 语义模糊（需求含义 / 边界 / 设计意图）停下问人；实现模糊自选合理项、注记一行、继续。

## 4. Subagents（单层扁平扇出）

subagent 看不到你的任何上下文：项目硬规则、测试命令纪律、本 change 契约，按本目录
`dispatch-prompt.md` 的槽位**逐字重述**，每次都是。**禁止 subagent 再派 agent。**
高噪音工作（全量测试日志、构建考古）隔离到 subagent，只回 ≤2k token 摘要。

gate 评审用 fresh-context reviewer（只给 diff + spec + 标准，不给产生代码的推理过程），
按路由分级：R0 inline 自检 / R1 单 reviewer / R2 双视角（spec 合规 + 代码质量）/
R3 三视角（+ skeptic）+ 人。发现分诊：[blocking] = 违反 spec/契约，或真实缺陷
（正确性 / 资源泄漏 / 数据丢失 / 安全）——必修；[nit] = 风格与「可以更好」——记录不追。

## 5. Close（证据 gate）

- 每条 Verify 命令的真实输出粘贴（不概述、不「应该过」）。
- Outcome 一行：用户可见的东西落地了吗。
- 出口态声明：DONE / BLOCKED / SPLIT；跳过或合并的环节（如 WORKFLOW §5.6 Verify /
  §5.7 Polish——它们是 judgment call 不是必选项）明说并给理由。
- 按 WORKFLOW.md §5.8 archive（toolkit clone 路径在项目 CLAUDE.md 的 Toolkit 行）。
- archive 后查节奏：`retros/`（OpenSpec 项目 `openspec/retros/`）最新文件起 ≥5 个
  archive 或 ≥4 周 → 现在触发 value-review。这一步就是节奏强制，不靠记忆。

## 6. Session 边界（land the plane）

task 组结束、任何 gate、或 harness 警告上下文时收工：更新 tasks.md 勾选与契约状态，
写 2–3 行 next-session brief（当前 task / 下一步 / 悬而未决）进 change 的 CLAUDE.md。
文件携带状态，不靠对话。

恢复：`git status` 先行——有未提交改动 = 中断的迭代：注记与 tasks.md 能说清状态就收完
这一个迭代，说不清就 reset 回锚点。然后读契约 + tasks.md + change CLAUDE.md，
≤2 行报告状态，直接继续循环——只在 gate 或阻塞时问。
````

- [ ] **Step 2: 验证**

Run: `(Get-Item skills\change-loop\SKILL.md).Length; Select-String -Path skills\change-loop\SKILL.md -Pattern "NORTH_STAR|Explored:|Mode: A|Mode: B|recitation|Rationalization" | Measure-Object | Select-Object -ExpandProperty Count`
Expected: 长度 ≤ 6144；计数 = 0。

- [ ] **Step 3: Commit**

```powershell
git add skills\change-loop\SKILL.md; git commit -m "feat(change-loop): rewrite as v5 — contract core, two-line route, brief-instruction form"
```

---

### Task 5: dispatch-prompt.md 重写

**Files:**
- Rewrite: `E:\opc_project\my-work-skill\skills\change-loop\dispatch-prompt.md`

**Interfaces:**
- Consumes: Task 4 §4 的派发规则（单层扇出、web 抓取降级）
- Produces: 六槽位模板（Task 6 模板 Hard Rules 引用之）

- [ ] **Step 1: 用以下完整内容替换 dispatch-prompt.md**

````markdown
# Subagent Dispatch Template

> subagent 看不到主循环的任何上下文；省略任何 REQUIRED 槽位 = 派发无效。

```markdown
## Model (REQUIRED)
<默认继承会话模型。例外：浏览器自动化 / 网页抓取类派发必须降级 Sonnet 或更低
（token 失控实测多次）。裁判永不弱于产出方。>

## Objective (REQUIRED)
<一个任务，一个产出。不是两个。>

## Context (REQUIRED)
<change-id、相关文件路径、已存在什么——最小必需。无对话史。>

## Constraints (REQUIRED — 逐字重述，不摘抄改写)
- 项目硬规则：<粘 CLAUDE.md 相关行>
- 测试命令纪律：<粘，如 only `dotnet test --filter ...`；永不自行设置 escape 变量>
- Loop contract：<粘 Outcome / Verify / Budget>
- Scope：只动 <files/areas>；无顺手改动

## Output format (REQUIRED)
<返回什么——数据，不是叙事。目标 ≤2,000 token。>

## Boundaries (REQUIRED)
- 禁止再派 agent（单层扁平扇出，无例外）
- Do NOT: <commit / push / 改 spec / 全量测试 / ...>
- 失败时：返回 tried / observed / hypothesis；同一失败最多 2 次尝试后停下报告。
```

## Reviewer 变体（gate 评审）

- fresh-context：只给 diff + spec + 评审标准，**不给**产生代码的推理过程。
- 每条 finding 标注：[blocking] = 违反 spec/契约，或真实缺陷（正确性 / 资源泄漏 /
  数据丢失 / 安全）——必修，架构/质量视角发现的真实缺陷同样是 [blocking]；
  [nit] = 风格与「可以更好」——记录不追（防评审驱动的过度工程）。
- R2 双视角：spec 合规与代码质量分开派发，不共享结论。
- R1 单 reviewer 额外职责：核对 Verify 命令是否真覆盖 Scenarios——弱验证是 R1 最大漏风口。
- 多 reviewer 结论冲突：不自行仲裁——原话并列进证据包，人裁。冲突点通常正是 spec 的真模糊处。
````

- [ ] **Step 2: 验证**

Run: `(Get-Item skills\change-loop\dispatch-prompt.md).Length; Select-String -Path skills\change-loop\dispatch-prompt.md -Pattern "cheap-model|降级白名单|可降级" | Measure-Object | Select-Object -ExpandProperty Count`
Expected: 长度 ≤ 2048；计数 = 0。

- [ ] **Step 3: Commit**

```powershell
git add skills\change-loop\dispatch-prompt.md; git commit -m "feat(change-loop): slim dispatch template — flat fan-out, web-scrape downgrade exception"
```

---

### Task 6: templates/CLAUDE.md 重写 + 删除三个死文件

**Files:**
- Rewrite: `E:\opc_project\my-work-skill\templates\CLAUDE.md`
- Delete: `E:\opc_project\my-work-skill\templates\NORTH_STAR.md`
- Delete: `E:\opc_project\my-work-skill\OPUS-SYSTEM.md`
- Delete: `E:\opc_project\my-work-skill\quickstart.html`

**Interfaces:**
- Consumes: spec §6 模板全文（Session Start 行为修正后版本）
- Produces: North Star 段结构（Task 7 bootstrap Step 1 的槽位、Task 8 value-review 的分类判据锚）

- [ ] **Step 1: 用 spec §6 的模板全文替换 templates/CLAUDE.md**

内容 = spec `docs/specs/2026-08-14-v5-subtraction-design.md` §6 代码块内的完整 markdown（从 `# Project: <name>` 到 Enforcement 段末行），一字不差。落盘前核对 Session Start 行是「读 North Star 段；中型项目另读 backlog.md；…」。

- [ ] **Step 2: 删除死文件**

```powershell
git rm templates\NORTH_STAR.md OPUS-SYSTEM.md quickstart.html
```

- [ ] **Step 3: 验证**

Run: `(Get-Item templates\CLAUDE.md).Length; Test-Path templates\NORTH_STAR.md, OPUS-SYSTEM.md, quickstart.html`
Expected: 长度 ≤ 3072；三个 False。

- [ ] **Step 4: Commit**

```powershell
git add templates\CLAUDE.md; git commit -m "feat(templates): merge North Star into CLAUDE.md; remove NORTH_STAR.md, OPUS-SYSTEM.md, quickstart.html"
```

---

### Task 7: project-bootstrap 重写 + 删除 toolchain-refresh

**Files:**
- Rewrite: `E:\opc_project\my-work-skill\skills\project-bootstrap\SKILL.md`
- Delete: `E:\opc_project\my-work-skill\skills\toolchain-refresh\`（整目录）

**Interfaces:**
- Consumes: Task 4 两行声明格式（hook 文案）、Task 6 模板结构（Step 2 回填目标）
- Produces: 部署/迁移的唯一入口；warn-route-before-opsx 新文案

- [ ] **Step 1: 用以下完整内容替换 SKILL.md**

````markdown
---
name: project-bootstrap
description: Use when starting a new project with this workflow (立项 / 新项目 / kick off a project), deploying or updating the toolkit's skills and hooks on a machine or in a project (部署工作流), migrating a v3/v4 project, or when the Session Start Protocol finds the project CLAUDE.md missing its North Star section (or a medium project missing backlog.md).
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
   部署的是副本，不会自更新）；**同时删除 `~/.claude/skills/` 下工具包已移除的 skill
   目录（如 toolchain-refresh）**——覆盖复制不清理死副本，死 skill 的触发词仍会命中。
3. 前置：superpowers 插件在（brainstorming / systematic-debugging 是循环依赖）；
   中型项目 `npx openspec --version` 可用。缺 → WORKFLOW.md 第 1 部分。

机器已是最新（路径文件在、skills 一致、无死目录）→ 一行说明，继续。

## Step 1 — 立项 brainstorm

**REQUIRED SUB-SKILL: superpowers:brainstorming。** 宣布并调用，不自由采访。已有文档/
代码先读，不问它们已回答的。必须产出（= Step 2 的槽位）：

- North Star 段四要素：谁通过这个项目得到什么（一句话）+ 可观察成功判据 + anti-scope +
  当前阶段重点
- 规模：小型（R0/R1 为主，无 OpenSpec）vs 中型（OpenSpec）
- Stack、build/test 命令、test filter flags
- heavy tests？（单测 >200MB 内存 / 外部依赖 / e2e）→ 喂 Step 3

## Step 2 — 回填（AI 起草 → 人逐行确认 → commit）

1. `CLAUDE.md` 从 toolkit 的 `templates/CLAUDE.md` 起草，North Star 段填 brainstorm 结果。
2. 中型：`npx @fission-ai/openspec@latest init` → ARCHITECTURE.md + backlog.md
   （结构：WORKFLOW.md 第 3 部分）。

无 `<placeholder>` 存活——填不出 = Step 1 没做完，回去。

**v3/v4 项目迁移**（幂等）：NORTH_STAR.md 内容并入 CLAUDE.md North Star 段后删除该文件；
`openspec/` 与既有 hooks 保留；移除 `$PROFILE` 中的 `function claude` wrapper；
删 PROTOCOL.md 与项目内 WORKFLOW.md 副本；注销 warn-apply-phase、warn-toolchain-stale
两个 hook，删 `.claude/last-toolchain-refresh`。

## Step 3 — Hooks（此时 stack 已知）

源码：toolkit 的 WORKFLOW.md 附录 G。部署到 `.claude/scripts/` + 注册进
`.claude/settings.json`。**MERGE 不覆盖**——别的工具也在里面注册 hooks：先读、再加、
再验 JSON。

部署清单（5 个）：

- `block-unsafe-test-commands`（heavy-test）：走附录 G 的 Day-1 三问填三个空位；
  「暂无重测试」是合法答案，出现时重跑本步。
- `block-replaced-skills`、`block-superpowers-specs-dir`、`warn-destructive-git`：照附录 G。
- `warn-route-before-opsx`（Tier 2，matcher Skill；先核对已装 OpenSpec 版本的命令名）：

```powershell
# warn-route-before-opsx.ps1 — Tier 2 soft warning (PreToolUse, matcher: Skill)
$json = [Console]::In.ReadToEnd() | ConvertFrom-Json
if ($json.tool_input.skill -match '^opsx:(propose|new)') {
  Write-Output "REMINDER: $($json.tool_input.skill) requires a route declaration earlier this session (change-loop: 'Route: R<n> - reason' + 'Next: ...'). None exists -> stop, invoke change-loop first."
}
exit 0
```

每个部署的脚本跑附录 G 的 echo 用例并粘贴输出——**没 echo 测过的 hook 不算部署**
（静默死掉的 hook 比没有更坏，你以为强制层存在）。

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
````

- [ ] **Step 2: 删除 toolchain-refresh**

```powershell
git rm -r skills\toolchain-refresh
```

- [ ] **Step 3: 验证**

Run: `(Get-Item skills\project-bootstrap\SKILL.md).Length; Test-Path skills\toolchain-refresh; Select-String -Path skills\project-bootstrap\SKILL.md -Pattern "Step 4 — Opus|OPUS-SYSTEM|assumeOpusDefault|Route/Explored/Mode/Next" | Measure-Object | Select-Object -ExpandProperty Count`
Expected: 长度 ≤ 5120；False；0。

- [ ] **Step 4: Commit**

```powershell
git add -A skills\; git commit -m "feat(bootstrap): rewrite as v5 four-step; remove toolchain-refresh skill"
```

---

### Task 8: value-review SKILL.md 修订

**Files:**
- Rewrite: `E:\opc_project\my-work-skill\skills\value-review\SKILL.md`

**Interfaces:**
- Consumes: Task 6 的 North Star 段（分类判据新锚点）
- Produces: retros/ 节奏锚（Task 4 §5 Close 引用之）

- [ ] **Step 1: 用以下完整内容替换 SKILL.md**

````markdown
---
name: value-review
description: Use when a long-running project shows drift — consecutive changes with no user-visible value, repeated R-revisions on the same decision, backlog priorities overturned, the main spec reads as confusing — or on cadence (every 5 archived changes or 4 weeks), or when the user asks for a mid-project review / 中期回顾.
---

# Value Review

对照 North Star 重新锚定项目、按累积现实重判架构与 backlog。产出是**交人决策的建议**
——永不自动落地。

> 本流程为压缩占位：触发表是权威，流程为最小可用版。「工程全面复盘」的深度重设计
> 是 v5 落地后的第一个独立 change。

## Triggers（任一命中）

| 信号 | 阈值 |
|---|---|
| 自嗨连击 | 连续 3 个 archive 无可观察行为变化——事后判，不看 Outcome 声称什么 |
| 决策翻烧饼 | 同一决策被 ≥2 次 R-revision，或 2 个 change 在同一 capability 上冲突 |
| backlog 被推翻 | 上次回顾以来 phase 顺序或优先级重排 |
| 节奏兜底 | `retros/`（OpenSpec 项目 `openspec/retros/`）最新文件起 ≥5 archive 或 ≥4 周——change-loop 收尾自动查，不靠记忆 |
| 人的直觉 | 「看不懂主 spec」/ 对方向不安 |

## Procedure（压缩版）

1. **核销上轮承诺先行**。打开上一份 retro：每个承诺解锁 user-value 的 enabling change，
   价值落了吗？未兑现的领衔 findings。首轮（`retros/` 无文件）跳过本步。
2. **North Star 检查**。读项目 CLAUDE.md 的 North Star 段。还成立吗？失真 → 停：
   重锚定是人的决策，它定下来之前其余都不重要。
3. **逐 change 一行分类**。对上次回顾以来每个 change：*用户得到了什么？*按 North Star
   段的三分类判：user-value / enabling / self-indulgence。enabling 的标准不是「理论上
   解锁」而是「承诺的价值落了没」——所以第 1 步先跑。
4. **写了就停**。产出 `retros/<date>-value-review.md`（OpenSpec 项目放
   `openspec/retros/`）：findings + 每条建议标 [keep] / [change] / [kill] / [decide]，
   呈交人。批准后才走 R-revision / ARCHITECTURE 更新 / backlog 修改——批准前零落地。

## Common mistakes

- **自动落地结论**：架构与价值方向是语义级决策——永远人 gate。
- **数吞吐不看结果**：「archive 了 12 个 change」不是 finding；用户得到了什么才是。
- **enabling 一律放行**：检验是「承诺的价值落了没」，不是「理论上有用」。
````

- [ ] **Step 2: 验证**

Run: `Select-String -Path skills\value-review\SKILL.md -Pattern "NORTH_STAR\.md|Review Log" | Measure-Object | Select-Object -ExpandProperty Count`
Expected: 0

- [ ] **Step 3: Commit**

```powershell
git add skills\value-review\SKILL.md; git commit -m "feat(value-review): re-anchor to CLAUDE.md North Star section and retros/ cadence; compress procedure"
```

---

### Task 9: 全仓库陈旧锚点交叉检查

**Files:**
- Verify only（发现问题才修改对应文件）

- [ ] **Step 1: 陈旧锚点扫描**

```powershell
Select-String -Path GUIDE.md,README.md,templates\*.md,skills\*\*.md -Pattern "NORTH_STAR"
Select-String -Path GUIDE.md,README.md,templates\*.md,skills\*\*.md -Pattern "OPUS|wrapper|assumeOpus"
Select-String -Path GUIDE.md,README.md,templates\*.md,skills\*\*.md -Pattern "toolchain-refresh"
Select-String -Path GUIDE.md,README.md,templates\*.md,skills\*\*.md -Pattern "Explored:|tripwire|recitation|40%"
```

Expected 白名单（此外的任何命中都是缺陷，修掉再重跑）：
- `NORTH_STAR`：仅 project-bootstrap 迁移段（「NORTH_STAR.md 内容并入…后删除」）+ GUIDE §5 对照表 v4 列。
- `OPUS|wrapper`：仅 project-bootstrap 迁移段（移除 wrapper）+ GUIDE §3/§5 表格 v4 列。
- `toolchain-refresh`：仅 project-bootstrap Step 0（死副本删除）与迁移段 + GUIDE §5 表格 v4 列。
- 第四条：仅 GUIDE §5 对照表 v4 列。

- [ ] **Step 2: 尺寸总核对**

```powershell
Get-ChildItem GUIDE.md,README.md,templates\CLAUDE.md,skills\change-loop\SKILL.md,skills\change-loop\dispatch-prompt.md,skills\project-bootstrap\SKILL.md,skills\value-review\SKILL.md | Select-Object Name,Length
```

Expected: 全部符合 Global Constraints 尺寸表。

- [ ] **Step 3: 如有修改则 commit**

```powershell
git add -A; git commit -m "fix: purge stale anchors found in cross-check"
```

（无修改则跳过。）

---

### Task 10: kb_deposit 沉淀（两条）

**Files:** 无（MCP 调用）

- [ ] **Step 1: 加载 kb_deposit 工具**

ToolSearch: `select:mcp__kb__kb_deposit`

- [ ] **Step 2: 沉淀「融合决策记录」**

内容 = GUIDE.md §3 的完整表格 + 一段导语：「my-work-skill 工作流的外部方案融合决策
（截至 v5，2026-08）。每条含拒绝/采纳理由，防止重复调研。权威版在
my-work-skill/GUIDE.md §3，更新以彼为准。」

- [ ] **Step 3: 沉淀「v5 减法重构决策」**

内容要点：动机（frontier class 能力跃升 + 官方 too-prescriptive 警告）；方法（43 环节
使用投票 + 官方文档交叉验证 + ablation 台账）；核心结论（契约内核 = 两家官方保留清单
交集；人审 gate 诚实化为 brainstorm + 真机验收；提示层做减法、harness 层按误伤率；
模型下限 Opus 5 不做特调；单层扁平扇出禁孙 agent——web 抓取类必降 Sonnet）；
指针：spec = my-work-skill/docs/specs/2026-08-14-v5-subtraction-design.md，
证据 = FIELD-LOG.md 2026-08-14 条目。

- [ ] **Step 4: 验证**

两次 kb_deposit 返回成功；无需 commit（知识库在 E:\knowledge，不在本仓库）。

---

### Task 11: 部署到本机 + 终验

**Files:**
- 机器级：`~/.claude/skills/`（本仓库外）

- [ ] **Step 1: 部署**

```powershell
$dst = "$HOME\.claude\skills"
"change-loop","project-bootstrap","value-review" | ForEach-Object {
  Copy-Item -Recurse -Force "E:\opc_project\my-work-skill\skills\$_" $dst
}
if (Test-Path "$dst\toolchain-refresh") { Remove-Item -Recurse -Force "$dst\toolchain-refresh" -Confirm:$false }
```

- [ ] **Step 2: 终验**

```powershell
Get-ChildItem "$HOME\.claude\skills" | Select-Object Name
Get-Content "$HOME\.claude\skills\change-loop\SKILL.md" -TotalCount 3
Test-Path "$HOME\.claude\skills\toolchain-refresh"
```

Expected: 三个 toolkit skill 在列（机器上其他非 toolkit skill 不动）；change-loop 头三行是 v5 frontmatter（description 含 "North Star section"）；False。

- [ ] **Step 3: 汇报**

向用户汇报：全部 task 的 commit 列表、终验输出、以及下一步（在下个真实项目跑 GREEN 观察，结果回填 FIELD-LOG ablation 台账）。
