---
name: change-loop
description: Use when starting any development change — feature, bugfix, refactor, or the first change after project bootstrap / 立项 — in a project using this workflow (the project CLAUDE.md has a North Star section or mandates route declaration). Invoke BEFORE any opsx command (propose/apply), spec writing, solution brainstorming, or code; also when picking an item from backlog.md, and when resuming an in-progress change after a session break or context compaction.
---

# Change Loop

每个 change 是一个有契约、有预算、明确出口的循环。人工触点两个：spec 前的 brainstorm
问答、收尾的真机验收；gate 之间由 AI 自治。循环体：**每迭代恰好一个 task，绿进绿出，
逐 task commit。**

## 1. Route（任何 spec / opsx 命令 / 代码之前）

先查回顾触发（value-review 的 description 列有触发词；命中即先回顾再路由）。然后按
novelty × reversibility × blast radius 判断，声明三行：

```
Route: R<0-3> — <一行理由>
主线: 第 N 步 <change-id> | 第 N 步前置（只读测量 / enabling） | 支线（来源：dry-run / 修复 / 评审 / 回顾）
Next: <brainstorm | SPEC-lite | opsx propose | test>
```

不在 backlog 主线段里的 change 一律是支线；主线段只在 route check / project review 批准后
或人直接指示时增删，Close 只打勾。

- **R0 直行**：一次 commit 可逆、无 spec/架构/数据契约影响、≤1 小时 → 测试→代码→commit。
  开工前一句说明 verify 命令与期望，commit 前展示输出。R0 免 gate、不写 backlog、不计数。
- **R1 轻量**：意图 2–3 句说得清、单 capability、无新架构决策/外部依赖 → SPEC-lite。
- **R2 标准**：新 capability、跨模块、或新外部依赖 → OpenSpec propose 四件套；
  spec critic 修完后经人批准进循环。
- **R3 架构**：动 ARCHITECTURE 决策、数据契约或 North Star 边界 → 先与人定方向再走 R2。

三条规则：**没读过要动的代码不路由**——爆炸半径在代码里，先只读 explore 再声明；对既有
代码的假设靠读取验证，不靠回忆。**默认先 brainstorm**（superpowers:brainstorming）——
仅当已有具体证据工件（bug 复现/verify 输出/评审发现）或用户明说跳过时直接写 spec，
跳过前 ≤3 句复述意图与边界。**拿不准取高一级**；中途升级要声明，静默降级禁止。

## 2. Loop Contract（R1+，写进 tasks.md 或 SPEC-lite 头部）

```markdown
## Loop Contract
- Outcome: <一句用户可见词汇——用户得到什么>
- Verify: <具名命令 + 期望输出。"测试通过"四个字无效>
- Budget: <max 天数>；每 task 最多 5 次迭代
- Exit: DONE（Verify 全绿 + Outcome 落地；gate 未由 fresh-context 跑 → DONE-ungated）
      | BLOCKED（blockers 附后，升级给人）| SPLIT（超预算或发现复合任务 → 提拆分方案）
```

Outcome 只能用实现词汇写出（重构/统一/抽象/覆盖率）→ 这是 enabling 工作：指名它解锁的
主线步与落地时点（≤2 个 change）；指不出 → 不开工，记 backlog 支线一行（触发：它解锁的
主线步），下次 route check 审。

R1 SPEC-lite（Goal/Non-goals/Scenarios/Loop Contract 单文件）位置：OpenSpec 项目
`openspec/changes/<change-id>/spec-lite.md`；其他项目根目录 `SPEC.md`，收尾移入
`docs/changes/`。根目录 `SPEC.md` 属于**一个 change**、不属于项目——项目常设设计文档叫
`DESIGN.md`。

**Spec 自检（成文后、进循环前）**：派 fresh-context spec critic（dispatch-prompt.md
「Spec critic」变体）——R1 一个（只做清单第 2、5 条）/ R2 critic + 「假设对照代码」视角分开派 /
R3 再加 skeptic。顺序：critic → 修 [blocking] → R2+ 把 critic 冲突项与「最不放心的 3 处」
并列交人批准 → 进循环。critic 派不出去 → 契约头部记 `Critic: 未跑（原因）`。发现 ≠ 新
change：范围内改 spec，超范围进 backlog 支线一行。

## 3. 内环（自治）

每 task：读 scenario → 有运行时行为先写失败测试 → 最小实现 → 绿 → 自审 diff → commit →
下一个。task 之间不请示，只报进度。

- **只在绿提交**；最后一个绿 commit 是回退锚点（新仓库先跑绿测试骨架并提交立锚）。
  坏树收尾：`git reset --hard` 回锚点 → 失败注记（task id + tried/observed/hypothesis）
  append 进契约 → 立即 docs-commit（注记因此跨越未来 reset）→ 换思路或 BLOCKED。
  fix-forward 仅限迭代内；不从红树开新 task。
- **每次失败尝试都记注记**（不止坏树的）：注记就是尝试计数器——对话记忆不跨 compaction，
  文件跨。
- **Stuck 判据（任一命中即停止换说法重试）**：空 diff 迭代；同一错误签名连续 2 次；
  修 A 坏 B 坏 A 往返一圈。命中（或 5 次上限）→ 写注记 → superpowers:systematic-debugging。
  诊断 = 复合任务 → 拆分（spec 范围内自治改 tasks.md 继续；动 spec/范围/预算 = change 级
  SPLIT，停下交人）；其余未解 → BLOCKED。计划与现实脱节 → 从 spec 重生成剩余 tasks，
  不逐行补丁。
- 语义模糊（需求含义/边界/设计意图）停下问人；实现模糊自选合理项并注记一行。

## 4. Subagents（单层扁平扇出）

subagent 看不到你的任何上下文：项目硬规则、测试命令纪律、本 change 契约，按本目录
`dispatch-prompt.md` 的槽位**逐字重述**，每次都是。**禁止 subagent 再派 agent。**
高噪音工作（全量测试日志、构建考古）隔离到 subagent，只回 ≤2k token 摘要。

派 reviewer / critic / 隔离 subagent 是**常设授权**（项目 CLAUDE.md Hard Rules）——不请示、
不等批准；harness 对多 agent 编排（Workflow）的 opt-in 不适用于单个 subagent。派不出去 →
报原因、标 ungated；**不在本会话 inline 替代：R1+ 的 gate 定义是 fresh-context，inline 自检不是 gate。**

gate 评审用 fresh-context reviewer（只给 diff + spec + 标准，不给产生代码的推理过程），
按路由分级：R0 免 gate（自审 diff）/ R1 单 reviewer / R2 双视角（spec 合规 + 代码质量）/
R3 三视角（+ skeptic）+ 人。发现分诊：[blocking] = 违反 spec/契约，或真实缺陷
（正确性/资源泄漏/数据丢失/安全）——必修；[nit] = 风格与「可以更好」——记录不追。

## 5. Close（证据 gate，R1+）

- 每条 Verify 命令的真实输出粘贴（不概述、不「应该过」）。
- Outcome 一行：用户可见的东西落地了吗。
- `Gate: critic 跑了（n）| 没跑（原因）；reviewer 跑了（n / 视角）| 没跑（原因）`——任一没跑，
  出口态只能写 **DONE-ungated**。
- `主线: 推进第 N 步 | 第 N 步前置 | 支线（原因）`——与路由声明一致，改了要说明。
- 出口态声明：DONE / DONE-ungated / BLOCKED / SPLIT；跳过或合并的环节（如 `/opsx:verify`
  工件核查、code-simplifier polish，皆为 judgment call）明说并给理由。
- Archive。OpenSpec 项目：`openspec archive <change-id> -y`（delta 自动合入主 spec，首次归档
  自动建主 spec）→ 主 spec `## Architectural Decisions` 追加本 change 决策，每条带
  *Source: change `<id>` (archived <date>)*，被推翻的旧决策不删、改写为 *Superseded by <new>,
  see change `<new-id>`* → `openspec validate --specs` 0 失败、`openspec list` 无 active change
  （不加 `--strict`）。非 OpenSpec 项目：根 `SPEC.md` 移入 `docs/changes/<id>.md`。Close 内容
  与读数留在归档；对已归档 change 的订正追加到归档文件（OpenSpec 归档目录：proposal.md，R1 为
  spec-lite.md）末尾 `## Errata`，不写 backlog。
- 更新 backlog.md：主线步出口态 DONE 才打勾（DONE-ungated 补跑 gate 后打勾；SPLIT 子 change
  全 DONE 打勾）；支线完成即删该行（归档与 git 有）。Now 覆盖前先读旧 Now——悬而未决只能
  核销或结转（欠的 gate 在此），不能消失；支线计数：主线推进或 route check 后清零，支线
  archive +1，前置探针不计。

## 6. Session 边界（land the plane）

task 组结束、任何 gate、harness 警告上下文时收工：更新 tasks.md 与契约状态；next-session
brief 写进 backlog.md Now 段（整段覆盖：主线位置写成 `第 k/M 步 · <change-id> task i/n`，
下一步、悬而未决），change 内部注记留在 change CLAUDE.md。文件携带状态，不靠对话。

恢复：`git status` 先行——未提交改动 = 中断迭代：注记能说清就收完该迭代，否则 reset
回锚点。再读契约 + tasks.md + backlog Now，≤2 行报告，直接继续——只在 gate 或阻塞时问。
