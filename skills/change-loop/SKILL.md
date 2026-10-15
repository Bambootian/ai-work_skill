---
name: change-loop
description: Use when starting any development change — feature, bugfix, refactor, or the first change after project bootstrap / 立项 — in a project using this workflow (the project CLAUDE.md has a North Star section or mandates route declaration). Invoke BEFORE any opsx command (propose/apply), spec writing, solution brainstorming, or code; also when picking an item from backlog.md, when the mainline is waiting on an external event (waiting-period work), and when resuming an in-progress change after a session break or context compaction.
---

# Change Loop

每个 change 是一个有契约、有预算、明确出口的循环。人是船长：只定方向、钱、时间、找谁；
其余由你决定并推进，决定在里程碑汇总里给人否决。循环体：绿进绿出，逐 task commit。

## 1. Route（任何 spec / opsx 命令 / 代码之前）

先查回顾触发（value-review 的 description；读最近一份汇总 ⑤ 的信号行）。读过要动的代码再路由——爆炸半径在代码里。
按 novelty × reversibility × blast radius 声明两行：

```
Route: R<0-3> — <一行理由>
主线: 第 N 步 <change-id> | 第 N 步前置（只读测量 / enabling） | 支线（来源）| 等待期活
```

- **R0 直行**：可逆、无 spec / 架构 / 数据契约影响 → 开工前一句 verify 命令与期望，自审 diff，
  commit 前展示输出。免 gate、不写 backlog。
- **R1 轻量**：单 capability、无新架构决策 / 外部依赖 → 最小产物 = Loop Contract + Goal / Non-goals
  各一句，Scenarios 按需。非 OpenSpec：根 `SPEC.md` 一个文件（收尾移入 `docs/changes/`）；OpenSpec：
  `openspec/changes/<id>/spec-lite.md` + `tasks.md`，`.openspec.yaml` 写 `schema: lite` + `skip_specs: true`
  （lite schema 由 bootstrap 建）。
- **R2 标准**：新 capability、跨模块或新外部依赖 → OpenSpec propose 四件套；critic 按内容判定后
  进循环，不等人批准。
- **R3 方向**：动 North Star、板块终态 / 判据、主线段，或花费超项目参数 → 方向交人定；反方是否先派按
  value-review 触发表（大投入前 / 机械信号，同一板块 ≤1 轮），派了就把并排表一起交人；再走 R2。
  只动 ARCHITECTURE 决策或数据契约不是 R3：按 R2 走，你定并写失效前提，Spec 自检该跑的信号已含它。

不在 backlog 主线段里的 change 一律支线。板块、终态、判据、主线段增删归人；板块内步骤的拆分、
排序、插入由你做，写在 `主线:` 行并列入汇总。拿不准取高一级；中途升级要声明。brainstorm 只在
立项与 R3。spec 只写契约（接口 / 数据格式 / 预登记口径 / 红线）与 scenarios，过程进 commit 与归档。
路由时用本 change 要动的路径、模块名、主线步、change-id grep backlog 支线与 `docs/watchlist.md`，
命中的条目列一行；没命中不写。

## 2. Loop Contract（R1+，写进 tasks.md 头部；无 tasks.md 的非 OpenSpec R1 写 SPEC.md 头部）

```markdown
## Loop Contract
- Outcome: <做完后谁能观察到什么不同——操作者还是 North Star 用户，注明；不用代号>
- Verify: <具名命令 + 期望输出。"测试通过"四个字无效>
- Budget: <max 天数>
- Exit: DONE（Verify 全绿 + Outcome 落地；底线 gate 没跑 → DONE-ungated）
      | BLOCKED（blockers 附后，升级给人）| SPLIT（超预算或复合任务 → 提拆分方案）
- Decided（可选）: <你替人定的事，一句一条，≤5；难撤回（改数据契约 / 改配置身份使历史读数失效 /
  已外发 / 已花钱）标 ⚠；超过 5 条 = SPLIT 信号>
```

**问人只有四类**：方向（需求意图与边界、North Star、板块终态 / 判据、主线段）、钱（超项目参数的花费、
新付费渠道首次）、时间（排期、预算延长）、找谁 / 对外不可逆（外发、公开、删数据）。其余你定并记
`Decided:`；答案取决于真跑结果的题，先用默认值跑完再定。

**Spec 自检**（成文后、进循环前）：跑不跑、派几个视角按内容判定，契约头写
`Critic: <视角 | 免> — <理由>`，工具是 fresh-context spec critic（`dispatch-prompt.md`）。该跑的信号：
新数据契约或架构决策、预登记口径、要花真钱真跑；可免：只动文档或产物整理；免跑理由必须指出具体信号。
[blocking] 修完进循环；冲突项与「最不放心处」由你裁定并记 `Decided:`。发现 ≠ 新 change：范围内改
spec，超范围进 backlog 支线一行。

## 3. 内环（自治）

每 task：读 scenario → 实现（有运行时行为的改动配相称的测试，顺序不规定）→ 绿 → 自审 diff →
commit → 下一个。task 之间不请示，只报进度。

- **只在绿提交**；最后一个绿 commit 是回退锚点（新仓库先跑绿测试骨架并提交立锚）。坏树收尾：
  `git reset --hard` 回锚点 → 失败注记（task id + tried / observed / hypothesis）append 进契约 →
  立即 docs-commit（注记因此跨越未来 reset）→ 换思路或 BLOCKED。fix-forward 仅限迭代内。
- **每次失败尝试都记注记**：对话记忆不跨 compaction，文件跨。同一错误重复出现即换思路或
  BLOCKED，不换说法重试；诊断出复合任务 → 拆分（spec 范围内自治改 tasks.md；动 spec / 范围 /
  预算 = SPLIT，停下交人）。
- 订正与无所属 change 的技术决定：追加到相关归档末尾或 `docs/notes/` 一行，不进 backlog / decisions。

## 4. Subagents（单层扁平扇出）

subagent 看不到你的任何上下文：项目硬规则、测试命令纪律、本 change 契约，按本目录
`dispatch-prompt.md` 的槽位**逐字重述**，每次都是。**禁止 subagent 再派 agent。**
高噪音工作（全量测试日志、构建考古）隔离到 subagent，只回 ≤2k token 摘要。
派 reviewer / critic / 方向反方 / 隔离 subagent 是常设授权（项目 CLAUDE.md Hard Rules）——不请示；
派不出去 → 报原因、标 ungated，**不在本会话 inline 替代：gate 的定义是 fresh-context**。

gate 评审用 fresh-context reviewer（只给 diff + spec + 标准，不给产生代码的推理过程）。跑不跑、
几个视角按内容判定，契约头 `Critic:` 下一行写 `Gate: <视角 | 免> — <理由>`。**底线**：动产品代码
（非一次性脚本）、数据契约或 ARCHITECTURE 的 R1+ change 至少一个 reviewer；增量 gate 默认免，修复
引入新逻辑或新数据路径才跑；免跑理由同 Spec 自检：指出具体信号。[blocking] = 违反 spec / 契约，或真实缺陷（正确性 / 资源泄漏 / 数据丢失 /
安全）——必修；[nit] 记录不追。多 reviewer 结论冲突由你裁定并记 `Decided:`；属四类的交人。

## 5. Close（证据 gate，R1+）

- 每条 Verify 命令的真实输出粘贴（不概述、不「应该过」）；Outcome 一行：谁能观察到什么落地了。
- `Gate: critic 跑了（n / 视角）| 免（理由）| 没跑（原因）；reviewer 同`——底线 gate 没跑，出口态
  只能写 **DONE-ungated**；按判定免跑的不降级。出口态：DONE / DONE-ungated / BLOCKED / SPLIT。
- Archive。OpenSpec：`openspec archive <change-id> -y` → 主 spec `## Architectural Decisions` 追加本
  change 的决策并注明来源 change，被推翻的旧决策改写为 Superseded → `openspec validate --specs`
  （不加 `--strict`）0 失败、`openspec list` 无 active。非 OpenSpec：根 `SPEC.md` 移入
  `docs/changes/<id>.md`。Close 内容与读数留在归档。
- 更新 backlog.md：主线步 DONE 才打勾（DONE-ungated 补跑 gate 后打勾）；支线完成即删行；Now 整段
  覆盖，覆盖前先读旧 Now，悬而未决只能核销或结转。留给未来的条件优先写到它会被读到的地方（要动的
  文件头 / Verify 断言 / spec Requirement 下一行），放不下才进 `docs/watchlist.md` 并带触发；写前 grep 旧条目，重复 / 矛盾则合并。

## 6. Session 边界（land the plane）

task 组结束或任何 gate 后收工：更新 tasks.md 与契约状态；next-session brief 写进 backlog.md Now
（整段覆盖：主线位置 `第 k/M 步 · <change-id> task i/n`、下一步、悬而未决）。文件携带状态，不靠对话。
恢复：`git status` 先行——未提交改动 = 中断迭代：注记能说清就收完该迭代，否则 reset 回锚点；
再读契约 + tasks.md + Now，≤2 行报告，直接继续。

**等待期**：Now 下一步为「等 <外部事件>」且无可路由主线步时不停机：做只读或只写隔离区
（`docs/notes/`、项目 CLAUDE.md Stack 声明的探针目录、独立 worktree）的活——探针 / 测量 / 裸模型对照
（不花钱，或按项目参数）、热存储到期审（只产清单，移出在里程碑汇总时执行）、`工具包:` 候选行。产物与
候选行写 `docs/notes/<date>-waiting.md`；Now 只改「等待期活」那一句，其余主线文件、共享数据、热文档不碰；
做完进下次里程碑汇总，不单独报告。
