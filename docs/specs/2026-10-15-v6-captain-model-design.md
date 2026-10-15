# v6.0 船长模型设计（人机分工翻转 · 里程碑汇总 · 方向反方 · 热存储到期 · 过程约束减法）

> 2026-10-15。本文是 v6 实现的唯一契约；实现与本文冲突时先改本文。
> 证据：`docs/evidence/2026-10-14-workflow-review/README.md`（回顾记录，四态标记）、同目录
> `2026-10-15-v6-proposal-adversary-panel.md`（草案 → 3 个设计视角 + 3 个反方 → 修订，含并排表与理由）、
> FIELD-LOG 2026-10-14 / 2026-10-15 条。本文只写定稿，不重复论证。

## 1. 用户裁定（设计约束）

2026-10-14（八条，原话见 README §5）：① 判不了的技术题全部交 AI，只问钱、时间、方向、找谁，常设偏好
定一次；② 只在里程碑给一份汇总；③ 热存储有上限、冷存储随便长，条目到期 AI 先逐条审再移出、汇总列出；
④ 大幅精简流程，约束结果和红线不约束过程，守住契约记忆；⑤ 方向层反方：大投入前 + 机械信号触发，反方
要点与 AI 反驳并排书面给人；⑥ 资源限制是项目参数不是工作流常量；⑦ 等待期 AI 自主做只读或隔离写的活；
⑧ 多 change 并行要做但不急着定。

2026-10-15（四条）：A 人工触点收缩为「立项 brainstorm（只确认 North Star 与主线）」+「方向态 change 先定
方向」，R2 spec 人批准与每 change brainstorm 取消（改 09-27 裁定）；B 「最不满意」一问移到汇总末行必填，
判决先写（改 09-11 裁定）；C 热存储沿用 10-14 定义，decisions 只收四类、watch 优先就地放置、到期删行；
D 先迁 new_review_create 跑一个里程碑再迁其余四个。

## 2. 设计

### 2.1 人机分工（change-loop、模板 CLAUDE.md、value-review）
- 问人只有四类：方向（需求意图与边界、North Star、板块终态 / 判据、主线段增删）、钱（超项目参数、新付费
  渠道首次）、时间（排期、预算延长）、找谁 / 对外不可逆（外发、公开、删数据）。其余 AI 自决，写进 Loop
  Contract 可选行 `Decided:`（≤5 条；难撤回 = 改数据契约 / 改配置身份使历史读数失效 / 已外发 / 已花钱，标 ⚠；
  >5 条 = SPLIT 信号），随 change 归档。
- R2 spec 由 critic 按内容判定后直接进循环；brainstorm 只在立项与 R3；critic / reviewer 冲突由 AI 裁定并记
  `Decided:`。R3 = 动 North Star、板块终态 / 判据、主线段，或花费超项目参数 → 方向交人定；反方是否先派按
  value-review 触发表（大投入前 / 机械信号，同一板块 ≤1 轮）。只动 ARCHITECTURE 决策或数据契约按 R2 走：
  AI 定并写失效前提，Spec 自检必跑，不派反方不问人。
- 板块、终态、判据、主线段增删归人；板块内步骤拆分 / 排序 / 插入归 AI，写在 `主线:` 行并列入汇总。
- 项目参数（常设偏好）一行在 CLAUDE.md Stack & Conventions：资源停止线 / 花钱上限 / 大投入门槛 / 第二反方；
  未声明 = 无停止线，新付费渠道首次仍问一次并写回。

### 2.2 里程碑汇总（value-review）
`retros/<date>-milestone.md`，≤40 行，写给人、无代号。七段：① 你现在能做到的新东西；② 本期我定的事
（`git log <上次汇总>..HEAD -- <archive dir>` + grep `Decided:`，难撤回在前，可否决；附花费对参数线）；
③ 到期移出的条目（附 `wc -c` CLAUDE.md / backlog.md）；④ 方向：反方并排表或「未触发：<信号读数>」；
⑤ 位置 + 距离 + 上期承诺落了吗 + 机械信号 a / b 命中否 + 唯一下一步；⑥ 需要你定的（四类，无则「无」）；
⑦ `工具包:` 一行。末两行：「最不满意？」（未答写「未答」）；`模型:`。
触发：主线里程碑 / 最近汇总 ≥4 周（按 commit 序取锚点）/ 机械信号 / 人问。Project review（板块收官、
模型换代、人要求）七项不变，但第 5–7 项由方向反方写、AI 逐条核事实并排。删除：支线计数（Now 三字段）、
观察位 #4–#6、[decide] A/B 停等。

### 2.3 方向反方（dispatch-prompt 变体 + value-review）
- 默认 1 个 fresh-context 外部反方；第二个按内容判定，有第二个模型家族可用则优先。配方：`git archive HEAD`
  快照到 scratchpad，git log 预导出，CLAUDE.md / AGENTS.md 改名 `PROJECT-*.md`，`claude -p`
  （`--setting-sources local --strict-mcp-config`，只允许 Read / Grep / Glob，不联网、不读本机产物）。Agent
  派发只作退路并标「独立性弱一档」（harness 事实：subagent 会被注入 CLAUDE.md）。
- 触发：大投入前（新板块 / 改 North Star 或主线段 / 花费超项目参数 / 主线步预估 ≥5 个 change；门槛为项目
  参数）+ 机械信号 a（上期承诺同一项第 2 次 ✗；若是可只读跑的实验则等待期直接跑）/ b（判据报达成而主线
  仍继续）+ 模型换代 / 人问；同一板块 ≤1 轮，除非信号命中。
- 产出处理：AI 逐条核事实，并排表四列（反方原话 ≤2 行｜事实成立?｜接受 / 反驳｜对方向意味着什么）进
  retro 或 proposal Why；反方全文进 `docs/notes/<date>-adversary.md`；反方方向建议只作参考。

### 2.4 热存储（GUIDE §6、模板 backlog、change-loop §1 / §5）
- 热 = CLAUDE.md、backlog、在途契约、项目参数、watchlist、decisions（每 session 或每路由都读）。上限：
  backlog 8KB（hook 已有）；watchlist / decisions 靠下面两条收缩；CLAUDE.md 不设数字，汇总报 `wc -c`。
- decisions.md 只收四类人裁定（人话一行）；AI 技术决定在 `Decided:` 行随 change 归档；架构决定在主 spec
  `## Architectural Decisions`（注明来源 change；被推翻的改写为 Superseded）。
- 留给未来的条件优先写到会被读到的地方（要动的文件头 / Verify 断言 / spec Requirement 下一行），放不下才进
  watchlist 并带触发。到期 = 两次汇总未触发或 ≥8 周（行出生日 `git blame`）；绑定具名未来事件 / 未开始
  主线步的免到期；AI 逐条审 → 删行（git 有）→ 汇总 ③ 列出；写新条目前 grep 旧条目。
- 路由时按本 change 要动的路径 / 模块名 + 主线步 + change-id grep backlog 支线与 watchlist，命中才列一行。
- skill 正文不放评估位 / 观察位；GREEN 观察只记 FIELD-LOG 并带到期日。

### 2.5 过程约束减法（change-loop、模板、openspec-config）
切除（ablation 台账在 FIELD-LOG 2026-10-15）：每迭代恰好一个 task；5 次迭代上限 + stuck 三判据（留一句
「同一错误重复即换思路或 BLOCKED」）；先写失败测试的顺序；Outcome 三分类与 enabling ≤2 change（模板 North
Star 段与 change-loop 两处）；Errata / Decisions 仪式名（留一句分流）；两处过期槽；§1「假设靠读取验证不靠
回忆」；§6「harness 警告上下文时收工」（与 harness 自动摘要相反）；§4 常设授权段压缩为两行（harness opt-in 说明只留
模板）；每 change 默认先 brainstorm；「计划与现实脱节 → 从 spec 重生成剩余 tasks」；「『这次简单』不算」反驳句；R0 的 ≤1 小时 / 一次 commit；路由 `Next:` 行；Close `主线:` 复述行与工具名点名；模板 Hard
Rules「外部库 / API 先验证」「测试是承重墙：不删除」；openspec-config 的「每迭代恰好一个 task」与 Errata 句。
保留（契约内核）：Loop Contract 四字段 + 可选 Decided；只在绿提交 + 绿锚点；失败注记进文件；Verify 真输出；
Spec 自检 `Critic:` 行 + 按内容判定；gate 底线 + 按内容判定 + 增量 gate 规则；「gate = fresh-context，inline
不算」+ DONE-ungated；dispatch 槽位 + 禁孙 agent；land the plane；「不加未被要求的范围」。
R1 = 单文件含 Loop Contract（Goal / Non-goals 各一句，Scenarios 按需；OpenSpec 项目 `schema: lite` +
`skip_specs: true` 正式化）；R2 = OpenSpec 四件套；spec 只写契约与 scenarios。

### 2.6 等待期（change-loop §6、模板 backlog）
Now 下一步为「等 <外部事件>」且无可路由主线步时不停机：探针 / 测量 / 裸模型对照（不花钱或按参数）、到期审
（只产清单，移出在里程碑）、`工具包:` 一行；只读或只写 `docs/notes/`、探针目录、独立 worktree。并行调度不设计。

### 2.7 项目层一次性消融（bootstrap v5.5 → v6.0 迁移）
迁移时 AI 自决：只审约束过程的项目自加规则（must / 禁止 / 先…再…），问「防哪种失败、近 4 周在当前模型上
出现过吗」，答不出即删；红线、数据契约、anti-scope 式 Domain Rules、运行须知不动；删除清单进迁移 commit 与
首份汇总 ②，人可否决，复发只回装那一条并注当时模型。

### 2.8 工具包回路
汇总 ⑦ 固定前缀 `工具包:`，工具包会话 grep 跨项目 retros 收割进 FIELD-LOG（手动回路）；README 修改约定
要求改 skill 前先读。

## 3. 接口与迁移

动到 GUIDE §5 接口表：Hard Rules 条目、Now 四字段 → 三字段、路由三行 → 两行、Close `主线:` 行、Loop Contract
加可选 `Decided:`、回顾产物名、openspec-config guidance 内容 → **v6.0 major**。迁移段在 project-bootstrap
（v5.5 → v6.0 七步 + 分批裁定：new_review_create 先迁，其余项目在其首份 v6 汇总前只报「待迁」不迁）；
在途 change 按旧格式收尾，新格式是子集。旧版（< v5.5）迁移步骤移到 GUIDE §5。

文件：VERSION；README（版本表、修改约定、目录树）；GUIDE §1 / §2 / §3 / §4 / §5 / §6；templates/CLAUDE.md、
backlog.md、openspec-config.yaml；hooks/warn-route-before-opsx.ps1（文案）；skills/change-loop/SKILL.md、
dispatch-prompt.md；skills/value-review/SKILL.md；skills/project-bootstrap/SKILL.md。

## 4. 不做

新 hook；改 skill 名或触发词；多 change 并行调度；项目侧清理（冻结代码测试移出、skill 内 PowerShell 数据
逻辑进 CLI、watchlist 实际清扫）——归项目迁移轮；撤回表五项不重提（gate 保留且底线不动）。

## 5. 验证与 GREEN 观察位

验证（实施时粘贴输出进 FIELD-LOG）：尺寸 change-loop ≤9.5KB（实测 9.2KB，较 v5.5 −16%；原设计值 7.5KB 未达，判定不再删语义——
fresh-context 评审要求的消歧句又加回约 0.5KB）、value-review ≤7KB（实测 6.8KB）、bootstrap ≤11.5KB（实测
11.4KB）、模板 CLAUDE.md ≤3KB；陈旧锚点 grep（`Next:`、`支线计数`、`评估位`、`观察位`、`三分类`、`每迭代恰好`、`harness 警告`、
`承重墙`、`语义模糊`、`Errata`）在 skills/ 与 templates/ 零命中（GUIDE §5 对照表、FIELD-LOG 历史、project-bootstrap v5.5→v6.0 迁移段里作为
删除对象的旧句除外）；
`templates/openspec-config.yaml` 用 PyYAML 解析，guidance / rules 每项为 str；`warn-route-before-opsx` echo
用例（独立隐藏控制台）输出一行 JSON、`opsx:proposed` / `change-loop` 静默、坏 JSON exit 1；部署副本
`diff -rq` 与仓库一致；fresh-context 评审（一致性 / 裁定保真 / 可执行性）[blocking] 修完再发版。

GREEN 观察位（全部在 FIELD-LOG 2026-10-15 条，带到期）：首份里程碑汇总 ≤40 行、无代号、用户有反应；⑥ 每
里程碑 ≤1 条；首次方向反方的并排表与采纳 / 否决；到期审移出 vs 否决；等待期产物不越界；字节读数；ablation
复发信号（stuck / 上限、R2 人批、TDD 顺序、支线计数）。
