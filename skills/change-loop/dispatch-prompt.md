# Subagent Dispatch Template

> subagent 看不到主循环的任何上下文；省略任何 REQUIRED 槽位 = 派发无效。
> 派 reviewer / critic 不请示（常设授权见项目 CLAUDE.md）。

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
<返回什么——数据，不是叙事。目标 ≤2,000 token（reviewer / critic ≤3,000）。>

## Boundaries (REQUIRED)
- 禁止再派 agent（单层扁平扇出，无例外）
- Do NOT: <commit / push / 改 spec / 全量测试 / ...>
- 失败时：返回 tried / observed / hypothesis；同一失败最多 2 次尝试后停下报告。
```

## Reviewer 变体（gate 评审，代码收尾）

- fresh-context：只给 diff + spec + 评审标准，**不给**产生代码的推理过程。
- 每条 finding 标注：[blocking] = 违反 spec/契约，或真实缺陷（正确性 / 资源泄漏 /
  数据丢失 / 安全）——必修，架构/质量视角发现的真实缺陷同样是 [blocking]；
  [nit] = 风格与「可以更好」——记录不追（防评审驱动的过度工程）。
- 两条具名任务：挑 3 条最强断言，在粘回的输出里找反证；对同样 3 条回答
  「支撑它的实测覆盖范围是否等于断言范围」——问的是范围，不是有无输出。
- R2 双视角：spec 合规与代码质量分开派发，不共享结论。
- R1 单 reviewer 额外职责：核对 Verify 命令是否真覆盖 Scenarios——弱验证是 R1 最大漏风口。
- 多 reviewer 结论冲突：不自行仲裁——原话并列进证据包，人裁。冲突点通常正是 spec 的真模糊处。

## Spec critic 变体（spec 成文后、apply 前）

只给 spec 产物（proposal / design / tasks / spec，或 SPEC-lite）+ 代码库只读权限，不给
brainstorm 过程。立场：默认找问题；报 PASS 前先写你试过怎么打它。逐条 yes/no：

1. 意图三向覆盖：proposal 每件事 ↔ spec Requirement ↔ tasks，缺一列出。
2. 对既有代码的每个假设——去读代码核实，不信 spec 的转述（最常见的漏）。
3. 外部 API / 库：每个引用实查存在与签名。
4. 范围：tasks 有 spec 没要求的？Non-goals 盖住蠕变了吗？Outcome 是用户可见词汇吗？
5. 可验证：每个 Requirement 有成功 + 失败 scenario；Verify 命令真覆盖 scenarios；末 task 端到端。
6. 决策：每条带「为什么」+「失效前提」。
7. 必填：最不放心的 3 处，即使整体 PASS。

R2 第二视角单独派：只做第 2 条（假设对照代码），不共享结论。R3 skeptic：只看 proposal 的
Why 与它引用的读数 / 事实——先构造每个断言可能怎么错，再查能否排除；不看 tasks。
