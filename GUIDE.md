# my-work-skill v4 使用指南

> v4 = v3（WORKFLOW.md）的流程内核 + 四层工程模型重构 + 2026-07 开源生态调研融合。
> WORKFLOW.md v3.6 冻结为参考文档，其中附录 G（hooks）、5.4.1（R-revision）、5.8（archive 操作）仍是权威，本指南直接引用不复制。
> 融合来源与拒绝清单见 §7——每条采纳/拒绝都有出处和理由，无来源的"最佳实践"不进本文档。

---

## 1. v3 的问题与 v4 的对应

| 痛点 | v3 的做法 | 根因 | v4 机制 |
|---|---|---|---|
| 1 人工控制过多 | 人在每个阶段间确认 | 人在环里（in the loop），吞吐受限于人 | Loop Contract + 分级 gate，内环自治（`change-loop`） |
| 2 AI 跨步、文本约束力不足 | 加更多文本（PROTOCOL.md、项目内 WORKFLOW 引用） | 会话内衰减是主敌（合规几率每多生成一个函数 -5.6%，McMillan 2026），更厚的文本救不了 | 约束下沉（§2）+ 短会话纪律（land the plane，§3） |
| 3 流程死板 | 固定 8 步，所有 change 同价 | 成本固定支付，风险不固定存在 | R0–R3 风险路由：AI 判断路由并声明理由，人审**路由**不审步骤 |
| 4 小工程分支没用过 | 独立轻量流程（第 6 部分） | 死重 | 删除。R0/R1 路由天然覆盖 |
| 5 插件更新靠手动 | 文档写"季度手动"（7.4） | 记忆型约束必然漏 | `toolchain-refresh` skill + scheduled routine（harness 层） |
| 6a 技术自嗨 | 无机制 | 北极星只存在于人脑 | NORTH_STAR.md 工件化 + Outcome 强制字段 + 三分类判据 + `value-review` 触发器 |
| 6b 架构/backlog 过时 | 人凭感觉选节点回顾 | 不可靠且滞后 | `value-review` 触发条件表（可观察信号）+ 周期兜底 |

v3 做对、v4 原样保留的：附录 G hook 体系、R-revision append-only、External APIs 实查、evidence-based verify、subagent 复述约束、spec 是契约不是文档。

---

## 2. 四层工程模型

| 层 | 回答的问题 | 载体 | 关键纪律（含 2026 实证修正） |
|---|---|---|---|
| **Harness（环境层）** | 无论模型怎么想，什么被强制？ | hooks、settings、scheduled routines、权限 allowlist | hook 是确定性的，CLAUDE.md 是建议性的（官方 docs 原话）。重复违反的文本规则 → 转成 hook |
| **Context（信息层）** | 每个时刻窗口里有什么？ | 常驻 CLAUDE.md / 按需 skills / 持久文件 | 见下方"上下文纪律" |
| **Prompt（指令层）** | 单次调用怎么说？ | skill 正文、`templates/dispatch-prompt.md`、OPUS-SYSTEM.md | 规则写在"正确高度"：具体启发式，不是 if-else 也不是空话；验证标准具名写进 prompt；派发用必填槽位模板，不用散文叮嘱 |
| **Loop（控制层）** | 迭代由谁控制、何时退出？ | Loop Contract | 五要素闭合（§3 审计表）；人从环里移到环上 |

**约束下沉原则**（每写一条约束，自底向上问）：

1. 能 hook 强制吗？→ 写脚本（如测试命令纪律）
2. 能变成模板必填槽位吗？→ 进模板（如 Outcome 字段、dispatch 模板、External APIs 表）
3. 能做成 skill 在特定时刻注入吗？→ 进 skill（如路由规则、回顾流程）
4. 都不能且每步都需要 → 才进 CLAUDE.md 常驻文本

**上下文纪律**（v4 修正版）：

- **有效工作区约 40%**：召回质量在上下文填到 ~40% 后显著下降（Horthy "dumb zone"；ralph 实践在 147–152k/200k 处观测到性能跳水）。不要等 60-70% 才行动。
- **文件交接 > 压缩**：结构化文件交接后开新 session，效果优于 /summarize 压缩续跑（Anthropic harness 研究，2026-03）。v3 的 checkpoint 编排退役，升级为 land-the-plane（§3）。
- **短会话是遵循度的主要杠杆**：McMillan 因子研究（1,650 session）证明 CLAUDE.md 的长度/位置/矛盾对遵循度无可测影响，会话内衰减才是真实效应。CLAUDE.md 仍然保持精简（token 成本），但别指望抠行数换纪律——换纪律靠短会话 + hook。
- **Recitation**：每个 task 开始时用一行复述 Contract 的 Outcome + 当前 task（把全局目标推回近端注意力，Manus 实践）。
- **保留失败记录**：3 行失败注记（tried/observed/hypothesis）append 进 Contract 后不删——模型看到失败才会绕开失败。
- **噪音隔离**：全量测试日志、构建考古这类高输出操作派给 subagent，subagent 只返回 1,000–2,000 token 摘要。
- **常驻文件保持稳定前缀**：CLAUDE.md/skills 里不放时间戳、不放频繁变动的内容（KV-cache 命中率，10x 成本差）。

**评审分诊规则**（防评审驱动的过度工程，官方 docs 2026 警告）：gate 评审的发现分两类处理——[blocking]（违反 spec/合同，或真实缺陷：正确性/资源泄漏/数据丢失/安全）必须修；[nit]（风格与"可以更好"）只记录不追。评审者永远能找出毛病，全追等于把过度工程外包给评审环节。

---

## 3. 四个嵌套循环 × 五要素审计表

循环工程五要素：**明确终止 / 循环体简单 / 回退策略 / 粒度 / 验证方式**。每个循环逐项闭合：

| 要素 | 内环（task） | change 环 | value 环 | meta 环 |
|---|---|---|---|---|
| **终止** | 绿+commit（成功）；stuck 判据或 5 次迭代上限 → 诊断分流：复合任务→SPLIT，其余→BLOCKED | 三态：DONE（证据包）/ BLOCKED（阻塞记录）/ SPLIT（超预算拆分） | retro 写完 + 人决策（write and stop） | 报告完成（含"无变化"一行式） |
| **简单** | 恰好一个 task：红→绿→审→commit | 四拍：Route→Contract→Loop→Close | 5 步固定流程 | 5 步固定流程 |
| **回退** | 绿锚点：只在绿提交；坏树 `git reset --hard` 回锚点；迭代内可 fix-forward，跨边界禁止 | spec 层 R-revision；计划层重生成 tasks（不逐行补丁）；代码层绿锚点 | 人批准前零变更落地；北极星失真 → 全线暂停 | 文档先行；版本前后记录在案可回装 |
| **粒度** | 一个 scenario 红→绿；>5 迭代 = 粒度错误信号 | 0.5–2 天；超预算 = SPLIT 不是加班 | 5 个 archive / 4 周 | 周–月 |
| **验证** | 具名命令（backpressure：命令+期望输出写进 Contract，"测试通过"四个字无效） | Verify 全跑 + Outcome check + 人审证据包 | 上轮承诺核销先行（step 1） | break-check 真跑命令 + hook 四用例 |

> 本节表格是速查；数值与判据的**权威定义在 `change-loop` skill 正文**，两处冲突以 skill 为准。

**stuck 判据**（任一命中即停止"换个说法再试"）：空 diff 迭代；同一错误签名连续 2 次；修 A 坏 B 坏 A 往返一圈。来源：ralph 生态的机制化实践（zeroclaw/langchain 2026）。

**分级 gate 评审**（已拍板）：R0 inline 自检 / R1 单独立 reviewer / R2 双视角（spec 合规 + 代码质量）/ R3 三视角（spec + 架构 + skeptic）+ 人。评审者是 fresh-context：只看 diff + 标准，不看产生它的推理过程。

**人的位置**：R2+ 的 spec gate、每个 change 的 evidence gate、value 环全部决策。其余时间人在环上不在环里。

---

## 4. 部署

### 新项目

1. 复制 `templates/CLAUDE.md` + `templates/NORTH_STAR.md` 到项目根目录；**North Star 由人写**。
2. 部署 skills：`skills/` 三个目录 → `~/.claude/skills/`（跨项目）或项目 `.claude/skills/`。
3. 部署 hooks：按 WORKFLOW.md 附录 G；重型测试项目按 Heavy-test 决策路径补 block-unsafe-test-commands。
4. 中型项目跑 `npx @fission-ai/openspec@latest init`（注意：OpenSpec 2026-06 已重构到 v1.x action-based 工作流，v3 文档里的命令面先跑一次 `toolchain-refresh` 核对）。
5. 首次 brainstorm → ARCHITECTURE.md + backlog.md → commit。
6. subagent 派发一律用 `templates/dispatch-prompt.md` 填槽。
7. 本工具包仓库保留一份本地 clone——skills 中对 WORKFLOW.md 的引用（附录 G、§5.8）指向工具包，**不把 WORKFLOW.md 复制进项目**。

### v3 项目迁移

1. `openspec/` 与 hooks 保留不动。
2. 新增 NORTH_STAR.md（人写）。
3. `templates/CLAUDE.md` 替换项目 CLAUDE.md（Stack 段照搬）。
4. 删 PROTOCOL.md（内容已由 skills 承载）、删项目内 WORKFLOW.md 副本。
5. 行为变化：session start 从"报告后问"改为"报告后继续"；checkpoint 编排改为 land-the-plane。

---

## 5. Opus 的使用方式

注入方式（约束力从强到弱）：① `claude --append-system-prompt (Get-Content OPUS-SYSTEM.md -Raw)`（PowerShell；bash 用 `"$(cat OPUS-SYSTEM.md)"`）或 output style（推荐）；② 全局 `~/.claude/CLAUDE.md` 追加段。二选一。

**预期**："Fable 体验" = 模型智力 + 行为校准 + harness 支撑。OPUS-SYSTEM.md 移植第二项，第三项本来就模型无关，第一项移植不了。补偿：任务颗粒度减半、gate 按路由分级加密、模型分工（Opus 跑内环吞吐，最强模型守 R3 设计与 value-review 判断——智力放 gate 上，吞吐放循环里）。单次派发级的模型选择由 AI 自动判断：规则在 `dispatch-prompt` 的 Model 槽位（默认继承；只在错误可被机械检测时降级；**产出可以便宜，裁判不能便宜**），降级派发必须附带 cheap-model 行动规范整块。

**照做后明天会发现**：审查时间成为新瓶颈（设计使然）；Opus 长会话纪律衰减更陡（-5.6%/函数是 Claude 系普遍效应，Opus 基线更低）→ change 颗粒度要更小、land-the-plane 更勤。

---

## 6. 无人值守轻量方案（Ralph 式，按拍板：只给 recipe 不建 skill）

**适用**：只烧 R0/R1 级 backlog 条目；greenfield 或测试覆盖强的区域。**不适用**：brownfield 复杂区（Huntley 本人："绝不在存量代码库上跑"）。首跑必须白天陪跑 2–3 次再过夜。

**驱动脚本骨架**（PowerShell）：

```powershell
# unattended-burn.ps1 — run from project root; prerequisites: hooks active, allowlist configured
$max = 10   # max-iterations 是首要保险（官方 ralph 文档原话）
for ($i = 1; $i -le $max; $i++) {
    $before = git rev-parse HEAD
    $out = Get-Content PROMPT.md -Raw | claude -p --allowedTools "Read,Edit,Write,Bash(git *),Bash(dotnet test --filter *)"
    if ($out -match 'EXIT:(ALLDONE|BLOCKED)') { break }      # 三态出口:与 EXIT:DONE(单项完成)不同暗号
    if ((git rev-parse HEAD) -eq $before) { break }          # 无新 commit = 无进展(commit-on-green 下,进展必然是新的绿 commit)
}
```

**PROMPT.md 要点**（每迭代固定读入，内容项目特异）：从 backlog 取**恰好一个** R0/R1 条目 → 按 change-loop 纪律执行 → 绿才 commit → 更新 backlog → 输出 `EXIT:DONE`（单项完成）/ `EXIT:ALLDONE` / `EXIT:BLOCKED`（附 blockers 写入 `BLOCKED.md`）。

**防护清单**（全部必须，缺一不跑）：max-iterations；不开 `--dangerously-skip-permissions`（用 allowlist）；hooks 全开（尤其测试命令纪律——你的机器冻结事故就是它防的）；三态出口；空 diff 检测；API 用量告警；晨间验收 = 审证据包，坏树 reset 回绿锚点。

**明天会发现**：产出质量 = backlog 条目质量——含糊的条目烧出含糊的代码；$10/hr 量级的 API 燃烧是常态（有人一晚 $500）。

---

## 7. 融合决策记录（采纳/拒绝均有出处）

**采纳**：

| 机制 | 来源 | 进了哪里 |
|---|---|---|
| 三态终止 + max-iterations 首要保险 | anthropics/claude-code ralph-wiggum docs | change-loop Contract / §6 |
| 绿锚点回退、只在绿提交 | ghuntley.com/ralph | change-loop Step 3 |
| 每迭代恰好一个 task | ralph 生态共识 | change-loop 迭代不变量 |
| stuck 判据三条 | zeroclaw #2152 / langchain #36139 / Kinney | change-loop Step 3 |
| 具名 Verify 命令（backpressure） | Huntley / Kinney | Contract Verify 字段 |
| land the plane 收工模式 | Yegge (beads) | change-loop Session boundaries |
| 40% 有效上下文 + 文件交接>压缩 | Horthy ACE-FCA + Anthropic 2026-03 | §2 上下文纪律 |
| recitation / 保留失败记录 / 噪音隔离 / KV 稳定前缀 | Manus (Yichao Ji) + Anthropic 2025-09 | §2 / change-loop |
| 评审发现分诊 | Claude Code 官方 docs 2026 | §2 / gate 评审 |
| 派发模板必填槽位 | Anthropic multi-agent research 2025-06 | templates/dispatch-prompt.md |
| 短会话>抠 CLAUDE.md 行数 | McMillan, arXiv 2605.10039 | §2（修正 v3 假设） |

**拒绝**：

| 候选 | 拒绝理由 |
|---|---|
| BMAD 全套 | 实测 6 天 $200 vs 别人 1–2 天；QA agent 对坏构建报"Perfect"；为 5–20 人团队设计。只取其"实现前对抗审查"思想（已含于 gate 评审） |
| Gas Town / 20+ agent 编排器 | 作者本人劝退大多数开发者；solo 场景无收益、纯成本 |
| beads（暂缓） | backlog.md + OpenSpec + claude-mem 已覆盖大部分；等 backlog 依赖图真的痛了再装（git-native，随时可补），现在上是无脑借鉴 |
| Spec Kit / Kiro 迁移 | SDD 横评里 OpenSpec 赢了 solo 场景（最低摩擦 + 最佳 brownfield）；迁移零增益 |
| ralph 官方插件 | 隐藏 hooks、卸载可能破库（HumanLayer 弃用实证）；15 行裸脚本更可审计、Windows 可移植 |
| 巨型 subagent fan-out | 配额燃烧 + 非确定性；保留"build/test 单 subagent"的部分 |
| C 编译器式并行多 agent | 前提是任务间完全独立（其失败模式恰是任务耦合）；solo 中型工程不具备该前提 |

---

## 8. 验证计划（GREEN 阶段观察清单）

RED 证据 = v3.x 实证史（内存炸机、propose 漏 add、R-revision 三连、痛点 1–6），已文档化。GREEN 在下个真实项目逐项观察：

- `change-loop`：路由声明率；R0 判错率；stuck 判据有没有真的截住"换个说法再试"；绿锚点 reset 有没有发生、发生时挽回了什么；BLOCKED 出口的 blockers 质量。
- `value-review`：触发信号 vs 你的直觉；分类判据误伤正当 enabling 的比率。
- `toolchain-refresh`：**第一个真实任务已就位——核对 OpenSpec v1.x 重构后的命令面与 WORKFLOW.md 附录 A 的差异**；scheduled routine 是否真的跑起来。
- 分级评审：R1 单审若 wall-clock 开销不成比例，可降级为结构化 inline 自审（superpowers 5.x 同款权衡）——但先收集 2–3 个 change 的命中数据再降。
- 无人值守 recipe：白天陪跑数据（迭代数、BLOCKED 率、晨检发现）攒够再过夜。

绕规则的原话记下来 → 回填对应 skill 的 rationalization 表。description 命中率低 → 按 writing-skills SDO 规则改 description 不改正文。

---

## 9. 与 WORKFLOW.md v3.6 的关系速查

| v3 章节 | v4 状态 |
|---|---|
| 第 0/2A/4/6 部分 | **被取代** → `change-loop` 路由（Mode A/B 升级：默认 A + 可观察 B 白名单 + 复述确认 + B 内跳闸——不再让 AI 从文本流畅度猜意图清晰度） |
| 附录 E（PROTOCOL.md） | **被取代** → skills 按需注入 |
| 7.4 工具链保鲜 | **被取代** → `toolchain-refresh` + scheduled routine |
| 5A 上下文管理 | **被取代** → §2 上下文纪律 + land-the-plane（文件交接 > 压缩，40% 阈值） |
| 5.4.1 R-revision、5.6 verify、5.8 archive、附录 G hooks、Heavy-test 决策路径 | **仍是权威**，v4 直接引用 |
| 附录 D/F（CLAUDE.md 模板） | **被取代** → `templates/CLAUDE.md` |
| 附录 A 命令速查 | **待核对**（OpenSpec v1.x 重构）→ toolchain-refresh 首个任务 |
