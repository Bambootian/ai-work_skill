---
name: change-loop
description: Use when starting any development change — feature, bugfix, refactor, or the first change after project bootstrap / 立项 — in a project using this workflow (the project CLAUDE.md has a North Star section or mandates route declaration). Invoke BEFORE any spec writing, solution brainstorming, or code; also when picking an item from backlog.md, when the mainline is waiting on an external event (waiting-period work), and when resuming an in-progress change after a session break or context compaction.
---

# Change Loop

每个 change 是一个有契约、有预算、明确出口的循环。人是船长：只定方向、钱、时间、找谁；
其余由你决定并推进，决定在里程碑汇总里给人否决。循环体：绿进绿出，逐 task commit。

## 1. Route（任何 spec / 代码之前）

先查回顾触发（value-review 的 description；读最近一份汇总 ⑤ 的信号行）。读过要动的代码与对应的能力主 spec
（`<specs dir>/<cap>/spec.md`，按 Requirement 名 / Decision ID 定位）再路由——爆炸半径在代码里。
按 novelty × reversibility × blast radius 声明两行，写在 change 文件头部：

```
Route: R<0-3> — <一行理由>
主线: 第 N 步 <change-id> | 第 N 步前置（只读测量 / enabling） | 支线（来源）| 等待期活
```

- **R0 直行**：可逆、无 spec / 架构 / 数据契约影响 → 开工前一句 verify 命令与期望，自审 diff，
  commit 前展示输出。免 gate、不建文件、不写 backlog。
- **R1 轻量**：单 capability、无新架构决策 / 外部依赖。
- **R2 标准**：新 capability、跨模块或新外部依赖；critic 按内容判定后进循环，不等人批准。
- **R3 方向**：动 North Star、板块终态 / 判据、主线段，或花费超项目参数 → 方向交人定；反方是否先派按
  value-review 触发表（大投入前 / 机械信号，同一板块 ≤1 轮），派了就把并排表一起交人；再按 R2 走。
  只动 ARCHITECTURE 决策或数据契约不是 R3：按 R2 走，你定并写失效前提，Spec 自检该跑的信号已含它。

**R1+ 的产物同一个形状：一个 change 一个文件**（`templates/change.md`，目录可放旁文件）。有能力主 spec 的项目：
`<changes dir>/<id>/change.md`（既有项目 `openspec/changes/`，新项目 `docs/changes/`），契约改动直接改主 spec（§2）；
无主 spec 的小项目：根 `SPEC.md`，收尾移入 `docs/changes/<id>.md`。文件头部第三行记 `BASE: <当时 HEAD 短 hash>`——
critic / gate / WITHDRAWN / 归档后复原都以它为 diff 基线；路由两行与 Loop Contract 成文即 docs-commit。

不在 backlog 主线段里的 change 一律支线。板块、终态、判据、主线段增删归人；板块内步骤的拆分、排序、插入由你做，
写在 `主线:` 行并列入汇总。任何时候觉得当前步在白做或主线错了，当场一行说出来，不必等回顾。拿不准取高一级；
中途升级要声明。brainstorm 只在立项与 R3。路由时用本 change 要动的路径、模块名、主线步、change-id grep backlog
支线与 `docs/watchlist.md`，命中的条目列一行；没命中不写。

## 2. 契约（R1+）

**Loop Contract 写在 change 文件头部**（接口：`## Loop Contract` / `## Tasks` / `## Close` 三个段名与 `Decided:` 行；
其余段按模板，可增删）：

```markdown
## Loop Contract
- Outcome: <做完后谁能观察到什么不同——操作者还是 North Star 用户，注明；不用代号>
- Verify: <具名命令 + 期望输出。"测试通过"四个字无效>
- Budget: <max 天数>
- Exit: DONE（Verify 全绿 + Outcome 落地；底线 gate 没跑 → DONE-ungated）
      | BLOCKED（blockers 附后，升级给人）| SPLIT（超预算或复合任务 → 提拆分方案）
- Decided: <可选；你替人定的事，一句一条，≤5；难撤回（改数据契约 / 改配置身份使历史读数失效 /
  已外发 / 已花钱）标 ⚠；超过 5 条 = SPLIT 信号>
```

**能力契约就地改**：spec 只写契约（接口 / 数据格式 / 预登记口径 / 红线）与 WHEN/THEN scenario，过程进 commit 与归档。
动契约的 change 直接改 `<specs dir>/<cap>/spec.md` 的 Requirement / Scenario；新能力新建 spec.md（四段骨架见
project-bootstrap Step 2，Purpose 不留占位）。决策写进 Architectural Decisions：为什么 + **Fails when** + `*Source: change <id> (<date>)*`，
只写一次；被推翻的旧决策首行改 `*Superseded by <ID>, see change <id>*`。change 文件的「Spec 改动」只列清单（一行一条），差异就是
git diff：`git diff <BASE> -- <清单里的 spec 文件>`，BASE 读 change 文件头部那一行。在途期主 spec 写的是意图：在途 change 由
`ls <changes dir>/*/change.md` 列出，其「Spec 改动」就是在途 Requirement；并行 change 必须各占一个 worktree，否则同分支
就地改是静默覆盖。小项目（无主 spec）：「Spec 改动」写「无」，Decisions 不打 ★，Close ②⑤ 跳过；归档与下一次路由不同一 commit。

**问人只有四类**：方向（需求意图与边界、North Star、板块终态 / 判据、主线段）、钱（超项目参数的花费、新付费渠道首次）、
时间（排期、预算延长）、找谁 / 对外不可逆（外发、公开、删数据）。其余你定并记 `Decided:`；答案取决于真跑结果的题，
先用默认值跑完再定。

**Spec 自检**（成文后、进循环前）：跑不跑、派几个视角按内容判定，契约头写 `Critic: <视角 | 免> — <理由>`，工具是
fresh-context spec critic（`dispatch-prompt.md`），输入 = change 文件 + 上面那条 spec diff + 代码只读。该跑的信号：
新数据契约或架构决策、预登记口径、要花真钱真跑；可免：只动文档或产物整理；免跑理由必须指出具体信号。[blocking]
修完进循环；冲突项与「最不放心处」由你裁定并记 `Decided:`。发现 ≠ 新 change：范围内改 spec，超范围进 backlog 支线一行。

## 3. 内环（自治）

每 task：读 scenario → 实现（有运行时行为的改动配相称的测试，顺序不规定）→ 绿 → 自审 diff → commit → 勾 change 文件
的 Tasks → 下一个。task 之间不请示，只报进度。

- **只在绿提交**；最后一个绿 commit 是回退锚点。坏树收尾：`git reset --hard` 回锚点 → 失败注记（task id + tried /
  observed / hypothesis）append 进 change 文件「注记」→ 立即 docs-commit → 换思路或 BLOCKED。fix-forward 仅限迭代内。
- **每次失败尝试都记注记**：对话记忆不跨 compaction，文件跨。同一错误重复出现即换思路或 BLOCKED，不换说法重试；
  诊断出复合任务 → 拆分（spec 范围内自治改 Tasks；动 spec / 范围 / 预算 = SPLIT，停下交人；子 change 抄父的 BASE 行、继承「Spec 改动」行，Source 保留父 id）。
- 订正与无所属 change 的技术决定：追加到相关归档末尾或 `docs/notes/` 一行，不进 backlog / decisions。

## 4. Subagents（单层扁平扇出）

subagent 看不到你的任何上下文：项目硬规则、测试命令纪律、本 change 契约，按本目录 `dispatch-prompt.md` 的槽位
**逐字重述**，每次都是。**禁止 subagent 再派 agent。** 高噪音工作（全量测试日志、构建考古）隔离到 subagent，只回
≤2k token 摘要。派 reviewer / critic / 方向反方 / 隔离 subagent 是常设授权（项目 CLAUDE.md Hard Rules）——不请示；
派不出去 → 报原因、标 ungated，**不在本会话 inline 替代：gate 的定义是 fresh-context**。

gate 评审用 fresh-context reviewer（只给代码 diff + change 文件 + 同一条 spec diff + 标准，不给产生代码的推理过程——
就地删掉的 scenario 是 diff 里的 `-` 行，要有人看）。跑不跑、几个视角按内容判定，契约头 `Critic:` 下一行写
`Gate: <视角 | 免> — <理由>`。**底线**：动产品代码（非一次性脚本）、数据契约或 ARCHITECTURE 的 R1+ change 至少一个
reviewer；增量 gate 默认免，修复引入新逻辑或新数据路径才跑；免跑理由同 Spec 自检：指出具体信号。[blocking] = 违反
spec / 契约，或真实缺陷（正确性 / 资源泄漏 / 数据丢失 / 安全）——必修；[nit] 记录不追。多 reviewer 结论冲突由你裁定
并记 `Decided:`；属四类的交人。

## 5. Close（证据 gate，R1+；五步一个 commit `archive(<id>): …`）

① Close 段 append：每条 Verify 命令的真实输出（不概述、不「应该过」）、Outcome 一行、`Gate: critic 跑了（n / 视角）|
免（理由）| 没跑（原因）；reviewer 同`、Decided 聚合、出口态 DONE / DONE-ungated / BLOCKED / SPLIT（底线 gate 没跑只能
DONE-ungated；按判定免跑的不降级）。
② 核主 spec：本 change 的决策都带 Source、被推翻的已 Superseded、新 spec 的 Purpose 非占位。
③ 归档（DONE / DONE-ungated / SPLIT 父 / WITHDRAWN；**BLOCKED 不归档**，留在 `<changes dir>` 就是在途标记）：`git add` 旁文件
→ `git mv <changes dir>/<id> <changes dir>/archive/<date>-<id>` → `git add <changes dir>/archive/<date>-<id>`（Close 段也进
commit）→ `test ! -d <changes dir>/<id>`；小项目 `SPEC.md` 移入 `docs/changes/<id>.md`。WITHDRAWN：先 `git log --oneline
<BASE>.. -- <spec 文件>` 确认只有本 change 的 commit，再 `git diff <BASE> -- <spec 文件> | git apply -R`；有别人的 commit 则
`git checkout -p` 逐 hunk 撤；change 文件写 WITHDRAWN 段后归档。
④ backlog：主线步 DONE 才打勾（DONE-ungated 补跑 gate 后打勾）；支线完成即删行；Now 整段覆盖，覆盖前先读旧 Now，悬而
未决只能核销或结转。留给未来的条件优先写到它会被读到的地方（要动的文件头 / Verify 断言 / spec Requirement 下一行），
放不下才进 `docs/watchlist.md` 并带触发；写前 grep 旧条目，重复 / 矛盾则合并。
⑤ 可选 lint：`grep -L '#### Scenario' <specs dir>/*/spec.md` 应为空。
归档后复原本 change 改了哪些契约：`git diff <BASE>..<archive commit> -- <清单文件>`（BASE 读归档 change.md 头部）。

## 6. Session 边界（land the plane）

task 组结束或任何 gate 后收工：更新 change 文件（Tasks、注记）；next-session brief 写进 backlog.md Now（整段覆盖：
主线位置 `第 k/M 步 · <change-id> task i/n`、下一步、悬而未决）。文件携带状态，不靠对话。
恢复：`git status` 先行——未提交改动 = 中断迭代：注记能说清就收完该迭代，否则 reset 回锚点；再读 change 文件 + Now，
≤2 行报告，直接继续。

**等待期**：Now 下一步为「等 <外部事件>」且无可路由主线步时不停机：做只读或只写隔离区（`docs/notes/`、项目 CLAUDE.md
Stack 声明的探针目录、独立 worktree）的活——探针 / 测量 / 裸模型对照（不花钱，或按项目参数）、热存储到期审（只产清单，
移出在里程碑汇总时执行）、`工具包:` 候选行。产物与候选行写 `docs/notes/<date>-waiting.md`；Now 只改「等待期活」那一句，
其余主线文件、共享数据、热文档（含在途 change 改过的主 spec 段）不碰；做完进下次里程碑汇总，不单独报告。
