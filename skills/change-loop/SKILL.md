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
