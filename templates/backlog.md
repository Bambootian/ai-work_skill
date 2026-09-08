# Backlog

> 索引，不是正文：每条 ≤2 行；证据、读数、裁决、过程进各自的文件（归属表：toolkit
> GUIDE §6，路径见 CLAUDE.md Toolkit 行），这里只留一句 + 路径。全文 ≤8KB（≈2.5k token，
> 中文约 45–80 行；hook 兜底）——超了搬内容，不删信息。
> Now 段每次收工**整段覆盖**：覆盖前先读旧 Now，悬而未决只能核销或结转，不能消失。
> 主线步完成只打勾；支线完成即删行；历史在 git log。

## Now（新 session 从这里接）

- 主线位置：<第 k / M 步 · <change-id> task i/n，一句>
- 下一步：<唯一一个动作：change-id，或「route check」，或「等 <外部事件>（到期 <date> / 未知，kill 线 <date>）」>
- 悬而未决：<一条一句；欠的 gate、待人拍的 [decide] 在此>
- 支线计数：<自上次主线推进或 route check 起的支线 archive 数>

## 主线（从当前进度到 North Star 成功判据的有序路径；无分组 = 整条主线一个板块）

### <板块 1：一句终态>
- [ ] <change-id 或外部事件> — <一行 user-visible outcome>｜解锁判据 <n>
- [~] <change-id> — 冻结｜kill 线 <date>｜复活条件：<...>

### <板块 2：一句终态>
- [ ] <...>

## 支线（触发在望的维护 / 修复 / 待触发；一行一条，不排进主线）

- [ ] <item> — <一句>｜触发：<事件 / 阈值>｜来源：<retro 日期 / dry-run / 评审>
- 长尾 watch 与冰箱（kill + 复活条件）：docs/watchlist.md，同格式，此处只留这一行

## Done（按板块折叠，一板块一行；change 细节在 archive）

- <板块>（<n> changes，<date> 收官）：<一句结果>
