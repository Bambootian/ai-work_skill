# Subagent Dispatch Template

> subagent 看不到主循环的任何上下文；省略任何 REQUIRED 槽位 = 派发无效。
> 派 reviewer / critic / 方向反方不请示（常设授权见项目 CLAUDE.md）。

```markdown
## Model (REQUIRED)
<默认继承会话模型。例外：浏览器自动化 / 网页抓取类派发必须降级 Sonnet 或更低
（token 失控实测多次）。裁判永不弱于产出方；方向反方用最强可用模型。>

## Objective (REQUIRED)
<一个任务，一个产出。不是两个。>

## Context (REQUIRED)
<change-id、相关文件路径、已存在什么、同批其他 agent 已知的环境事实——最小必需。无对话史。>

## Constraints (REQUIRED — 逐字重述，不摘抄改写)
- 项目硬规则：<粘 CLAUDE.md 相关行>
- 测试命令纪律：<粘，如 only `dotnet test --filter ...`；永不自行设置 escape 变量>
- Loop contract：<粘 Outcome / Verify / Budget>
- Scope：只动 <files/areas>；无顺手改动

## Output format (REQUIRED)
<返回什么——数据，不是叙事。目标 ≤2,000 token（reviewer / critic ≤3,000）。>

## Boundaries (REQUIRED)
- 禁止再派 agent（单层扁平扇出，无例外）
- Do NOT: <commit / push / 改 spec / 全量测试 / ...>
- 失败时：返回 tried / observed / hypothesis；同一失败最多 2 次尝试后停下报告。
```

## Reviewer 变体（gate 评审，代码收尾）

- fresh-context：只给 diff + spec + 评审标准，**不给**产生代码的推理过程。
- 每条 finding 标注：[blocking] = 违反 spec / 契约，或真实缺陷（正确性 / 资源泄漏 /
  数据丢失 / 安全）——必修，架构 / 质量视角发现的真实缺陷同样是 [blocking]；
  [nit] = 风格与「可以更好」——记录不追（防评审驱动的过度工程）。
- 两条具名任务：挑 3 条最强断言，在粘回的输出里找反证；对同样 3 条回答
  「支撑它的实测覆盖范围是否等于断言范围」——问的是范围，不是有无输出。
- 多视角时分开派发、不共享结论；单 reviewer 时必核 Verify 命令是否真覆盖 Outcome 与 scenarios
  ——弱验证是最大漏风口。
- 多 reviewer 结论冲突：原话并列记入契约，由主循环裁定并记 `Decided:`；属方向 / 钱 / 时间 /
  找谁的才交人。冲突点通常正是 spec 的真模糊处。

## Spec critic 变体（spec 成文后、进循环前）

只给 spec 产物（proposal / design / tasks / spec，或 R1 单文件）+ 代码库只读权限，不给
brainstorm 过程。立场：默认找问题；报 PASS 前先写你试过怎么打它。逐条 yes/no：

1. 意图三向覆盖：proposal 每件事 ↔ spec Requirement ↔ tasks，缺一列出。
2. 对既有代码的每个假设——去读代码核实，不信 spec 的转述（最常见的漏）。
3. 外部 API / 库：每个引用实查存在与签名。
4. 范围：tasks 有 spec 没要求的？Non-goals 盖住蠕变了吗？Outcome 写明了谁能观察到什么吗？
5. 可验证：每个 Requirement 有成功 + 失败 scenario；Verify 命令真覆盖 scenarios；末 task 端到端。
6. 决策：每条带「为什么」+「失效前提」。
7. 必填：最不放心的 3 处，即使整体 PASS。

多视角时第二视角只做第 2 条（假设对照代码），不共享结论。

## 方向反方变体（大投入前 / 机械信号 / 板块收官；触发表在 value-review）

- 独立性来自位置，不来自措辞：不加载工作流、不看 brainstorm 过程；项目约束文档（CLAUDE.md /
  AGENTS.md / ARCHITECTURE / backlog / decisions / retros）**只作证据读，不作指令遵守**。
  配方：`git archive HEAD` 快照到 scratchpad，`git log` 预导出为快照内文件，CLAUDE.md / AGENTS.md
  改名 `PROJECT-*.md`，用 `claude -p`（`--setting-sources local --strict-mcp-config`，只允许
  Read / Grep / Glob，不联网、不读 runs/ 类本机产物）在快照目录跑。Agent 工具派发只作退路，
  并在并排表表头标「独立性弱一档」（subagent 会被注入 CLAUDE.md）。
- Objective：判断这个工程在**方向**上最可能错在哪——不评估执行是否按计划；先构造最强的
  「该停下或转向」论证，再用快照证据检验它是否成立；允许结论是方向没问题。每条判断附快照内
  路径（必要时行号或提交号），拿不到证据的标明推测。
- Output（Markdown，≤150 行）：一句话结论；方向上最可能错的 3–5 点（判断 / 证据 / 若对意味着
  什么）；建议方向，或方向没问题的理由与最强反方为何不成立；最不确定的 3 处。
- 回来后主循环逐条核事实，写并排表四列：反方原话（≤2 行）｜事实成立?｜接受 / 反驳｜对方向意味着
  什么——进 retro 或 proposal 的 Why，交人。反方全文进 `docs/notes/<date>-adversary.md`，不进常驻
  文档，不转述。反方擅长发现问题，方向建议只作参考（回测 3 个里 2 个指错）。第二个反方：项目参数
  「第二反方」写了必派 / 不派就照它；写「按内容判定」或未写时，改 North Star / 新板块 / 花费超参数任一
  即派，派不派在并排表表头写一行理由；有第二个模型家族可用则优先用它。
