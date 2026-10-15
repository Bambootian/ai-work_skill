---
name: value-review
description: Use before routing the next change when any of these hold - a mainline milestone (a step whose 判据 is now observably met) or a 板块 was just archived; the newest milestone summary (retro) is ≥4 weeks old; a mechanical signal fired (the item promised in the last summary is ✗ for the second time, or a success criterion is reported met while the mainline keeps working on it); a big investment is ahead (new 板块, change to North Star or the mainline section, spend above project parameters, a mainline step estimated at ≥5 changes); the session model is a newer generation than the one recorded in the last summary; or the user asks 回顾 / 中期回顾 / route check / 我们还在主线上吗 / 这个工程还值得做吗. Products - milestone summary (≤40 lines, written for the human), project review (板块收官, ≤120 lines), and the direction adversary dispatched from here.
---

# Value Review = 里程碑汇总 + 方向反方

回答一件事：**离 North Star 终态还有多远，还在通往它的主线上吗。** 产物写给人（船长），不是日志：
无内部代号，证据用路径指。判决先写完，人的答案是输入不是替代。永不自动落地。

## 触发（任一；检查点 = 下一个 change 路由前）

| 产物 | 触发 |
|---|---|
| **里程碑汇总** `retros/<date>-milestone.md`，≤40 行 | 主线里程碑 archive（该步判据可观察达成）｜最近汇总 ≥4 周（backstop；锚点按 commit 序取 `git log -1 --format=%cs -- <retros>`，命中而未写文件 = 未回顾）｜机械信号命中｜人问 |
| **Project review** `retros/<date>-project-review.md`，≤120 行（含并取代同次汇总） | 板块收官｜模型换代（家族名或主版本号变化，对照上份末行）｜人要求 |
| **方向反方**（嵌在上面两者里；大投入前而无里程碑时，并排表进该 change 文件的 Why，不另写 retro） | 大投入前：新板块 / 改 North Star、板块终态或主线段 / 花费超项目参数 / 主线步预估 ≥5 个 change（门槛为项目参数）｜机械信号 a / b（见 ⑤）｜模型换代 / 人问（随 project review 或汇总）｜同一板块 ≤1 轮，除非信号命中 |

路径：`<retros dir>`（既有项目 `openspec/retros/`，其他 `docs/retros/`）；旧 `*-route-check.md` / `*-value-review.md` 视作上一份汇总。

## 里程碑汇总（七段 + 末两行；正文 ≤40 行——②③ 各超过 5 条时正文只留难撤回 / 前 5 条 + 计数，全文清单作附录不计行）

① **你现在能做到的新东西**：从本期归档的 Outcome 行汇总，只写用户可见产物。
② **本期我定的事**：`git log $(git log -1 --format=%H -- <retros>)..HEAD -- <archive dir> docs/notes` 列归档与笔记，grep `Decided:` 聚合；
   难撤回（⚠）在前，每条一句 + 要改的代价；在此否决。附本期花费对项目参数线的读数。
③ **到期移出的条目**：到期 = 条目出生后已过 ≥2 份汇总（只数 `retros/*-milestone.md` 与 `*-project-review.md`，
   旧 route-check 只作上一份锚点不计）或行出生日（`git blame`）距今 ≥8 周；绑定具名未来事件或未开始主线步
   的免到期。逐条审：触发了 → 路由 change；没触发但条件仍成立且能绑到具名事件 → 改绑并注明；其余删行
   （git 有），这里一行一条。附 `wc -c` CLAUDE.md / backlog.md。
④ **方向**：本期触发了反方 → 并排表（反方原话 ≤2 行｜事实成立?｜接受 / 反驳｜对方向意味着什么）；
   没触发 → 一句「未触发：<信号读数>」。
⑤ **位置**：主线 k/M 步；剩余步数与按实际节奏的估算（外部事件解锁的步注明不可估）；上期承诺
   <X>：✓ / ✗（连续第 n 次）；机械信号 **a**（n ≥ 2——若该项是可只读跑的实验，等待期直接跑）/
   **b**（判据报「达成」而主线仍在继续）：命中 / 未命中；在途 change 的「Spec 改动」一行（`ls <changes dir>/*/change.md`
   读出；无则不写）；唯一下一步。
⑥ **需要你定的**：只限方向 / 钱 / 时间 / 找谁，每条带推荐与改主意的代价；没有写「无」。
⑦ **`工具包:`** 一行：工作流哪里卡或重（没有写「无」）。
末两行：「这段用下来最不满意的一件事？」（未答写「未答」，不编）；`模型: <会话模型名>`。

## Project review（板块收官，七项）

1. **North Star 还成立吗**（用户是谁 / 得到什么 / anti-scope）——失真 → 停：重锚定是人的决策。
2. **地图倒核**：剩余主线步全做完，每条成功判据真能达成吗？只有实现词汇的主线步按「达不成」算。
3. **成功判据逐条**：达成 / 部分 / 未达 + 可观察证据，取自生产路径与用户产物（已证明 ≠ 已交付）。
4. **轨迹**：每板块计划步数 vs 实际 change 数 vs 用时；收敛还是发散。
5–7. **死胡同 / 贬值检查 / 停掉的最强理由**：由方向反方写，你逐条核事实并反驳或认同，并排表就是这
   三项；反方派不出去 → 自己写并在表头标明「本栏由主会话写，未派反方」。然后才是建议 [continue] /
   [re-scope] / [pause] / [kill] + 剩余主线重排提案，每个选项一句「选它意味着什么、改主意的代价」。
末尾带汇总的 ②③⑥⑦ 与末两行。

## 方向反方

形态与配方见 change-loop 目录 `dispatch-prompt.md`「方向反方变体」：默认 1 个 fresh-context 外部反方
（不加载工作流，项目约束文档只作证据）。第二个反方：项目参数「第二反方」写了必派 / 不派就照它；写「按内容判定」或未写时，改 North Star /
新板块 / 花费超参数任一即派，派不派在并排表表头写一行理由；有第二个模型家族可用则优先用它。反方擅长
发现问题，方向建议只作参考；方向由人看并排表后定。反方全文进 `docs/notes/<date>-adversary.md`，
不进常驻文档、不转述；只有人定下的方向进 `docs/decisions.md`。

## 共同规则

- **最多提 1 个新 change，且必须在主线上**；其余发现进 backlog 支线一行（带触发条件）。
- **回顾只读**：用已有归档 / 读数 / 命令输出；需要新实验 → 那就是它提的那一个 change，或等待期的只读探针。
- 板块、其终态与判据、主线段增删 → 交人（汇总 ⑥），批准前零落地；板块内步骤拆分由你做，列入 ②。
  觉得主线错了不必等汇总：任何 change 里当场一行提出。
- 技术与领域题不问人：你定，记 `Decided:`，判错由真跑暴露。
- 判决书不是日志：证据用路径指，不粘贴；工具包的流程问题只进 ⑦。首轮 backlog 无主线段 → 停，先跑
  project-bootstrap 迁移写出主线段交人确认。
