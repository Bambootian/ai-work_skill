---
name: value-review
description: Use before routing the next change when any of these hold - a mainline milestone (a step whose 判据 is now observably met) or a 板块 was just archived; backlog.md Now shows 支线计数 ≥3; the newest retro commit is ≥4 weeks old; the session model is a newer generation than the one recorded in the last retro; or the user asks 回顾 / 中期回顾 / 我们还在主线上吗 / 这个工程还值得做吗. Two forms - route check (≤40 lines) and project review (≤120 lines). Not triggered by raw archive count.
---

# Value Review = 主线回顾

回答一件事：**离 North Star 终态还有多远，我们还在通往它的主线上吗。** 不是给过去的
change 打分。产出是交人决策的判决书，永不自动落地。

## 两种回顾与触发（任一命中；检查点 = 下一个 change 路由前，change-loop §1）

| 形式 | 触发 | 产出 |
|---|---|---|
| **Route check 航线校准** | 主线里程碑 archive 后（该步所标判据可观察达成）；支线计数 ≥3（Now 下一步为「等 <外部事件>」期间暂停此条）；最近 retro commit ≥4 周（backstop：任何形式的 retro 都重置；命中而未写文件 = 未回顾，锚点不动）；人问「还在主线上吗」 | `retros/<date>-route-check.md`，≤40 行 |
| **Project review 工程复盘** | 一个板块收官（包含并取代同次 route check）；最近 project-review ≥8 周（无则从最早 retro 或立项 commit 起算）；模型换代——家族名或主版本号变化（Opus 4.8 → 5 算，Fable 5 → 5.1 不算），对照上份 retro 末行记录；连续 2 次 route check 判「钻牛角尖」或位置未前进，且两次之间隔 ≥1 个主线尝试或 ≥2 周；人要求 | `retros/<date>-project-review.md`，≤120 行 |

archive 总数不是触发条件。路径：OpenSpec 项目 `openspec/retros/`，其他 `docs/retros/`。
节奏锚用命令得出，不信 handoff 里的数（按 commit 序，不按文件名日期）：

```bash
retro=$(git log -1 --format=%H -- <retros>)         # 最近一份 retro 的 commit
git log -1 --format=%cs -- <retros>                  # 其日期 → 4 周 / 8 周
git log --diff-filter=A --format= --name-only "$retro"..HEAD -- <archive dir> | grep -c .
# ↑ 其后新增归档数；减去主线段新增打勾数 = 支线计数（Now 里的数只是缓存）
```

## Route check（先问一句，再六项）

第一行是问人的：**「这段时间你用下来最不满意的一件事是什么？」** 答案原话记下；没答
就写「未答」，不编——过往回顾里真正有用的信号全来自人，不来自程序。

1. **终态与判据**：从 CLAUDE.md North Star 段抄，不重写、不换说法。
2. **主线快照**：M 步已完成 k；本期每个 archive → 推进第几步 / 前置 / 支线（为什么出现：
   dry-run / 修复 / 评审衍生 / 回顾衍生）。「推进」按用户产物核验（已证明 ≠ 已交付）；
   不成立 → 回退打勾 + 一条 [decide]。
3. **待做审视**：只审在途提案 + 自上次 retro 起新增的支线 + 触发已命中的支线，逐条
   在线 / 降级等触发 / kill；其余一句「n 条未触发，不动」。
4. **偏离判决**：在线｜分叉｜钻牛角尖，先写一行量：自上次主线推进起 n 支线 / d 天。判据
   （给 change-id）：同一细节 ≥2 个 change 且该细节不是主线步；主线某步估算较上份 route
   check 推后；目标措辞从「用户得到 X」滑成「工具能做 Y」；支线连击——主线阻塞于外部事件时
   不算，判「在线，阻塞于 <事件>」。
5. **距离**：剩余步数 + 按已完成步骤的实际节奏一句估算（外部事件解锁的步注明不可估）。
6. **下一步**：唯一一个动作。

末两行：上轮承诺核销（上一份 retro 提的那一个 change 与各 [decide] 落了吗）；
`模型: <会话模型名>`（换代触发的基线）。

## Project review（七项）

1. **North Star 还成立吗**（用户是谁 / 得到什么 / anti-scope）——失真 → 停：重锚定是人的
   决策，定下来之前其余都不重要。
2. **地图倒核**：把剩余主线步全部做完，每条成功判据真能达成吗？达不成的判据指出缺哪一步；
   只有实现词汇的主线步按「达不成」算。尺子错了，后面所有位置读数都错。
3. **成功判据逐条**：达成 / 部分 / 未达 + 可观察证据——取自生产路径与用户产物，不看
   Outcome 声称什么。
4. **轨迹**：每板块（无分组 = 整条主线一个板块）计划步数 vs 实际 change 数 vs 用时；
   收敛还是发散。
5. **死胡同**：哪一步反复尝试无进展（列 change 与 probe）；沉没成本提醒。
6. **贬值检查**：当前模型 / 工具已能直接做到本项目哪些部分？哪些组件因此多余？剩余价值
   是什么——长周期工程最贵的错误是继续建一个模型已经免费给出的东西。末行记 `模型:`。
7. **停掉的最强理由，然后才是建议**：先用本次证据写出「今天停掉这个项目的最强理由」（≥3 句），
   写不出才允许 [continue]；再给 [continue] / [re-scope] / [pause] / [kill] + 剩余主线重排提案。
   一个从不失败的检查等于没有。

## 共同规则

- **最多提 1 个新 change，且必须在主线上**；其余发现进 backlog 支线一行（带触发条件）。
- **回顾只读**：用已有归档 / 读数 / 命令输出；需要新实验 → 那就是它提的那一个 change。
- **[decide] ≤3 条，每条一个是非题或 A/B，写完停下等人当场拍**；未拍的结转 backlog Now
  悬而未决，不带进下一轮 retro 重述。
- 主线段增删 → [decide] 交人；批准后才动 backlog 主线 / North Star / ARCHITECTURE——
  批准前零落地。
- 判决书不是日志：证据用路径指，不粘贴；自己写错了就改正文，过程在 git。
- 议题是产品与主线；工具包的流程问题进 toolkit 的 FIELD-LOG，不占回顾篇幅。
- 首轮：backlog 无主线段 → 停，先跑 project-bootstrap 迁移写出主线段交人确认；
  旧 `*-value-review.md` 视作上一份 retro。

## v5.1 观察位（每次回顾顺手核；命中即在 retro 末尾写「观察位命中 #n」并告诉人，建议升级为规则）

| # | 信号 | 升级方式 |
|---|---|---|
| 4 | 贬值检查连续 2 份 project review 只有定性判断，未引用任何真实对照 | 无对照时，本次唯一 change 必须是「当前模型不带项目代码裸做一次同样的事」的 spike |
| 5 | 剩余步数连续 3 次 route check 不减 | 距离项改为趋势行：上次剩 k、这次剩 j、隔 d 天 |
| 6 | 连续 2 次 backstop 回顾都判「阻塞于同一外部事件」 | 工程复盘必须在 [pause] 与继续之间二选一，不许第三次原样等 |
| 7 | CLAUDE.md「当前阶段重点」与 backlog Now 主线位置说法不一致 | 删「当前阶段重点」，改为指向 backlog Now |
