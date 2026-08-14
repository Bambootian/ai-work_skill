---
name: value-review
description: Use when a long-running project shows drift — consecutive changes with no user-visible value, repeated R-revisions on the same decision, backlog priorities overturned, the main spec reads as confusing — or on cadence (every 5 archived changes or 4 weeks), or when the user asks for a mid-project review / 中期回顾.
---

# Value Review

对照 North Star 重新锚定项目、按累积现实重判架构与 backlog。产出是**交人决策的建议**
——永不自动落地。

> 本流程为压缩占位：触发表是权威，流程为最小可用版。「工程全面复盘」的深度重设计
> 是 v5 落地后的第一个独立 change。

## Triggers（任一命中）

| 信号 | 阈值 |
|---|---|
| 自嗨连击 | 连续 3 个 archive 无可观察行为变化——事后判，不看 Outcome 声称什么 |
| 决策翻烧饼 | 同一决策被 ≥2 次 R-revision，或 2 个 change 在同一 capability 上冲突 |
| backlog 被推翻 | 上次回顾以来 phase 顺序或优先级重排 |
| 节奏兜底 | `retros/`（OpenSpec 项目 `openspec/retros/`）最新文件起 ≥5 archive 或 ≥4 周——change-loop 收尾自动查，不靠记忆 |
| 人的直觉 | 「看不懂主 spec」/ 对方向不安 |

## Procedure（压缩版）

1. **核销上轮承诺先行**。打开上一份 retro：每个承诺解锁 user-value 的 enabling change，
   价值落了吗？未兑现的领衔 findings。首轮（retros 目录无文件）跳过本步。
2. **North Star 检查**。读项目 CLAUDE.md 的 North Star 段。还成立吗？失真 → 停：
   重锚定是人的决策，它定下来之前其余都不重要。
3. **逐 change 一行分类**。对上次回顾以来每个 change：*用户得到了什么？*按 North Star
   段的三分类判：user-value / enabling / self-indulgence。enabling 的标准不是「理论上
   解锁」而是「承诺的价值落了没」——所以第 1 步先跑。
4. **写了就停**。产出 `retros/<date>-value-review.md`（OpenSpec 项目放
   `openspec/retros/`）：findings + 每条建议标 [keep] / [change] / [kill] / [decide]，
   呈交人。批准后才走 R-revision / ARCHITECTURE 更新 / backlog 修改——批准前零落地。

## Common mistakes

- **自动落地结论**：架构与价值方向是语义级决策——永远人 gate。
- **数吞吐不看结果**：「archive 了 12 个 change」不是 finding；用户得到了什么才是。
- **enabling 一律放行**：检验是「承诺的价值落了没」，不是「理论上有用」。
