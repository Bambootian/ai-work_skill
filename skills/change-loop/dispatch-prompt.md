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
