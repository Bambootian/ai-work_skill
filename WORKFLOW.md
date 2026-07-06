# OpenSpec + Superpowers 工程实践完整流程 v3

> **适用场景**:个人向工程开发——数月中型工程,或 1-5 天小工程(可能扩展)。
>
> **不适用场景**:< 半天的脚本、PoC、一次性临时任务——直接和 AI 口头沟通。
>
> **文档版本**:v3(2026-05)。OpenSpec、superpowers 在快速演进,命令有效期约几个月,思想会留下来。

---

## 一页摘要(先看这个)

**分层架构**:

```
┌──────────────────────────────────────────────────────────┐
│ Layer 4 │ POLISH:     code-simplifier                     │
├──────────────────────────────────────────────────────────┤
│ Layer 3 │ REVIEW:     superpowers code-reviewer           │
│         │           + OpenSpec validate + AI 逐条核查      │
│         │           + 端到端真实运行                       │
├──────────────────────────────────────────────────────────┤
│ Layer 2 │ EXECUTION:  superpowers (TDD / subagent / debug)│
├──────────────────────────────────────────────────────────┤
│ Layer 1 │ SPEC:       OpenSpec(中型) / SPEC.md(小型)  │
├──────────────────────────────────────────────────────────┤
│ Layer 0 │ BRAINSTORM: Mode A 探索式 / Mode B 补全式       │
└──────────────────────────────────────────────────────────┘
```

**中型工程核心循环**(每个 change 跑一次):

```
[选 change] → [Mode A or B] → [Explore 显式声明] → [Propose 8 步]
   → [Apply: TDD] → [Verify: spec + 端到端] → [Polish] → [Archive + 健康自检]
```

**小工程核心循环**(整个项目跑一次):

```
[Brainstorm: Mode A or B] → [SPEC.md] → [TDD apply] → [端到端] → [README]
```

**心智模型**:
1. 一个 change 是一个原子工程单位(0.5-2 天)。完整工程 = N 个 change 累积归档。
2. spec 是契约,不是文档。可验证、能转测试、写不出来不假装。
3. 流程出错时回头便宜——永远在 spec 阶段多投入。
4. 模糊与清晰是 change 级判断,不是项目级预设。

**AI 痛点防御映射**:

| 编号 | 缺陷 | 防御 |
|---|---|---|
| a | context drift | SessionStart hook + checkpoint 策略 + spec / archive |
| b | API 幻觉 | design.md `External APIs` 字段强制查证 |
| c | 过度抽象 | Hard Rules + spec `Non-goals` + code-reviewer |
| d | 不读现有代码 | Explore 显式声明 |
| e | 顺手改坏无关代码 | code-reviewer + 每 task 一次 commit |
| f | session 内上下文膨胀 | checkpoint + 总结注入子目录 CLAUDE.md |
| g | 跨 session 状态丢失 | SessionStart hook + tasks.md |
| h | 决策链丢失 | design.md `Decisions` + `Brainstorm Log` |
| i | AI 自审假认真 | 独立 subagent + 对抗性 prompt + 3 条不放心点 |
| j | 虚假完成信号 | TDD + verify 端到端真跑 |
| k | AI 不遵循文本指令 | PreToolUse Hook 硬约束(附录 G)+ 文本引导双保险 |

---

## 第 0 部分:流程选择(进入工作前先走)

```
段 1: 第一次进入这个项目?
├─ 是 → 走第 3 部分项目骨架阶段
│       1. 先放中型 CLAUDE.md + PROTOCOL.md(默认约束底盘)
│       2. 跑 Mode A 项目级 brainstorm
│       3. 按 brainstorm 产出判规模:
│          - 中型 → 保持,继续骨架阶段
│          - 小型 → 替换为小工程 CLAUDE.md,跳到段 3
│          - 极小 → 删 CLAUDE.md,放弃本流程
└─ 否 → 进段 2

段 2: 本次 change 能用 2-3 句话清晰说出"意图、边界、关键决策"吗?
├─ 不能 → Mode A 探索式 brainstorm
└─ 能   → Mode B 补全式审查

段 3: Mode A/B 跑完后判规模:
├─ 极小(< 半天)   → 不走本流程,口头沟通
├─ 1-5 天小工程   → 第 6 部分轻量分支
└─ 数月中型 change → 第 5 部分标准 8 步 propose
```

规模判断在 Mode A/B(或项目级 brainstorm)之后,不在之前——模糊阶段判断不准规模。每个 change 重新判,不要预设。

**关于 CLAUDE.md 预放**:项目首次进入时,brainstorm 前必须先放 CLAUDE.md + PROTOCOL.md,否则 Hard Rules 都未生效。默认放中型版,brainstorm 后若判定为小工程再替换。

---

## 第 1 部分:环境准备(一次性,~30 分钟)

### 1.1 系统要求

```bash
node --version   # >= 20.19.0,不够用 nvm 升级
claude --version
git --version
```

### 1.2 安装 OpenSpec(项目级)

```bash
cd <项目目录>
git init
npx @fission-ai/openspec@latest init
```

`init` 时选 Claude Code + core profile。

### 1.3 安装 Superpowers(用户级)

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

确认:`/plugin list`,superpowers 应为 enabled。

### 1.4 安装 code-simplifier

```
/plugin marketplace add anthropics/claude-code
/plugin install code-simplifier
```

### 1.5 明确不装

- ❌ planning-with-files(和 OpenSpec 重叠)
- ❌ 独立 codereview skill(和 superpowers code-reviewer 重复)
- ❌ gstack 全套(dispatcher 抢生态位)

### 1.6 验证

"列出当前所有可用的 skill",应看到:
- openspec-propose / explore / apply / sync / archive
- superpowers 的 brainstorming / writing-plans / test-driven-development / subagent-driven-development / code-reviewer / systematic-debugging / verification-before-completion
- code-simplifier

看不到就 `/reload-plugins`。

---

## 第 2 部分:项目配置文件(一次性,最关键的一步)

v3 把 CLAUDE.md 拆为**骨架 + 协议**两个文件:

| 文件 | 内容 | 长度目标 | 加载方式 |
|---|---|---|---|
| `CLAUDE.md` | 项目信息 + Hard Rules + 引用 | ≤ 40 行 | 每次自动注入 |
| `PROTOCOL.md` | Skills Coordination Protocol 完整版 | 不限 | CLAUDE.md 指令按需读取 |

**为什么拆**:CLAUDE.md 超过 80 行后 AI 对中间段落的遵循度下降。Hard Rules 必须每次注入,协议细节只在特定阶段需要(propose 时、apply 时),按需读取即可。

两份模板见附录 D-F,按规模选:

| 规模 | 需要的文件 |
|---|---|
| 中型工程 | `CLAUDE.md`(附录 D)+ `PROTOCOL.md`(附录 E) |
| 小工程 | `CLAUDE.md`(附录 F),不需要 PROTOCOL.md |

复制到项目根目录,只改 `Stack & Conventions` 段。

### 保护 CLAUDE.md

Superpowers / OpenSpec 装完后可能自动 append。每次它们想改,审一遍再合并,不要盲目接受。

---

## 第 2A 部分:工作流文档的项目引用(v3.1 新增)

### 为什么需要

AI 在 session 中只能看到项目目录内的文件和 CLAUDE.md 引用的内容。如果工作流文档不在项目里也不被引用,AI 无法在关键阶段切换点主动对照流程,容易在 skill 的"自动驾驶"下偏离项目约定的阶段顺序。

### 做法

1. **把本文档复制到每个工程的根目录**,文件名固定为 `WORKFLOW.md`
2. **加入 .gitignore**(不提交到仓库):
   ```
   WORKFLOW.md
   ```
3. **在 CLAUDE.md 中引用**(加在 `## Protocol` 段之后):
   ```markdown
   ## Workflow Reference

   完整工程实践流程在项目根目录 `WORKFLOW.md`。
   首次进入项目或进入新阶段(骨架/propose/apply/verify/archive)时读取对应章节。
   ```
4. **在 PROTOCOL.md 中加入阶段顺序约束**(见下方模板更新)

### 效果

- AI 每次 session start 看到 CLAUDE.md 中的引用 → 知道 WORKFLOW.md 存在
- 进入新阶段时主动读取对应章节 → 不会跳步骤
- 文件不入仓库 → 不污染团队 git 历史,个人工作流私有

### PROTOCOL.md 模板新增段(插入在最前面)

```markdown
## Phase Order (strict)

1. Brainstorming → 2. 骨架落地(ARCHITECTURE.md + backlog.md + CLAUDE.md Stack)
→ 3. Explore 声明 → 4. Propose(含自审) → 5. Apply(TDD)
→ 6. Verify → 7. Polish → 8. Archive

跳到下一阶段前,上一阶段的产物必须存在。
骨架阶段仅在项目首次进入时执行一次;后续每个 change 从步骤 3 开始。
```

---

## 第 3 部分:项目骨架阶段(一次性,0.5-1 天)

### Step 0 — 预放配置文件(2 分钟)

把中型模板的 `CLAUDE.md` 和 `PROTOCOL.md` 复制到项目根目录。Stack 段先空着或填粗糙猜测,brainstorm 后再回填。

### Step 1 — 启动 brainstorm(30-60 分钟)

```
我想做 <粗糙描述>。在写任何文档前,请用 superpowers 的 brainstorming
skill 帮我把这个 idea 捋清楚。从最核心的问题问起,把模糊点都暴露出来。
```

讨论范围:产品目标 / 技术栈 / 架构方向 / MVP 边界 / 关键非功能要求。

### Step 2 — 判断规模(brainstorm 收敛后立即)

| 判定为 | 动作 |
|---|---|
| 数月中型工程 | 保持中型 CLAUDE.md + PROTOCOL.md,继续 Step 3 |
| 1-5 天小工程 | 替换 CLAUDE.md 为小工程版,删 PROTOCOL.md,跳到第 6 部分 |
| 极小 / 一次性 | 放弃本流程,删配置文件,口头沟通完成 |

### Step 3 — 落地两份文档(中型工程才走;15-30 分钟)

```
把刚才讨论的内容整理成:
  1. ARCHITECTURE.md:架构 + 模块 + 关键决策的 rationale
  2. backlog.md:第一批 capability 列表,按依赖排序
另外,回填 CLAUDE.md 的 Stack & Conventions 段。
```

AI 写你审。审 ARCHITECTURE 是否反映真实结论、backlog 优先级和依赖是否正确、CLAUDE.md 没被篡改。

### Step 4 — Commit

```bash
git add CLAUDE.md PROTOCOL.md ARCHITECTURE.md backlog.md openspec/ .claude/
git commit -m "chore: bootstrap project with OpenSpec + Superpowers"
```

### backlog.md 模板

```markdown
# Project Backlog

## Capability roadmap

### Phase 1: MVP
- [ ] user-registration
- [ ] user-authentication
- [ ] product-catalog

### Phase 2: Core flow
- [ ] order-creation
- [ ] payment-stripe

## Notes
- Phase 1 内部强依赖
- Phase 2 依赖 Phase 1
```

backlog 是活的,但只在骨架阶段、archive 后、propose 前修改。已 archive 的 capability 不能删除,只能划掉。

---

## 第 4 部分:Mode A vs Mode B

每个 change 进 propose 前判一次:**你能用 2-3 句话清晰说出"意图、边界、关键决策"吗?**

- 能 → Mode B
- 不能 → Mode A

不要预设。中型工程后期也可能引入全新方向,那时退回 Mode A。

### Mode A — 探索式 brainstorm

**适用**:项目首次进入 / 引入全新 capability / 跨领域 change / 自己也没想清楚。

**AI 角色**:助产士。苏格拉底追问,30-90 分钟,多轮发散后收敛。

**收敛信号**:你能用 2-3 句话向第三方解释清楚。此时进 propose 落工件。

### Mode B — 补全式审查

**适用**:已知模式的迭代 / 已 archive capability 的扩展 / 你心里有方案。

**AI 角色**:质检员。你描述方案,AI 跑结构化 checklist 反向找漏洞,10-30 分钟。

**Checklist**(AI 以 yes/no 开头逐条回答,允许简短补充):

```
准确性
- 边界自洽?有自相矛盾或定义不清的术语?
- 命名/字段/术语风格跟已 archive 的 spec 一致?

正确性
- 技术上能跑通?
- 依赖的现有 capability 是哪些?依赖关系对吗?
- 用到的外部 API/库/函数实际存在且可用?(必须实查,不允许凭训练记忆)

完整性 — 边界
- 空值、超长输入、特殊字符、并发、上下游失败、用户取消?

完整性 — 错误路径
- 失败响应、重试策略、回滚、对其他 capability 的影响?

完整性 — 隐含约束
- 安全/性能/合规要求、用户没说但心里有的?
```

### 模式之间可以切换

- Mode B 跑到一半发现根本性问题 → 退回 Mode A
- Mode A 聊到中途忽然清晰 → 转入 Mode B 跑 checklist 收尾

---

## 第 5 部分:中型工程单 change 完整闭环

### 5.1 选定 change

打开 `backlog.md`,挑下一个未做的 capability。标准:
- 0.5-2 天内能完成
- 依赖项都在 living spec 里
- 可独立交付

太大就拆。

### 5.2 判断 Mode A or B

按第 4 部分的判据(详见该节)。不要跳过直接 propose。

### 5.3 Explore(显式声明)

进 propose 前 AI 必须回答:

```
本 change 是否需要 Explore?
[ ] 需要,理由:...
[ ] 不需要,理由:...
```

需要的常见情况:涉及现有代码需先理解 / 技术方案不止一个需权衡 / 涉及新外部依赖。

执行:`/opsx:explore`

### 5.4 Propose(30-90 分钟)

#### Step 1 — 触发

```
/opsx:propose <change-id>

走 Mode B。我的方案是:...
请先读 PROTOCOL.md,然后跑 Mode B checklist 找漏洞,补完再生成 spec。
```

或:

```
/opsx:propose <change-id>

走 Mode A。我对这个只有粗糙概念,请先读 PROTOCOL.md,然后从核心问题开始问。
```

#### Step 2 — 交互式澄清(Mode A) / Checklist(Mode B)

按选定模式执行。你不确定的,让 AI 推荐 + 给 trade-off,你拍板。这是整个流程最高 ROI 的环节。

#### Step 3 — 生成四件套

```
openspec/changes/<change-id>/
├── proposal.md   ← 为什么做、改什么
├── design.md     ← 技术方案
├── tasks.md      ← 任务清单
└── specs/<capability>/spec.md  ← Requirements + Given/When/Then + Non-goals
```

**design.md 必含字段**:

```markdown
## Decisions

每条:
- 决策:<选了什么>
- 为什么:<理由 + trade-off>
- 在什么前提下会失效

## Brainstorm Log

记录讨论过、放弃的方向 + 放弃理由

## External APIs

| 库/API | 用途 | 查证方式 | 查证日期 |
|---|---|---|---|
| argon2 (npm) | password hashing | npm 存在 + API 签名正确 | 2026-05-12 |
```

> External APIs 的"查证"最低标准:确认包/API 存在 + 主要函数签名正确 + 最近 6 个月有更新。

**spec.md 必含 `## Non-goals`**。

#### Step 4 — AI 自审(必须用独立 subagent)

通过 Agent 工具 spawn 独立 subagent,对抗性视角逐条 yes/no:

```
你扮演一位挑剔的高级工程师审查这份 spec,目标是找问题。

【防 a — context drift】
- proposal 里的每件事,spec.md 里都有对应 Requirement?
- spec 的每个 scenario,tasks 里都有对应 task?

【防 b — API 幻觉】
- design.md External APIs 字段每条都经过实查?

【防 c — 过度抽象】
- tasks 里有 spec 没要求的功能?
- Non-goals 是否覆盖了范围蠕变风险?

【防 d — 不读现有代码】
- 假设了哪些现有代码结构?核实了吗?

【防 j — 虚假完成】
- 每个 Requirement 有 1 success + 1 failure scenario?
- tasks 最后一项是端到端验证?

【防 h — 决策链】
- Decisions 每条带"为什么"+"失效前提"?
- Brainstorm Log 记录了放弃方向?

【反向(防 i)】
- tasks 里有 spec 没要求的 task?
- design 里有 spec 没写的行为?

最后必须列出 3 条最不放心的地方,即使整体认为通过。
```

#### Step 5 — 你审业务意图(5-15 分钟)

AI 自审过后只看:
- proposal 真是我想要的?
- spec 少了什么我心里有但没明说的?
- design 方案我能接受?
- tasks 颗粒度看着舒服?

#### Step 6 — 统一修订

把 AI 自审 + 你审的问题一次性反馈,让 AI 一次改完。

#### Step 7 — Validate

```bash
npx openspec validate <change-id>
```

通过才进下一步,失败让 AI 修格式。

#### Step 8 — Commit

```bash
git add openspec/changes/<change-id>/
git commit -m "spec: propose <change-id>"
```

**实证教训(2026-05-29 causal-chain-enhancements-core)**:必须 `git add` **整个 change 目录**,禁止逐文件 add——偶发会只 add tasks.md 而漏掉 .openspec.yaml / proposal.md / design.md / specs/,直到 archive 前才发现 propose 阶段产物从未入库。

**强制自检(commit 后立即跑)**:

```bash
git ls-files openspec/changes/<change-id>/
# 必须列出最小全集:
#   .openspec.yaml
#   proposal.md
#   design.md
#   tasks.md
#   specs/<capability>/spec.md  (≥ 1 个 capability)
# (CLAUDE.md 不属 propose 产物,apply checkpoint 时再加)
```

少了任何一个立即补 commit,**禁止带残缺的 propose 进 apply**。

propose 做对的标志:你看着 tasks.md 能判断"按这个清单执行下去,做出来的就是我想要的"。

### 5.4.1 R-revision 链:spec 修订记录形态(v3.6 新增)

Apply 阶段发现 spec 与代码/自身内部矛盾时,**不要静默改 spec**——触发
R-revision(Revision 链)：

| 规则 | 说明 |
|---|---|
| 命名 | R1, R2, R3... 按时间顺序递增,永不重用 |
| 位置 | `openspec/changes/<change-id>/CLAUDE.md` 的 `## Revision Log (append-only)` 段 |
| 纪律 | **append-only**:新 entry 追加到末尾,旧 entry 不改不删 |
| 内容格式 | 每条 R-revision 含: 触发症状 → 决策(含方案对比) → 影响摘要(改了哪些下游产物) |
| 触发条件 | (a) spec scenario 与已落地代码矛盾; (b) spec 内部自相矛盾; (c) 新实测数据推翻 D-decision 数值假设; (d) 用户拍板调整锁定决策 |
| 对应代码产物 | R-revision 改完 spec 后,代码/测试在**同一个 commit** 或 **紧邻下一个 commit** 里同步(不允许 spec 改了但代码不跟) |
| 引用 | 下游 tasks.md / design.md / spec.md 改动行用 `(R3 fix)` 标记来源,方便追溯 |
| 不回退已完成 checkbox | R-revision 是对已完成工作的增量修正,不等于重做。tasks.md 已完成的 `[x]` 不改回 `[ ]`,在 group 末尾加一行"(R-revision follow-up)" 说明即可 |

**何时触发 R-revision vs 直接改**:
- 改动影响 ≥2 个下游文件(如同时改 spec + design + 已落地代码): **R-revision**
- 改动仅修文字 typo / 格式,不影响任何决策或行为: 直接改,commit message 里标注

**实证**:primary-source-attribution 在 apply 期间产生了 R1(6 个 probe 实查推翻 D2/D7/D8)、R2(5-lens 自审推翻 Branch-2 deferral)、R3(Evidence dual-channel 类型矛盾),每次都是"停 apply → 改 spec → validate → 恢复 apply"。三次 R-revision 共修正了 4 个 blocker + 9 个 major,防止了大量 Group 3-7 的返工。

### 5.5 Apply(几小时到 1-2 天)

```
/opsx:apply <change-id>
```

CLAUDE.md Hard Rules + PROTOCOL.md 指挥 AI 按节奏跑:

```
For each unchecked task in tasks.md:
  1. 读 spec 找对应 scenario
  2. 写 failing test → 红
  3. 写最少代码让绿
  4. 必要时 refactor 保持绿
  5. superpowers code-reviewer 审 diff
  6. 标 [x] + commit
```

你的角色:观察者 + 仲裁者。介入时机:

- AI 重复失败 3 次 → `systematic-debugging` 做根因
- AI 想改 spec → **停 apply,回 propose 改,validate,再继续**
- AI 写超出 spec → "Hard Rules 防 c"
- AI 想跳过测试 → "Hard Rules 防 j"
- AI 顺手改无关代码 → revert(防 e)

定期 `git log --oneline` 确认每个 commit 颗粒度合理(判据见 5.5.1)。

### 5.5.1 Commit 颗粒度判据(实践细化,不进 CLAUDE.md Hard Rule)

CLAUDE.md Hard Rule 默认每 task 一次 commit。实践中遇到强耦合声明性 task,拆分反而留下"半边接口编不过"的中间状态。判据:

| 情况 | 处理 |
|---|---|
| 跨关注点的 task(检测 vs 分级 vs 数据提取) | MUST 分开 |
| 同一文件家族的连续声明性 task(model + interface + 占位 impl) | MAY 合并,message 显式列出所有 task ID |
| 不确定 | 分开。事后 squash 易,事后 split 难 |

合并的 commit message 写明涉及任务,例:`feat: define core models, interfaces, NullSymbolResolver (tasks 2.1+2.2+2.3)`。

### 5.6 Verify(每个 capability 边界一次)

双重验证。`/opsx:verify` 在当前 OpenSpec CLI 里**不存在**(2026-05 实践确认),用 CLI 命令 + AI 主动核查代替。

#### 5.6.1 spec 合规检查

```bash
openspec validate --changes --strict   # 当前 change 内自洽,tasks 全 [x]
```

外加 AI 主动逐条核查(CLI 只验格式,不验"实现存在"):

```
对照 openspec/changes/<change-id>/specs/<capability>/spec.md 逐条:
- 每个 Requirement 在 src/ 里有对应实现?给出文件:行号
- 每个 Scenario 在 tests/ 里有对应测试?给出测试方法名
- 全测试命令运行输出,失败数=0?
不允许"应该实现了"这类未经验证的措辞。
```

#### 5.6.2 端到端真跑(防 j)

```
跑 superpowers verification-before-completion skill。
启动实际系统,跑核心 scenario,看到真实运行结果。
AI 报告不算数,运行输出才算。
```

### 5.7 Polish — 两类必做

#### 5.7.1 代码级:code-simplifier

```
对本 change 涉及的源码跑 code-simplifier,检查冗余、过度抽象、命名不一致。
公共 API 签名、算法、异常类型 MUST 不变(下游 change 已签约)。
```

#### 5.7.2 工件级:archive 前的 spec/文档清理

code-simplifier 不会管这层。手动扫一遍:
- spec.md 重复 scenario block / 矛盾 Requirement / 命名漂移
  (实证:stutter-detection 曾出现 2 个 scenario verbatim 重复,差点 seed 进主 spec)
- design.md 的 Decisions 是否仍站得住、External APIs 是否仍有效
- tasks.md 勾选项是否对应实际产出

#### 5.7.3 验证

polish 后:全测试保持绿(单元 + 端到端重跑)。polish 单独 commit,不和 archive 混。

```bash
<test-command>           # e.g. dotnet test / npm test
git commit -am "chore: polish <change-id> (post-verify, behavior preserved)"
```

### 5.8 Archive

`/opsx:archive` skill 实际**不会自动合并主 spec**(2026-05 实践确认)。skill 只做文件移动,主 spec 的 seed/append 由用户/AI 手动完成。

#### 5.8.1 触发

```
/opsx:archive <change-id>
```

skill 自动:检查 tasks 全 [x] + artifacts done;移动 change 文件夹到 `openspec/changes/archive/<YYYY-MM-DD>-<change-id>/`。skill 询问"sync now"时,实际是让用户/AI 走 5.8.2 或 5.8.3。

#### 5.8.2 首次 archive 的 seed 操作(项目第一次 archive 才走)

`openspec/specs/` 还是空的:

1. `specs/<capability>/spec.md` 复制到 `openspec/specs/<capability>/spec.md`
2. 首行 `## ADDED Requirements` → `## Requirements`
3. **顶部插入 `## Purpose` 段**(2-3 句话陈述 capability 存在价值;OpenSpec validate 强制要求,缺失直接 fail)
4. 末尾追加 `## Architectural Decisions`,把 design.md 决策按 capability 切分挂入,每条带 *Source: change `<id>` (archived YYYY-MM-DD)*

#### 5.8.3 后续 change 的 merge 操作(主 spec 已存在)

- 同名 Requirement 的 scenario 增量合并(不删旧)
- 新 Requirement 追加到 `## Requirements` 末尾
- 新 Decision 追加到 `## Architectural Decisions`,带 Source 标注
- 旧 Decision 失效:不删除,改写为 *Superseded by <new-decision>, see change `<new-id>`*

#### 5.8.4 健康自检

```bash
openspec validate --specs --strict   # 必须 0 失败
openspec list                         # 应无 active changes
```

外加人工速读主 spec:无矛盾、无重复、命名一致、引用的 capability 都存在、Decisions 都有 Source。

#### 5.8.5 收尾

更新 backlog.md(标记 done,**不删**)。commit。回 5.1。

```bash
git add .
git commit -m "chore: archive <change-id>; seed/merge living specs"
```

---

## 第 5A 部分:上下文管理策略(防 a/f/g)

Apply 阶段是上下文膨胀的高发区——test output、debug 日志、code-reviewer 报告不断累积。以下策略在 session 内和跨 session 两个维度控制上下文健康。

### 5A.1 session 内:checkpoint + 总结注入

#### 强制时机(四处必做)

1. **进 verify 前**:让 verify session 干净接手,不带 apply 的调试噪音
2. **archive 前**:让下一 change 借用本 change 的环境事实(API 行为、文件路径、阈值)而非重学
3. **session 中段(>50% tasks 完成时)**:防 session 崩溃丢失上下文
4. **上下文使用量达 60-70% 时**(v3.6 新增):无论 task 完成百分比如何,
   上下文窗口高水位意味着即将触发压缩/截断,此时 checkpoint 保护信息
   完整性。实证:primary-source-attribution R3 spec 改造吃掉 68% 上下文,
   若不 checkpoint 后续 Group 3 的 dispatch + review 周转会在 85%+ 区间运行,
   压缩丢失细节的概率显著升高。

#### 可选时机

单个 task 完成后(洁癖,不强制)。

#### 操作步骤

```
1. checkpoint 回跳到该 change 对话开始处
   → 中间的 test output、debug 噪音全部丢弃
2. /summarize 生成压缩总结
3. 把总结写入 openspec/changes/<change-id>/CLAUDE.md
   → Claude Code 在 AI 访问该子目录时自动注入
4. 继续下一阶段
```

#### 实证(stutter-detection-core, 2026-05)

`openspec/changes/stutter-detection-core/CLAUDE.md` 88 行总结让接手 session 的 AI 在 30 秒内还原:15/15 tasks done、26 tests green、真实 trace 数据(LOL 5660 帧 109 卡顿)、8 条不可重复验证的技术事实、本机 ETL 文件路径。**没有这个文件,接手 session 大约要 15-30 分钟重新探索**。

### 5A.2 跨 change:清空 vs 延续

一个 change 闭环结束(archive 后),判断:

| 情况 | 动作 |
|---|---|
| 下一个 change 和当前**无关** | `/clear` 清空上下文,干净开始 |
| 下一个 change 和当前**有关**(如同一 capability 的扩展) | 带着压缩后的上下文继续 |

**无关的判据**:不同 capability、不共享核心数据结构、不依赖刚写的内部 API。

**有关的判据**:同一 capability 的后续 change、要调用刚 archive 的 API、要修改刚写的 schema。

### 5A.3 SessionStart hook 兜底

新 session 启动时,CLAUDE.md 的 Session Start Protocol 指令引导 AI 主动读取 backlog.md + 扫描 openspec/changes/。

### 5A.4 不建议的做法

- ❌ 在一个超长 session 里跑完整个 change 不做任何 checkpoint——context 膨胀后 AI 会开始忘记 Hard Rules
- ❌ 把所有 change 的总结都写入根目录 CLAUDE.md——膨胀到无法使用
- ❌ /clear 后不做任何上下文恢复就开始下一个 change——AI 不知道项目状态

---

## 第 6 部分:小工程轻量分支

适用 1-5 天、500-5000 行、可能扩展的独立小工程。

**核心思路**:流程缩减,纪律不减。Hard Rules 全留,工件简化。

### 整体流程

```
[Brainstorm: Mode A or B] → [写 SPEC.md] → [你审一次] → [TDD apply]
   → [端到端真跑] → [SPEC.md + README]
```

### Step 0 — Brainstorm

按 Mode A 或 Mode B(详见第 4 部分)。收敛信号:你能用 2-3 句话说清"做什么、不做什么、关键决策"。

### Step 1 — SPEC.md 模板

```markdown
# <项目名> — SPEC

> 创建:2026-05-12  预期工时:3 天  生命周期:Y(可能扩展)

## Goal

<1-2 句话>

## Non-goals

明确不做:
- ...

## Decisions

| 决策 | 为什么 | 失效前提 |
|---|---|---|
| 用 Tauri 不用 Electron | bundle 小、性能好 | Tauri 1.x 缺关键 API |

## Brainstorm Log

- 方向:Markdown 文件存储 — 放弃:查询不便

## External APIs

| 库 | 用途 | 查证方式 | 查证日期 |
|---|---|---|---|
| @tauri-apps/api | Tauri runtime | npm 存在 + API 正确 | 2026-05-12 |

## Scenarios

### Requirement: 添加 todo

#### Scenario: 成功添加
GIVEN 应用启动且列表为空
WHEN 输入 "买牛奶" 按回车
THEN 列表显示 "买牛奶",done=false
AND SQLite 存在对应记录

#### Scenario: 空输入
GIVEN 应用启动
WHEN 按回车但输入框为空
THEN 不创建记录,无错误提示

## Tasks

- [ ] 1. setup: Tauri 项目初始化 + SQLite schema
- [ ] 2. test: GET todos returns []
- [ ] 3. impl: GET todos
- ...
- [ ] N: 端到端验证(实际打开应用、点击、看效果)
```

### Step 2 — 单层自审

```
对 SPEC.md 跑 yes/no 自查(独立 subagent):
- Goal 清晰且可向第三方解释?
- Non-goals 覆盖范围蠕变风险?
- Decisions 每条带"为什么"?
- External APIs 每个查证过(包存在 + API 签名 + 近期更新)?
- Scenarios 每个 Requirement 至少 1 success + 1 failure?
- Tasks 最后一项是端到端验证?
报告问题 + 3 条最不放心点。
```

通过后:

```bash
git add SPEC.md
git commit -m "spec: initial SPEC.md"
```

### Step 3 — TDD apply

按 SPEC.md Tasks 顺序逐个实施。每个 task:
1. 读对应 Scenario
2. 写 failing test → 红
3. 写最少代码让绿
4. code-reviewer 审 diff
5. 标 [x] + commit

每个 task 一次 commit。Hard Rules 全适用。

**上下文管理**:小工程通常 session 内能跑完。如果 task 超过 15 个,在中间做一次 checkpoint + /summarize,把总结写入 SPEC.md 末尾的 `## Progress Notes` 段。

### Step 4 — 端到端真跑

```
跑 superpowers verification-before-completion skill。
启动实际应用,跑核心 scenario,看到真实运行结果。
```

### Step 5 — README

```bash
git add README.md
git commit -m "docs: README"
```

### 6.1 跳过/保留的环节

| 跳过 | 为什么 |
|---|---|
| 8 步 propose | 复杂度撑不起 |
| PROTOCOL.md | 协议内容已内联在小工程 CLAUDE.md |
| Explore 独立阶段 | 与 Step 0 合并 |
| archive 合并主 spec | 没有主 spec |

| 保留 | 为什么 |
|---|---|
| Hard Rules | 痛点是 AI 缺陷,不是流程 |
| TDD | 防 j 核心 |
| 每 task 一次 commit | 防 g 最小成本 |
| code-reviewer | 防 c/d/e 核心 |
| 端到端真跑 | 防 j 终防线 |
| Decisions + Brainstorm Log | 防 h |
| External APIs 字段 | 防 b |
| Non-goals | 防 c |
| 独立 subagent 自审 | 防 i |

### 6.2 升级到中型流程的触发

任一发生即停下升级:
- Tasks 超过 30
- 出现第二个独立 capability
- 实施超过 5 天
- 决定长期严肃维护

升级动作:

1. `npx @fission-ai/openspec@latest init`
2. 拆 SPEC.md → proposal.md / design.md / spec.md / tasks.md(让 AI 一次性拆完:"`请按 PROTOCOL.md 的四件套格式拆分当前 SPEC.md,保持所有内容不丢失`")
3. 写 ARCHITECTURE.md + backlog.md
4. 替换 CLAUDE.md 为中型版,加入 PROTOCOL.md
5. `npx openspec validate` 确认格式
6. 后续按中型流程跑

---

## 第 7 部分:长期维护

### 7.1 Archive 后即时维护

已在 5.8 节定义:主 spec 健康自检 + Decisions 跟随 capability + 更新 backlog。

### 7.2 触发式 spec 审视

不预设月度节奏。出现以下信号时触发:
- 连续 2 个 change 在同 capability 上有冲突
- archive 自检发现矛盾或漂移
- 你回头看主 spec 觉得"看不懂自己写了什么"

### 7.3 阶段性 retrospective(可选)

完成 backlog 一整个 phase 后,如果你想,写一份 `openspec/retros/<date>-phase-N.md`。不强制。

### 7.4 工具链保鲜(季度)

- `npx @fission-ai/openspec@latest update`
- `/plugin update superpowers`
- `git log -- CLAUDE.md` 检查是否被 framework 偷改

---

## 第 8 部分:常见踩坑速查

| 症状 | 原因 | 解法 |
|---|---|---|
| propose 后又要写独立 plan | writing-plans 没禁用 | 检查 CLAUDE.md + PROTOCOL.md 在项目根、reload |
| Apply 跳过测试直接写代码 | TDD 协议没生效 | 显式说"按 CLAUDE.md Hard Rules" |
| Verify 总失败说 spec 没覆盖 | spec 写得太细超出实际功能 | propose 阶段平衡:完整但不超前 |
| Change > 3 天还没完 | 颗粒度太粗 | 停下,拆成新 change |
| AI 到 apply 后半段开始不遵守 Hard Rules | 上下文膨胀(防 f) | checkpoint 回跳 + /summarize + 写入子目录 CLAUDE.md |
| verify 通过但 drift | code-reviewer 没真在跑 / 端到端没真跑 | 检查 superpowers enabled、看到运行结果 |
| Propose AI 不问问题直接生成 | 进 Mode B 但其实需要 Mode A | 显式说"切到 Mode A,先 brainstorm" |
| AI 自审说"都通过"但你审出问题 | 痛点 i 发作 | 独立 subagent + 反向验证 + 3 条不放心点 |
| 跨 session AI 忘进度 | SessionStart hook 配错 | 检查 `.claude/settings.json`;手动 `! cat backlog.md` 兜底 |
| /clear 后 AI 不知道项目在哪 | 没利用子目录 CLAUDE.md | archive 前确保总结已写入;新 session 让 hook 注入状态 |
| Y 生命周期小工程长大后混乱 | 没及时升级到中型 | 触发信号出现立即升级 |

---

## 第 9 部分:完整示例 — 最小 TODO API

约 4-6 小时(第一次可能 8-12 小时)。

### 项目设定

```
TODO API:
- 单用户(不做认证)
- CRUD:创建/列表/更新/删除
- 字段:id, title, done, created_at
- 栈:Node.js + Express + SQLite
```

### Day 1: 启动(1 小时)

```bash
mkdir todo-api && cd todo-api
git init
npm init -y
npm install express better-sqlite3
npm install -D vitest supertest @types/node typescript

npx @fission-ai/openspec@latest init
```

放入 CLAUDE.md + PROTOCOL.md(中型模板)。启动 brainstorm → 落地 ARCHITECTURE.md + backlog.md。

```bash
git add . && git commit -m "chore: bootstrap todo-api"
```

### Day 1: Change 1 — todo-crud

#### 选定 + 判断模式

"5 个 endpoint 标准 CRUD,SQLite schema,输入验证 title 非空且 ≤ 200 codepoint,标准 HTTP 错误。" → **Mode B**

#### Propose Mode B → Apply → Verify + Polish + Archive

(流程同 5.1-5.8,此处省略重复。)

**上下文管理示例**:

```
[Task 1-8 完成] → checkpoint 到 change 开始 → /summarize
  → 总结写入 openspec/changes/todo-crud/CLAUDE.md
  → 继续 Task 9-20
[Task 20 完成] → checkpoint → /summarize → 更新同一个 CLAUDE.md
[Verify + Polish + Archive]
[下一个 change todo-list-filtering 和 todo-crud 有关]
  → 带着压缩后的上下文继续,不 /clear
```

---

## 附录 A:命令速查

```bash
# OpenSpec
npx @fission-ai/openspec@latest init    # 初始化
npx openspec validate <change-id>       # 校验格式
npx openspec list                       # 列出 active changes
npx openspec show <change-id>           # 查看详情
npx openspec view                       # 交互式 dashboard
npx @fission-ai/openspec@latest update  # 升级

# Slash commands
/opsx:explore                # 调研(显式声明)
/opsx:propose <change-id>    # 创建 change
/opsx:apply <change-id>      # 实施
# /opsx:verify <change-id>   # 当前 CLI 不存在,用 openspec validate 替代(见 5.6)
/opsx:archive <change-id>    # 归档(skill 不自动合并主 spec,见 5.8)

# Plugin
/plugin marketplace add <source>
/plugin install <name>
/plugin list
/plugin update <name>
/reload-plugins
```

---

## 附录 B:目录结构

**中型工程**:

```
my-project/
├── CLAUDE.md                    # 骨架:Stack + Hard Rules + 引用(≤ 40 行)
├── PROTOCOL.md                  # 完整 Skills Coordination Protocol
├── ARCHITECTURE.md
├── backlog.md
├── openspec/
│   ├── specs/                   # Living spec
│   │   └── auth/spec.md         # 含 Architectural Decisions 节
│   ├── changes/<current>/
│   │   ├── CLAUDE.md            # 该 change 的上下文总结(checkpoint 产物)
│   │   ├── proposal.md
│   │   ├── design.md            # 含 Decisions / Brainstorm Log / External APIs
│   │   ├── tasks.md
│   │   └── specs/<capability>/spec.md  # 含 Non-goals
│   ├── changes/archive/<date>-<id>/
│   └── retros/
├── .claude/skills/, settings.json
└── src/, tests/
```

**小工程**:

```
small-project/
├── CLAUDE.md      # 小工程版(含内联协议)
├── README.md
├── SPEC.md        # 全部 spec 内容
├── src/, tests/
└── .claude/
```

---

## 附录 C:客观评估

**真实优点**:
- 解决 AI 编程核心痛点:context drift、需求模糊、决策链丢失、虚假完成、过度抽象、上下文膨胀
- 职责分层:OpenSpec 管"做什么",superpowers 管"怎么做"
- CLAUDE.md 骨架 + PROTOCOL.md 分离:高频规则始终注入,低频协议按需加载
- Living spec 长期复利
- Mode A/B 双轨适配模糊和清晰
- checkpoint + 子目录 CLAUDE.md 总结注入:session 内上下文可控

**真实局限**:
1. 流程有开销——小修改走全流程过度。中型 change 是甜点,小工程用第 6 部分。
2. 对纪律要求高——70% 的成败取决于你愿不愿意在累的时候不偷懒。
3. 工具链脆弱——命令有效期约几个月。**思想留下,工具可能换**。
4. 时间估算偏乐观——第一次跑可能要 2 倍时间。
5. 不普适——巨型项目撑不住;游戏/嵌入式/ML 训练/C++安全等"边写边想"传统重的领域价值打折。
6. 仍是"人在 loop 中"——1-2 年可能出现更自主的 agent 方案。

---

## 附录 D:中型工程 CLAUDE.md 模板

```markdown
# Project: <你的项目名>

## Stack & Conventions

<按项目实际填写>

## Session Start Protocol

At the start of every new session, before responding:
1. Read `backlog.md` and `PROTOCOL.md`.
2. List `openspec/changes/` and identify any in-progress change.
3. If one exists, read its `tasks.md`, `CLAUDE.md`(if present), and specs.
4. Report current state in 1-2 lines, then ask what to do next.

## Hard Rules (always)

- No code change without a failing test first.
- No skipping the spec — stop and update spec or remove the behavior.
- Commit after each task. Never batch multiple tasks into one commit.
- Commit messages explain why and reference the task number.
- External libraries / APIs must be verified to exist before use.
- Key decisions must be recorded under `Decisions` with rationale.
- Self-review, code-review, verify must run in an isolated subagent.
- If confused or context unclear, STOP and ask, don't guess.

## Protocol

Detailed Skills Coordination Protocol is in `PROTOCOL.md`.
Before starting any phase (propose / apply / verify / archive), read it.
```

---

## 附录 E:中型工程 PROTOCOL.md 模板

```markdown
# Skills Coordination Protocol

This project uses OpenSpec as the spec layer and Superpowers as the execution
layer. This protocol is authoritative — both frameworks must defer to it.

## Phase: Brainstorming

- Project bootstrap: USE Superpowers `brainstorming` skill.
- Change-level Mode A (vague intent): USE `brainstorming`, scoped to change.
- Change-level Mode B (clear intent): DO NOT use `brainstorming`. User
  describes plan, AI replies yes/no checklist (accuracy, correctness, edges,
  error paths, implicit constraints). Qualifies for Mode B only if intent /
  boundaries / key decisions fit 2-3 sentences.

## Phase: Proposing

- USE `/opsx:propose` (or `/opsx:explore` first; state reason explicitly).
- DO NOT use `brainstorming` or `writing-plans` — propose IS the planning.
- All artifacts under `openspec/changes/<change-id>/`.
- `design.md` MUST include: `## Decisions` (rationale + "fails when ..."),
  `## Brainstorm Log`, `## External APIs` (each verified; training memory
  is not sufficient).
- `specs/<capability>/spec.md` MUST include `## Non-goals`.

## Phase: Self-review

Any review MUST run in an isolated subagent via Agent tool. The subagent acts
as a skeptical senior engineer: yes/no checklist, MUST list 3 least-confident
points even when passing.

## Phase: Implementing

When `/opsx:apply` is invoked:
1. `tasks.md` is the authoritative checklist. Do not regenerate plans.
2. For each unchecked task:
   a. Dispatch subagent (`subagent-driven-development`).
   b. Read relevant Given/When/Then scenarios.
   c. Strict TDD: failing test → red → minimal code → green → refactor.
   d. Run `code-reviewer` on diff.
   e. Pass → mark `[x]`, commit.
3. Do NOT invoke propose / explore during apply.

## Phase: Reviewing

After all tasks for a capability:
- `openspec validate --changes --strict` for spec format; AI then maps each
  Requirement/Scenario to its src + test, with file paths and method names
  (no "should be implemented" without evidence).
- ALSO `verification-before-completion` — start system, exercise scenarios.
  AI reports don't count; running output does.

## Phase: Polishing

- Run code-simplifier. Preserve behavior. Re-run e2e after polish.

## Phase: Archiving

Run `/opsx:archive` only after all tasks [x], verify passed, e2e passed,
polish done, all tests green, changes committed.

Immediately after:
- Health self-check on merged main spec.
- Append Decisions to main spec `## Architectural Decisions`.
- Update backlog (mark done; never delete).

## Context Management

- After completing a task/capability: checkpoint → /summarize → write
  summary into `openspec/changes/<change-id>/CLAUDE.md`.
- After archive: if next change unrelated → /clear; if related → continue
  with compressed context.
```

---

## 附录 F:小工程 CLAUDE.md 模板

```markdown
# Project: <你的项目名>

## Stack & Conventions

<按项目实际填写>

## Session Start Protocol

At the start of every new session:
1. Read `SPEC.md`, list unchecked tasks.
2. Report state in 1-2 lines, ask what to do next.

## Hard Rules (always)

- No code change without a failing test first.
- No skipping the spec — stop and update SPEC.md or remove the behavior.
- Commit after each task. Never batch multiple tasks into one commit.
- Commit messages explain why and reference the task number.
- External libraries / APIs must be verified to exist before use.
- Key decisions must be recorded under SPEC.md `Decisions`.
- Self-review, code-review, verify must run in an isolated subagent.
- If confused or context unclear, STOP and ask, don't guess.

## Skills Coordination Protocol

This project uses single-file `SPEC.md` as spec layer, Superpowers as
execution layer.

### Planning
- Vague intent → USE `brainstorming` skill.
- Clear intent → DO NOT use `brainstorming`. User describes, AI replies
  yes/no checklist.
- Plan written into SPEC.md (Goal, Non-goals, Decisions, Brainstorm Log,
  External APIs, Scenarios, Tasks; last task = e2e verification).

### Self-review
Isolated subagent, yes/no checklist, 3 least-confident points.

### Implementing
For each task: subagent → TDD → code-reviewer → mark [x] → commit.

### Verifying
`verification-before-completion` — start system, exercise scenarios.
AI reports don't count; running output does.

## Escalation

Stop and migrate to medium-project workflow if:
- Tasks exceed 30
- Second independent capability appears
- Implementation runs over 5 days
- Project becomes long-lived
```

---

## 附录 G:PreToolUse Hook 硬约束体系

### 设计原则

文本指令(CLAUDE.md / PROTOCOL.md)是"软约束"——AI 可能在 skill 的 MUST 指令下被覆盖。
PreToolUse Hook 是"硬约束"——代码层面拦截,AI 无法绕过。两者组合 = 双重保险。

| 原则 | 说明 |
|------|------|
| 只堵错路,不堵正路 | Hook 阻断/警告错误行为;正确路径由文本引导 |
| 通用性 | 脚本适用于所有 OpenSpec + Superpowers 项目,不含项目特定逻辑 |
| 不造成死锁 | 硬 block 仅限"该项目里永远不合法"的行为;有合法例外的用软警告 |
| 分层 | Tier 1 硬 block(exit 2) / Tier 2 软警告(exit 0 + stdout) |

### Tier 1:硬拦截(exit 非零 → 工具调用被阻断)

| 脚本 | Matcher | 拦截行为 | 原因 |
|------|---------|---------|------|
| `block-replaced-skills.ps1` | Skill | 阻断 `writing-plans` / `executing-plans` | OpenSpec 的 propose/apply 永久替代它们 |
| `block-superpowers-specs-dir.ps1` | Write | 阻断写入 `docs/superpowers/specs/` | brainstorming skill 默认路径;在 OpenSpec 项目里从来不对 |
| `block-unsafe-test-commands.ps1`(v3.5,模板化) | Bash | 阻断裸跑 test 命令(无 filter / 无 escape var) | 全套 heavy/integration 测试并发会爆 RAM/资源,见本附录 "Heavy-test 资源管理" 段 |

### Tier 2:软警告(exit 0 + stdout 输出警告)

| 脚本 | Matcher | 警告行为 | 合法例外 |
|------|---------|---------|---------|
| `warn-apply-phase.ps1` | Skill | apply 进行中调了 propose/explore | 用户明确要求回去改 spec |
| `warn-destructive-git.ps1` | Bash | 检测到 `git reset --hard` / `push --force` / `checkout .` 等 | 用户明确要求 |

### 部署

文件结构:

```
.claude/
├── settings.json          ← hook 注册(PreToolUse 配置)
└── scripts/
    ├── block-replaced-skills.ps1
    ├── block-superpowers-specs-dir.ps1
    ├── block-unsafe-test-commands.ps1   ← 仅重型测试项目;模板填充后部署,见本附录 "Heavy-test 资源管理" 段
    ├── warn-apply-phase.ps1
    └── warn-destructive-git.ps1
```

`settings.json` 配置:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Skill",
        "hooks": [
          { "type": "command", "command": "powershell -NoProfile -File .claude/scripts/block-replaced-skills.ps1" },
          { "type": "command", "command": "powershell -NoProfile -File .claude/scripts/warn-apply-phase.ps1" }
        ]
      },
      {
        "matcher": "Write",
        "hooks": [
          { "type": "command", "command": "powershell -NoProfile -File .claude/scripts/block-superpowers-specs-dir.ps1" }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "powershell -NoProfile -File .claude/scripts/warn-destructive-git.ps1" }
        ]
      }
    ]
  }
}
```

### 不做 Hook 的约束(及原因)

| 软约束 | 为什么不做 |
|--------|-----------|
| TDD:先写测试再写实现 | 无法判定"这次 Write 是实现代码还是接口/模型/配置";refactoring 时测试已存在 |
| Self-review 必须用 subagent | Hook 无法区分主 session vs subagent(都跑在独立进程里) |
| Commit message 格式 | 格式因项目而异,通用 hook 太松或太严 |
| External API 验证 | 无法自动判定"这段代码调了未验证的 API" |
| Checkpoint 时机 | 需计算 task 完成百分比 + 判断上次 checkpoint 时间,过于复杂 |

### 验证 Hook 生效

```bash
# 新 session 中尝试触发 block(应该收到 BLOCKED 错误):
# 在对话中说"请调用 writing-plans skill"

# 检查 settings.json 语法:
powershell -Command "Get-Content .claude/settings.json | ConvertFrom-Json"
```

### 扩展

添加新规则:
1. 在 `.claude/scripts/` 新建 `.ps1` 脚本
2. 在 `settings.json` 的对应 matcher 下注册
3. 硬 block 用 `exit 2` + stderr;软警告用 `exit 0` + stdout

如需 SessionStart hook(如 AI 被证明不遵循 Session Start Protocol 文本),可同理在
settings.json 中注册 `"SessionStart"` matcher,脚本输出 backlog + active change 状态。
当前不建议:CLAUDE.md 文本协议已被 2+ session 实证有效,加 hook 带来上下文噪音但无增量价值。

### Heavy-test 资源管理(跨工程通用模式,v3.5 新增)

**问题模式**:测试套件里有"重型测试"(加载 GB 级数据 / 起容器 / 拉真实数据库 / e2e
浏览器),AI 默认裸跑全套 → 触发重型测试 + xUnit/pytest/jest 默认按 class/file
并发 → 内存或资源爆炸 → 用户机器卡死。本工程 2026-06-01 实证:Apply 阶段一个
subagent 在自审里裸跑 `dotnet test`,RealEtl 集成测试三个类并发加载多 GB ETL,
RAM 90%+,用户机器冻结数分钟。

**通用度**:跨语言跨栈普遍存在
- .NET:`dotnet test` 触发 ETL / 数据库 integration tests
- Python:`pytest` 触发 docker-compose / external API tests
- Node:`npm test` / `jest` 触发 e2e headless 浏览器
- Go:`go test ./...` 触发 testcontainers / 真 IO 测试
- Rust:`cargo test` 触发 `#[ignore]` 之外的真实 IO

#### 四种策略对比

新工程骨架阶段(WORKFLOW 第 3 部分)主动评估,按项目特征选一套或组合:

| 策略 | 工程量 | 可靠性 | 适用 | 维护成本 |
|---|---|---|---|---|
| **A. 命名约定 + 文档** | 0(只写文档) | 低(靠自觉) | trivial 项目 / 无 subagent | 0 |
| **B. 测试框架 marker / Trait / build tag** | 0.5-1 小时 | 高(结构性,默认就不跑) | 可控测试代码、CI 已规范化 | 低(写测试时记得贴标记) |
| **C. 测试 runner 配置默认排除** | 0.5 小时 | 中(可被 `--run-all` 覆盖) | 中型项目 | 低 |
| **D. PreToolUse hook 物理拦截** | 0.5-1 小时 | 最高(AI/subagent 改不了) | 跨 session、subagent 多、AI 自动化高 | 中(项目特异脚本需要维护) |

#### Day-1 决策路径

骨架阶段 Step 4 之前,问自己 3 个问题:

1. **本项目有没有"重型测试"**(单测试 RAM > 200MB / 起外部依赖 / e2e)?
   - 没有 → 跳过本节
   - 有 → 进入问题 2

2. **测试代码我能改吗**(不在 archived spec 范围、CI 不会 break)?
   - 能 → 优先 **B**(写测试时贴 marker,从源头解决)
   - 不能改老测试、新测试可控 → **B + C 组合**(老测试 runner 排除,新测试贴 marker)
   - 完全不能改 → **D**

3. **会派 subagent 跑测试吗**(apply 阶段、verify 阶段)?
   - 会 → **必须叠加 D**(subagent prompt 文本约束被实证不可靠;hook 才是物理保障)
   - 不会(全程主 session 手动跑)→ B/C 足够

**经验**:OpenSpec + Superpowers 工作流的 apply 阶段会大量派 subagent,绝大多数项目
最终都需要 **D**(可叠加 B 作为深度防御)。本工程目前用 **D 单层**(测试代码改造留给
独立的基础设施 change)。

#### 具体实现:策略 D PreToolUse hook 模板

模板脚本见 "完整脚本源码 / `.claude/scripts/block-unsafe-test-commands-TEMPLATE.ps1`"
(本附录末尾)。

落地步骤(新项目骨架阶段):

1. **填三个空**(项目特异参数):
   - `<TEST_CMD_REGEX>` — 拦截哪个测试命令的正则(如 `\bdotnet\s+test\b` /
     `\bpytest\b` / `\bgo\s+test\b` / `\bnpm\s+test\b`)
   - `<SAFE_FILTER_REGEX>` — 哪些参数表示"已 scoped"(如 `--filter\b` /
     `\s-k\s` / `\s-run\s` / `--testNamePattern\b`)
   - `<ESCAPE_VAR>` — 应急通道环境变量名(项目特异,如 `MYPROJECT_ALLOW_FULL_TEST`)

2. **复制脚本到 `.claude/scripts/block-unsafe-test-commands.ps1`**(去掉 `-TEMPLATE`
   后缀)

3. **`.claude/settings.json` Bash matcher 加挂载**:
   ```json
   {
     "matcher": "Bash",
     "hooks": [
       {
         "type": "command",
         "command": "powershell -NoProfile -File .claude/scripts/block-unsafe-test-commands.ps1"
       }
     ]
   }
   ```

4. **PROTOCOL.md 加 hard rule 段**(模板见下),hook 错误消息回链此段

5. **验证四个用例**(本工程实测过的):
   ```bash
   # Test 1: 裸命令应 block
   echo '{"tool_input":{"command":"<TEST_CMD>"}}' | powershell -NoProfile -File .claude/scripts/block-unsafe-test-commands.ps1
   echo "exit=$?"  # 期望 2

   # Test 2: filter 过的应放
   echo '{"tool_input":{"command":"<TEST_CMD> <SAFE_FILTER_EXAMPLE>"}}' | powershell -NoProfile -File ...
   # 期望 0

   # Test 3: 应急通道应放
   echo '{"tool_input":{"command":"<ESCAPE_VAR>=1 <TEST_CMD>"}}' | powershell ...
   # 期望 0

   # Test 4: 非测试命令应放
   echo '{"tool_input":{"command":"<BUILD_CMD>"}}' | powershell ...
   # 期望 0
   ```

#### PROTOCOL.md hard rule 段模板

加在 PROTOCOL.md 现有段(如 ## Phase: Mid-term Value Review)之后:

```markdown
## Test Command Discipline (Hard Rule, cross-change)

This project's `<TEST_FOLDER>` hosts heavy/integration tests
(`<EXAMPLE_TEST_CLASS_1>`, `<EXAMPLE_TEST_CLASS_2>`) that <RESOURCE_PRESSURE_DESC>.
<TEST_FRAMEWORK>'s default parallelism makes a bare `<TEST_CMD>` invoke them
concurrently → <CRASH_DESC> (实证 <DATE> <CHANGE_ID> apply).

Hard rules (enforced by `.claude/scripts/block-unsafe-test-commands.ps1`
PreToolUse hook on Bash):

1. Bare `<TEST_CMD>` is blocked. All `<TEST_CMD>` invocations MUST include
   a <SAFE_FILTER_FLAG> clause OR set the `<ESCAPE_VAR>=1` environment variable.
2. Subagents MUST NOT set `<ESCAPE_VAR>=1`. Only main-loop Claude may set
   it, and only after the human has explicitly approved a full-suite run
   (verify, archive prep). Subagent prompts must include this constraint.
3. Default safe filters for routine apply work:
   - <FILTER_EXAMPLE_1>
   - <FILTER_EXAMPLE_2>
   - <FILTER_EXAMPLE_EXCLUDE>
4. subagent-driven-development skill prompts MUST include a "Hard Rule —
   Test Command Constraint" section restating rules 1+2 verbatim.
```

#### 实证

2026-06-01 本工程 Group 1 apply 期间内存炸机 → 2026-06-02 落地策略 D + PROTOCOL.md
hard rule。Group 2 + R3 期间 11 次测试调用 0 次内存事件,实证:
- subagent 派发 prompt 自带"测试命令纪律"段(WORKFLOW.md 推动)
- hook 兜底拦住任何漏写约束的 subagent 或主 session 的疏忽
- 应急通道(`STUTTER_ALLOW_FULL_TEST=1`)留给 Group 9 verify 阶段,subagent 不许用

后续若 LOL trace 改造、Report.Tests 性能调查(backlog 3b)做完,可以撤回到策略
B/C(测试代码层加 Trait + runner 默认排除),hook 作为深度防御保留。

### 完整脚本源码(可直接复制到新项目)

#### `.claude/scripts/block-replaced-skills.ps1`

```powershell
# Tier 1 Hard Block: Skills replaced by OpenSpec equivalents.
# In any project using OpenSpec + Superpowers workflow, these skills are
# permanently replaced and should never be invoked:
#   - writing-plans    -> /opsx:propose generates design.md + tasks.md
#   - executing-plans  -> /opsx:apply walks tasks.md with TDD
#
# This hook fires on PreToolUse for the Skill tool.
# Exit 2 = block the tool call; stderr shown to Claude as error.

$json = [Console]::In.ReadToEnd() | ConvertFrom-Json
$skill = $json.tool_input.skill

$blocklist = @{
    'superpowers:writing-plans'   = 'Per PROTOCOL.md: use /opsx:propose instead. Propose IS the planning phase — it generates design.md, tasks.md, and specs.'
    'superpowers:executing-plans' = 'Per PROTOCOL.md: use /opsx:apply instead. Apply walks tasks.md with strict TDD.'
}

if ($blocklist.ContainsKey($skill)) {
    [Console]::Error.WriteLine("BLOCKED: $($blocklist[$skill])")
    exit 2
}

exit 0
```

#### `.claude/scripts/block-superpowers-specs-dir.ps1`

```powershell
# Tier 1 Hard Block: Prevent writing design docs to superpowers default path.
# In OpenSpec projects, all spec/design artifacts go to:
#   openspec/changes/<change-id>/   (active)
#   openspec/specs/<capability>/    (archived living spec)
# The brainstorming skill's default output path (docs/superpowers/specs/) is
# never correct and indicates the skill's built-in steps 6-9 are being followed
# instead of the project's PROTOCOL.md.
#
# This hook fires on PreToolUse for the Write tool.
# Exit 2 = block the tool call.

$json = [Console]::In.ReadToEnd() | ConvertFrom-Json
$path = $json.tool_input.file_path

if ($path -match 'docs[/\\]superpowers[/\\]specs') {
    [Console]::Error.WriteLine("BLOCKED: Do not write to docs/superpowers/specs/. In OpenSpec projects, design docs are generated by /opsx:propose under openspec/changes/<change-id>/design.md. Living specs go to openspec/specs/<capability>/spec.md after archive.")
    exit 2
}

exit 0
```

#### `.claude/scripts/warn-apply-phase.ps1`

```powershell
# Tier 2 Soft Warning: Detect propose/explore invocation during apply phase.
# Per PROTOCOL.md: "Do NOT invoke propose / explore during apply."
# Exception: user explicitly requests going back to fix spec (WORKFLOW.md 5.5).
#
# Detection heuristic: if any active change's tasks.md has both [x] (started)
# and [ ] (not done) items, apply is likely in progress.
#
# This hook fires on PreToolUse for the Skill tool.
# Exit 0 always (soft warning only); stdout warning shown to Claude.

$json = [Console]::In.ReadToEnd() | ConvertFrom-Json
$skill = $json.tool_input.skill

# Only check for propose/explore skills
$watchlist = @(
    'opsx:propose',
    'opsx:explore',
    'openspec-propose',
    'openspec-explore'
)

if ($skill -notin $watchlist) {
    exit 0
}

# Check if any active change is in apply phase
$changesDir = Join-Path $PWD 'openspec/changes'
if (-not (Test-Path $changesDir)) { exit 0 }

$activeChanges = Get-ChildItem $changesDir -Directory -Exclude 'archive' -ErrorAction SilentlyContinue
foreach ($change in $activeChanges) {
    $tasksFile = Join-Path $change.FullName 'tasks.md'
    if (Test-Path $tasksFile) {
        $content = Get-Content $tasksFile -Raw -ErrorAction SilentlyContinue
        if ($content -match '\[x\]' -and $content -match '\[ \]') {
            Write-Output ""
            Write-Output "WARNING: Apply phase appears in progress for change '$($change.Name)' (tasks.md has both completed and pending items)."
            Write-Output "Per PROTOCOL.md: Do NOT invoke propose/explore during apply unless the user explicitly asked to go back and fix the spec."
            Write-Output "If the user did NOT ask for this, STOP and return to tasks.md."
            Write-Output ""
            exit 0
        }
    }
}

exit 0
```

#### `.claude/scripts/warn-destructive-git.ps1`

```powershell
# Tier 2 Soft Warning: Detect destructive git operations.
# These commands can cause irreversible data loss. They should only run when
# the user has EXPLICITLY requested them.
#
# Detected patterns:
#   git reset --hard
#   git push --force / git push -f
#   git checkout .  / git checkout -- .
#   git restore .
#   git clean -f
#   git branch -D
#
# This hook fires on PreToolUse for the Bash tool.
# Exit 0 always (soft warning only); stdout warning shown to Claude.

$json = [Console]::In.ReadToEnd() | ConvertFrom-Json
$cmd = $json.tool_input.command

# Patterns for destructive git operations
$destructivePatterns = @(
    'git\s+reset\s+--hard',
    'git\s+push\s+--force',
    'git\s+push\s+-f\b',
    'git\s+checkout\s+\.',
    'git\s+checkout\s+--\s*\.',
    'git\s+restore\s+\.',
    'git\s+clean\s+-[a-zA-Z]*f',
    'git\s+branch\s+-D\b'
)

foreach ($pattern in $destructivePatterns) {
    if ($cmd -match $pattern) {
        Write-Output ""
        Write-Output "WARNING: Destructive git operation detected: '$cmd'"
        Write-Output "This command can cause irreversible data loss."
        Write-Output "Only proceed if the USER explicitly requested this exact operation."
        Write-Output "If you decided this on your own, STOP and find a safer alternative."
        Write-Output ""
        exit 0
    }
}

exit 0
```

#### `.claude/scripts/block-unsafe-test-commands-TEMPLATE.ps1`(v3.5 新增)

参数化模板。新项目复制后填三个 `<...>` 占位符,改文件名去掉 `-TEMPLATE`,在
`.claude/settings.json` Bash matcher 注册即可。

```powershell
# block-unsafe-test-commands.ps1
# Tier 1 Hard Block: bare test runner invocations trigger heavy/integration
# tests that load multi-GB data / start containers / spawn e2e browsers in
# parallel and crash the user's machine. This hook prevents recurrence
# across all changes / sessions.
#
# PROJECT CUSTOMIZATION (fill these three placeholders before deploying):
#   <TEST_CMD_REGEX>      regex matching the bare test command, e.g.:
#                           '\bdotnet\s+test\b'      (.NET)
#                           '\bpytest\b'              (Python)
#                           '\bgo\s+test\b'           (Go)
#                           '\bnpm\s+(?:test|run\s+test)\b'  (Node)
#                           '\bcargo\s+test\b'        (Rust)
#   <SAFE_FILTER_REGEX>   regex matching presence of a scope-narrowing flag:
#                           '--filter\b'              (.NET)
#                           '\s-k\s'                  (pytest)
#                           '\s-run\s'                (Go)
#                           '--testNamePattern\b'     (Jest)
#                           '\s--\s.*\btest::'        (Cargo, partial)
#   <ESCAPE_VAR>          project-specific env var name authorising full runs,
#                           e.g. MYPROJECT_ALLOW_FULL_TEST. Avoid generic names
#                           like ALLOW_FULL_TEST to reduce collision risk.
#
# Block rule:
#   <TEST_CMD> with NO <SAFE_FILTER> AND NO <ESCAPE_VAR>=1 → block.
#
# Allow rules:
#   <TEST_CMD> with --filter / -k / etc.       → allowed (scoped run)
#   <ESCAPE_VAR>=1 <TEST_CMD>                  → allowed (explicit auth)
#   any non-test command                       → allowed
#
# Subagent rule:
#   Subagents MUST NEVER set <ESCAPE_VAR>=1 on their own. Only the human or
#   main-loop Claude (after the human has explicitly authorised a full run)
#   may set it. Restated in subagent prompt boilerplate.
#
# Reference (point to your project's location):
#   PROTOCOL.md ## Test Command Discipline (Hard Rule, cross-change)
#
# Exit 2 = block; stderr shown to Claude as error.

$json = [Console]::In.ReadToEnd() | ConvertFrom-Json
$cmd = $json.tool_input.command

if (-not $cmd) {
    exit 0
}

# Only inspect commands that actually invoke the test runner.
if ($cmd -notmatch '<TEST_CMD_REGEX>') {
    exit 0
}

# Escape hatch: explicit user authorisation via env var prefix.
if ($cmd -match '<ESCAPE_VAR>\s*=\s*1' -or
    $cmd -match '\$env:<ESCAPE_VAR>\s*=\s*[''"]?1') {
    exit 0
}

# Allow if a scope-narrowing flag is present.
if ($cmd -match '<SAFE_FILTER_REGEX>') {
    exit 0
}

# All other invocations are bare full-suite runs → block.
[Console]::Error.WriteLine(@"
BLOCKED: bare test command is forbidden in this project.

Reason: full-suite runs trigger heavy/integration tests that consume
significant resources (RAM / containers / external services) concurrently
and can crash the user's machine.

Use one of these instead:

  # Scoped to specific test classes — fast, safe:
  <TEST_CMD> <SAFE_FILTER_EXAMPLE>

If you GENUINELY need a full-suite run (verify phase, archive prep, after
human authorisation), prefix the command:

  <ESCAPE_VAR>=1 <TEST_CMD> ...

Subagents MUST NOT set this variable on their own. Only the main-loop Claude
may set it after the human has explicitly approved a full run for this
specific moment.

See: PROTOCOL.md ## Test Command Discipline
"@)

exit 2
```

#### 本工程实例(参考):`.claude/scripts/block-unsafe-test-commands.ps1`

填充示例(StutterAnalyzer .NET 项目):
- `<TEST_CMD_REGEX>` → `\bdotnet\s+test\b`
- `<SAFE_FILTER_REGEX>` → `--filter\b`
- `<ESCAPE_VAR>` → `STUTTER_ALLOW_FULL_TEST`

完整文件已在仓库 `.claude/scripts/block-unsafe-test-commands.ps1`,可作为参考实现。

---

## 附录 H:版本与作者备注

- **文档版本**:v3.6(2026-06)
- **基于工具版本**:OpenSpec v1.x(Fission-AI)、superpowers(Jesse Vincent / obra)
- **v3.6 变更(基于 primary-source-attribution Group 1-3 实证,2026-06-02)**:
  - **PROTOCOL.md Phase: Implementing 2.a**:subagent prompt 必须 restate 项目硬约束——Group 1 内存炸机根因是 prompt 里没复述约束,靠"AI 记得"靠不住;新增"Rationale"段解释为什么
  - **PROTOCOL.md Phase: Reviewing**:新增实证注释"Spec + code dual-reviewer is mandatory, not ceremonial"——Group 2 review 抓出 6/10 真问题(60%+ hit rate),证明 review 不是仪式
  - **5.4.1 R-revision 链**:新增完整小节,定义 R1/R2/R3... 的命名规则、append-only 纪律、触发条件(spec-vs-code 矛盾 / spec 内部矛盾 / 实测数据推翻假设 / 用户拍板)、引用规范、不回退已完成 checkbox 的原则;附 primary-source-attribution 三次 R-revision 实证
  - **5A.1 checkpoint 时机第 4 条**:上下文使用量 60-70% 也是强制 checkpoint 信号(独立于 task 完成百分比);附 R3 spec 改造 68% 实证
  - 触发条件:backlog.md 载明"Group 3 task 3.6c GREEN 完成后触发 WORKFLOW.md v3.6"
  - 不动:CLAUDE.md 骨架(Hard Rules 精炼不膨胀)
- **v3.5 变更(基于 primary-source-attribution Group 1 内存炸机实证,2026-06-02)**:
  - 附录 G 新增 "Heavy-test 资源管理(跨工程通用模式)" 段:抽象本工程踩过的 RAM 爆炸坑为跨语言跨栈通用模式
  - 提供 4 种策略对比(命名约定 / 框架 marker / runner 配置 / hook 拦截)+ day-1 决策路径(3 个问题决定选哪种 / 是否叠加)
  - 新增模板脚本 `block-unsafe-test-commands-TEMPLATE.ps1` 参数化 3 个占位符(`<TEST_CMD_REGEX>` / `<SAFE_FILTER_REGEX>` / `<ESCAPE_VAR>`),覆盖 .NET / Python / Go / Node / Rust 5 个测试栈的填充示例
  - 新增 PROTOCOL.md hard rule 段模板 + 4 用例验证流程
  - 触发场景:Group 1 apply 期间 subagent 在自审里裸跑 `dotnet test`,RealEtl 三类并发加载多 GB ETL,RAM 90%+,机器冻结数分钟。Group 2 + R3 期间 11 次测试调用 0 内存事件验证策略 D 有效
  - 痛点防御映射:补 b(subagent 默认行为绕过文本约束)在物理工具调用层的兜底——文本约束有 ≠ subagent 遵守
  - 不动:CLAUDE.md / PROTOCOL.md(此模式属基础设施层,Hard Rules 骨架不污染)
- **v3.4 变更(基于 causal-chain-enhancements-core 收尾实证,2026-05-29)**:
  - 5.4 Step 8 增加"实证教训 + 强制自检"段:propose commit 后必须跑 `git ls-files openspec/changes/<change-id>/` 验证最小全集(.openspec.yaml / proposal.md / design.md / tasks.md / specs/<capability>/spec.md),少一立即补 commit
  - 触发场景:本 change propose 阶段疑似只 `git add tasks.md` 漏 add 其余 5 个文件,直到 archive 前(verify 后)才发现,导致 verify 阶段所谓的"specs delta 100% 覆盖"基于磁盘文件而非 git 历史,需要在收尾时补一个 `docs: track openspec propose artifacts` 修复 commit
  - 不动 CLAUDE.md / PROTOCOL.md(此教训属操作纪律层面,Hard Rules 骨架已隐含"no skipping the spec",不需扩张)
  - 痛点防御映射:补 a(context drift)在 git 维度的兜底——磁盘有 ≠ 仓库有
- **v3.3 变更(基于 causal-chain-engine brainstorm 实证,2026-05-26)**:
  - 新增附录 G:PreToolUse Hook 硬约束体系——通过代码层面拦截解决"AI 不严格遵循文本约束"的根本问题
  - Tier 1 硬 block:writing-plans / executing-plans skill 调用、docs/superpowers/specs/ 写入
  - Tier 2 软警告:apply 阶段误调 propose/explore、破坏性 git 操作
  - PROTOCOL.md Phase: Brainstorming 新增 EXIT OVERRIDE 段(文本引导 + hook 硬约束双保险)
  - 删除原附录 G(SessionStart Hook):与 CLAUDE.md Session Start Protocol 文本 100% 重复,2 个 session 实证未发现文本协议失效
  - 附录编号整理:hooks → 附录 G,版本备注 → 附录 H;修复预存的模板引用错误(附录 E-G → D-F)
  - 痛点防御表新增映射:hook 硬约束覆盖 "AI 不遵循文本指令" 这一 meta-缺陷
- **v3.2 变更(基于 stutter-detection-core 首次完整闭环实证,2026-05-25)**:
  - 5.5 节:增加 5.5.1 commit 颗粒度判据(强耦合声明性 task 可合并,跨关注点必须分开),不进 CLAUDE.md Hard Rule 以保持骨架精炼
  - 5.6 节:删除不存在的 `/opsx:verify` 命令,改为 `openspec validate --changes --strict` + AI 主动逐条核查 + verification-before-completion skill
  - 5.7 节:polish 拆为代码级(code-simplifier) + 工件级(spec/文档清理),实证表明 spec dupe scenario 这类问题 code-simplifier 抓不到
  - 5.8 节:描述与 OpenSpec CLI 实际行为对齐;增加首次 archive 的 seed 操作和 `## Purpose` 段强制要求(缺失会 fail validate);增加 Decisions 的 Source 标注规范和 Superseded 改写规则
  - 5A.1 节:checkpoint 时机从"建议每 task 后"硬化为"三处强制 + 一处可选",附加 stutter-detection-core 实证
  - 附录 A:删除 `/opsx:verify` 和 `/opsx:sync`(后者本工程无实际触发场景),其余命令保留
  - **不动**:CLAUDE.md / PROTOCOL.md(保护 Hard Rules 骨架不冗长化);External APIs 强制查证、独立 subagent 自审、TDD 本体、code-reviewer、Non-goals 等对抗 AI 痛点的核心条款
- **v3 主要变更**:
  - CLAUDE.md 拆分为骨架(≤ 40 行)+ PROTOCOL.md,提升 AI 对 Hard Rules 的遵循度
  - 新增第 5A 部分上下文管理策略:checkpoint + 子目录 CLAUDE.md 总结注入
  - 痛点表补齐编号 f(session 内上下文膨胀)
  - External APIs 查证标准明确化
  - Mode B checklist 从"不允许开放回应"改为"以 yes/no 开头,允许简短补充"
  - SessionStart hook 改为调用独立脚本,消除内联长命令的转义脆弱性
  - 小工程升级动作增加 AI 辅助拆分 prompt
  - 清理文档中的本机绝对路径引用
- **重要免责**:作者没有在 30+ change 的真实生产项目上跑过完整流程。时间估算基于工具文档、社区博客和合理推断。**你的真实经验应覆盖本文档。**
