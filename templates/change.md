# <change-id>
Route: R<0-3> — <一行理由>
主线: 第 N 步 <change-id> | 第 N 步前置（只读测量 / enabling） | 支线（来源）| 等待期活
BASE: <路由时的 HEAD 短 hash——critic / gate / WITHDRAWN / 归档后复原的 diff 基线；SPLIT 子 change 抄父的>

## Loop Contract
- Outcome: <做完后谁能观察到什么不同——操作者还是 North Star 用户，注明；不用代号>
- Verify: <具名命令 + 期望输出。"测试通过"四个字无效>
- Budget: <max 天数>
- Exit: DONE（Verify 全绿 + Outcome 落地；底线 gate 没跑 → DONE-ungated）| BLOCKED（blockers 附后）| SPLIT（拆分方案）
- Decided: <可选；你替人定的事，一句一条，≤5；难撤回（改数据契约 / 改配置身份 / 已外发 / 已花钱）标 ⚠>
- Critic: <视角 | 免> — <理由>
- Gate: <视角 | 免> — <理由>

## Why
<≤10 行人话：问题、为什么现在、谁能观察到什么不同>

## Non-goals
- <…>

## Spec 改动
<一行一条；正文在主 spec，差异 = `git diff <BASE> -- <下面列出的文件>`；本 change 不动契约、或小项目无主 spec，写「无」>
- `<specs dir>/<cap>/spec.md`: ADDED <Requirement 名>
- `<specs dir>/<cap>/spec.md`: MODIFIED <名>（改了什么）
- `<specs dir>/<cap>/spec.md`: REMOVED <名>（理由）/ Decision <ID> 新增 / <ID> → Superseded

## Decisions
<可选；只写决定 Fails when / Superseded 的决策与备选，一条一段。★ = 路由时已写进主 spec Architectural Decisions（带 Fails when 与 Source），此处只留为什么与没选的备选；小项目不打 ★>
- ★ <决策>：为什么 / 失效前提 / 没选 <备选> 因为 <…>

## Scenarios
<本 change 不动主 spec 时写 WHEN/THEN；动了主 spec 只写端到端验收>
- WHEN <…> THEN <…>

## 流程
<可选：≥3 阶段且带分支 / 重试 / 多执行方才画，mermaid；顺序本身是契约时画在主 spec 那条 Requirement 里，这里不画>

## Tasks
- [ ] 1.1 <任务> — 验证：<命令 → 期望输出>

## 注记
<失败注记 append：task id + tried / observed / hypothesis>

## Close
<append：每条 Verify 真输出 / Outcome 一行 / Gate 行 / Decided 聚合 / 出口态 / 读数；归档后订正追加于此>
