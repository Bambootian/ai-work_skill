# Subagent Dispatch Template

> 所有派发给 subagent 的 prompt 按此模板填槽；省略任何 REQUIRED 槽位 = 派发无效。
> 依据：subagent 看不到主循环的任何上下文（v3.6 内存炸机根因）；
> 必填槽位结构优于散文叮嘱（Anthropic multi-agent research 的派发四要素）。

```markdown
## Model (REQUIRED)
<inherit | cheaper tier — one line stating which and why, per the routing rule below>

## Objective (REQUIRED)
<one task, one outcome. Not two.>

## Context (REQUIRED)
<change-id, relevant file paths, what already exists — the minimum needed. No conversation history.>

## Constraints (REQUIRED — restate VERBATIM, never summarize)
- Project hard rules: <paste the relevant lines from CLAUDE.md>
- Test command discipline: <paste, e.g. only `dotnet test --filter ...`; NEVER set the escape var>
- Loop contract: <paste Outcome / Verify / Budget>
- Scope: touch only <files/areas>; no drive-by changes

## Output format (REQUIRED)
<exactly what to return — data, not narrative. e.g. "changed files list + full test command output
+ 3 least-confident points", or a JSON shape. Target ≤2,000 tokens.>

## Boundaries (REQUIRED)
- Do NOT: <commit / push / modify spec / run full test suite / ...>
- On failure: return tried / observed / hypothesis. Max 2 attempts, then stop and report.
```

## 模型路由规则（填 Model 槽位时用）

默认**继承会话模型**——降级是需要声明理由的显式优化，不是默认值。

- **可降级（cheap tier）**：探索/清点、跑命令报输出、日志摘要、按精确 spec 的样板实现、机械迁移。共同点：错误能被机械检测（测试/diff/schema），或产物只是信息回传。
- **永不降级**：gate 评审、spec 自审、根因诊断、架构分析、语义裁决——这些任务的错误检测靠判断，便宜裁判会盖章放行。
- **不对称律：产出可以便宜，裁判不能便宜。** 便宜产出 + 强模型或机械检查验收 = 安全；强产出 + 便宜验收 = 最差组合。

## Cheap-model 行动规范（降级派发时把整块粘进 Constraints 之后，不要摘抄改写）

```
Operating rules (non-negotiable):
1. Data first — your final message IS the return value. Deliverable/data in the
   first lines; no preamble, no process narrative.
2. Execute, don't re-litigate — constraints in this dispatch are settled decisions.
   Do not re-derive, question, or "improve" them mid-task.
3. Evidence or say so — verify with tool results before reporting. Paste failing
   output verbatim. Label anything unverified as unverified. Fabricated progress
   is the worst possible failure.
4. Minimal scope — only what this dispatch asks. No extra features, refactors,
   abstractions, or defensive code for impossible cases. Touch only files in scope.
5. Finish or report BLOCKED — never end with a promise or a question; you cannot
   ask the user anything. Max 2 attempts on the same failure, then return
   tried / observed / hypothesis and stop.
```

## Reviewer 变体（gate 评审时）

- Reviewer 是 fresh-context：只给 diff + spec + 评审标准，**不给**产生代码的推理过程。
- Output format 追加：`verdict per finding: [blocking] or [nit]`。[blocking] = 违反 spec/contract，**或真实缺陷**（正确性、资源泄漏、数据丢失、安全）——必修；[nit] = 风格与"可以更好"——记录不追（防评审驱动的过度工程）。架构/代码质量视角发现的真实缺陷同样是 [blocking]，不因"不是 spec 违反"而降级。
- R2 双视角：一个 reviewer 拿 spec 合规标准，一个拿代码质量标准，prompt 分开派，不共享结论。
- R1 单 reviewer 的额外职责：核对 Verify 命令是否真覆盖 Scenarios——弱验证是 R1 最大的漏风口（人只在收尾看证据，验证写弱了收尾也看不出来）。
- 多 reviewer 结论冲突（同一处一个 [blocking] 一个说不动）：**不自行仲裁**——两份原话并列放进 gate 证据包，人裁。冲突点通常正是 spec 的真模糊处。
