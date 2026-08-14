# my-work-skill v5 使用指南

> v5 = v4 的契约内核 + 面向 2026 frontier class 模型（能力下限 Opus 5）的减法重构。
> 设计契约与全部证据：`docs/specs/2026-08-14-v5-subtraction-design.md`。
> WORKFLOW.md v3.6 冻结：附录 G（hooks 源码）、5.4.1（R-revision）、5.8（archive）仍是被引权威。

## 1. 设计原理（一页）

**四层工程模型**：Harness（hooks/settings——确定性强制）→ Context（CLAUDE.md 常驻 /
skills 按需 / 持久文件）→ Prompt（skill 正文、dispatch 模板）→ Loop（契约控制迭代与退出）。

**约束下沉原则**（每写一条约束，自底向上问）：能 hook 强制吗 → 能变成模板必填槽位吗 →
能做成 skill 按需注入吗 → 都不能且每步都需要，才进 CLAUDE.md 常驻。

**v5 四原则**：

1. **下限锚定 Opus 5**：保留的约束必须对 Opus 5 有效；切除的必须 Opus 5 也不需要。
2. **不做单一模型特调**：模型校准是厂商的事，不为任何模型建补课层。回归记录标注当时模型。
3. **内核 harness 中立**：契约格式、spec 文件、CLAUDE.md 约定是纯 markdown；
   skills/hooks 是 Claude Code 适配层。不为其他 harness 预写适配器。
4. **提示层做减法，harness 层按误伤率取舍**：「过度约束反噬能力」全部指提示层文本；
   hook 零上下文成本，去留只看误报率。

**官方仍要求外部支撑的四样**（《Prompting Claude Fable 5》，对整个 frontier class 成立）：
文件化持久记忆、fresh-context 验证 subagent、进度声明对照 tool result 审计、
意图上下文 + 短指令形式的范围纪律。本工具包分别以 Loop Contract 与 land-the-plane、
分级 gate 评审、证据 gate、North Star 段承载——这四样是保留项的骨架。

## 2. 循环速查（数值与判据的权威在 change-loop skill，冲突以彼为准）

| 要素 | 内环（task） | change 环 | value 环 |
|---|---|---|---|
| 终止 | 绿+commit；stuck 判据或 5 迭代 → SPLIT/BLOCKED | DONE / BLOCKED / SPLIT | retro 写完交人决策 |
| 回退 | 绿锚点 reset；fix-forward 仅限迭代内 | spec 层 R-revision；计划层重生成 tasks | 人批准前零落地 |
| 粒度 | 一 task 一迭代 | 0.5–2 天；超预算 = SPLIT 不是加班 | 5 archive / 4 周 |
| 验证 | 具名命令 + 期望输出 | Verify 全跑 + 真机验收 | 上轮承诺核销先行 |

## 3. 融合决策记录（为什么不用 X——防止半年后重新调研一遍）

| 候选 | 结论 | 一句话理由 |
|---|---|---|
| BMAD 全套 | 拒 | 实测 6 天 $200 vs 别人 1–2 天；QA agent 对坏构建报 "Perfect"；为 5–20 人团队设计 |
| Gas Town / 20+ agent 编排器 | 拒 | 作者本人劝退大多数开发者；solo 无收益纯成本 |
| beads | 暂缓 | backlog.md + OpenSpec + claude-mem 已覆盖；依赖图真痛了再装（git-native 随时可补） |
| Spec Kit / Kiro 迁移 | 拒 | SDD 横评 OpenSpec 赢 solo 场景（最低摩擦 + 最佳 brownfield）；迁移零增益 |
| ralph 官方插件 | 拒 | 隐藏 hooks、卸载可能破库（HumanLayer 弃用实证） |
| 巨型 subagent fan-out | 拒 | 配额燃烧 + 非确定性；保留主循环单层扁平扇出 |
| 多层 agent 树（孙 agent） | 拒 | token 乘法失控（实测）+ 约束传话失真 + 归因断裂；一层扁平扇出是唯一编排形态 |
| 双模型架构（OPUS-SYSTEM 注入） | 退役 | 模型下限 Opus 5 后失去补课对象；2026-07 实测手动注入必忘 |
| 无人值守 ralph 驱动脚本 | 退役 | frontier class 原生长时程自治 + 异步检查取代土法循环 |

## 4. 工具链排查要点

命令突然失效 / skill 不触发 / 文档与命令面不符时：查版本（`/plugin list`、
`npx openspec --version`）→ 跑最便宜的真实命令做 break-check → hook echo 用例复验
（附录 G 四用例——hook 静默死掉是最坏失败模式）→ 先改文档再改实践（约束先行）。
装机基线由 bootstrap Step 4 的一次 break-check 建立。

## 5. v4 → v5 对照速查

| v4 | v5 |
|---|---|
| NORTH_STAR.md 独立文件 + Review Log 表 | CLAUDE.md North Star 段；节奏锚 = `retros/` 最新文件日期 |
| 四行 Route Declaration（Route/Explored/Mode/Next） | 两行（Route + Next）+ 三条一行规则 |
| Mode A/B 白名单谓词 + tripwire 法条 | 一行：默认 brainstorm，有证据工件或明说才跳过 |
| OPUS-SYSTEM.md + `$PROFILE` claude wrapper | 删除（下限 Opus 5，不做模型特调） |
| toolchain-refresh skill + 定时任务 + staleness hook | bootstrap 一次 break-check + 症状排查（§4） |
| 7 hooks | 5（删 warn-apply-phase、warn-toolchain-stale） |
| recitation / 40% 上下文教条 / 无人值守 recipe | 删除（官方：instruction retention 已达标；数字过时） |
| dispatch 降级白名单 + cheap-model 行动规范 | 默认继承会话模型；web 抓取类必降 Sonnet；禁孙 agent |
| Rationalizations 表 + Red flags 清单 | 删除（官方：短指令与逐条枚举同效；复发走 ablation 台账回装） |
| GUIDE §8 验证计划 | FIELD-LOG ablation 台账 + GREEN 观察位 |
