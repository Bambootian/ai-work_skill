# my-work-skill v5 使用指南

> v5 = v4 的契约内核 + 面向 2026 frontier class 模型（能力下限 Opus 5）的减法重构。
> v5.1 = 主线锚定：backlog 索引化、subagent 常设授权、spec 自检、回顾重构。
> 设计契约：`docs/specs/2026-08-14-v5-subtraction-design.md`、`docs/specs/2026-09-08-v5.1-mainline-anchoring-design.md`。
> v5.2 = WORKFLOW.md v3.6 退役（原文见 tag v5.1）：hook 源码在 `hooks/`，archive 步骤在 change-loop §5，
> spec 修订用 `/opsx:update`，opsx 流程内约定在 `templates/openspec-config.yaml`；对齐 OpenSpec 1.13。
> v5.3 = 版本戳：`VERSION` ↔ 项目 Toolkit 行 ↔ `~/.claude/my-work-skill.toolkit-version`，Session Start 比对；接口兼容承诺（§5）。

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
分级 gate 评审 + spec critic、证据 gate、North Star 段 + backlog 主线承载——这四样是保留项的骨架。

## 2. 循环速查（数值与判据的权威在 change-loop / value-review skill，冲突以彼为准）

| 要素 | 内环（task） | change 环 | value 环 |
|---|---|---|---|
| 终止 | 绿+commit；stuck 判据或 5 迭代 → SPLIT/BLOCKED | DONE / DONE-ungated / BLOCKED / SPLIT | route check ≤40 行 / project review ≤120 行，交人决策 |
| 回退 | 绿锚点 reset；fix-forward 仅限迭代内 | spec 层 `/opsx:update`（不静默改 spec，代码同 commit 跟上）；计划层重生成 tasks | 人批准前零落地；最多提 1 个新 change 且在主线上 |
| 粒度 | 一 task 一迭代 | 0.5–2 天；超预算 = SPLIT 不是加班 | 触发见 value-review 表：主线里程碑 / 支线计数 / 4 周 backstop；板块收官 / 8 周 / 模型换代 |
| 验证 | 具名命令 + 期望输出 | spec critic 先行；Verify 全跑 + 真机验收；Gate 行 | 已证明 ≠ 已交付：判据证据取自用户产物 |

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
| 自定义 reviewer agent（.claude/agents） | 暂缓 | 常设授权文本先试；「拒派」复发再装只读 reviewer agent（ablation 台账） |

## 4. 工具链排查要点

命令突然失效 / skill 不触发 / 文档与命令面不符时：查版本（`/plugin list`、
`npx openspec --version`）→ 跑最便宜的真实命令做 break-check → hook echo 用例复验
（hook 静默死掉是最坏失败模式）→ 先改文档再改实践（约束先行）。
装机基线由 bootstrap Step 4 的一次 break-check 建立。
项目行为像旧版（要求确认 subagent、看不见 hook 提醒、archive 手工合并）→ 先看项目 Toolkit 行
版本与 `~/.claude/my-work-skill.toolkit-version` 是否相等，不等就是没迁移，不是 skill 坏了。

**Hook 两条法则**（2026-09-08 实测 Claude Code 2.1.259）：工具事件（PreToolUse /
PostToolUse）下模型看得见的是 JSON `additionalContext` 或 exit 2 + stderr，`exit 0 + stdout`
只进 debug 日志（SessionStart / UserPromptSubmit 例外，纯文本可见）；脚本只含 ASCII 且读
stdin 前设 UTF-8。写错任一条 = 静默失效，脚本自己的 echo 测试测不出来。

## 5. 版本对照速查

**接口与兼容承诺**（机器级 skill 与项目文件之间的契约；minor 版本内只增不改不删，要改或删 =
major + 迁移段。在途 change 跨 minor 版本安全的前提就是这张表：状态在文件里，字段只增；新 skill
接旧契约，Close 补新增行）

| 接口 | 内容 |
|---|---|
| CLAUDE.md 段名 | North Star / Stack & Conventions / Toolkit（含 `版本:` 行）/ Session Start / Hard Rules / Enforcement |
| backlog.md 段名 | Now（四字段）/ 主线 / 支线 / Done |
| Loop Contract | Outcome / Verify / Budget / Exit 四字段（v4.1 起未变） |
| 路由与收尾 | Route / 主线 / Next 三行；Close 的 `Gate:` / `主线:` 行 |
| hooks | `hooks/` 清单、脚本名、matcher |
| openspec/config.yaml | schema / context / rules.<artifact> / operations.apply\|archive.guidance |
| 版本戳 | `VERSION` = tag；项目 Toolkit 行 `版本:`；机器 `~/.claude/my-work-skill.toolkit-version` |

**v4 → v5**

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

**v5.0 → v5.1**

| v5.0 | v5.1 |
|---|---|
| backlog = capability 清单，其余内容无家 | backlog = 索引（Now / 主线 / 支线 / Done，≤8KB）+ §6 归属表 + warn-backlog-size hook |
| 两行路由声明 | 三行：加 `主线:` 行——不在主线段 = 支线；主线段只经回顾批准增删 |
| gate 评审派发无授权文本；inline 替代不可见 | CLAUDE.md 常设授权；Close 必填 `Gate:` 行（critic + reviewer），没跑 = DONE-ungated；R0 免 gate |
| spec 写完直接进循环 | spec critic（fresh-context，分级）→ 修 blocking → R2+ 人批准 |
| value-review = 逐 change 三分类，5 archive / 4 周 | route check（主线快照 / 偏离 / 距离）+ project review（判据 / 死胡同 / 贬值）；主线里程碑 / 支线计数 / 4 周 backstop / 板块 / 8 周 / 模型换代；检查点在下一个 change 路由前 |
| 5 hooks，Tier 2 = exit 0 + stdout | 6 hooks（+ warn-backlog-size）；JSON additionalContext / exit 2 + stderr；stdin UTF-8 |

**v5.1 → v5.2**

| v5.1 | v5.2 |
|---|---|
| WORKFLOW.md v3.6 冻结，附录 G / §5.8 / §5.4.1 被引 | 退役（原文见 tag v5.1）：hook 源码 → `hooks/`（真实 .ps1 + echo 用例，Tier 1 也补 stdin UTF-8）；archive → change-loop §5 三行，delta 合并交回 `openspec archive -y`；R-revision → `/opsx:update` |
| opsx 流程内约定靠模型记住 change-loop | `templates/openspec-config.yaml`：context / rules.tasks / rules.specs / operations.apply\|archive.guidance，bootstrap 生成、OpenSpec 注入；权威仍在 change-loop |
| `openspec validate --specs --strict` | 不加 `--strict`（1.8 起 normal 不强制英文 SHALL/MUST；1.11 起 strict 对 Purpose 占位报失败） |
| 对齐 OpenSpec 1.5.0 | 对齐 1.13.0（core：propose / explore / apply / update / sync / archive）；存量项目 `openspec update` |

**v5.2 → v5.3**

| v5.2 | v5.3 |
|---|---|
| 项目与机器都无版本记录，漂移靠 Session Start 猜形态（只查 North Star / Now / 主线） | `VERSION` 文件；bootstrap 写项目 Toolkit 行 `版本:` 与机器标记文件；Session Start 先比对，不等即迁移，形态检查留作兜底 |
| 迁移无时机规则 | 绿树 task 边界、单独 docs commit；在途契约不动；Toolkit 行改版本 = 迁移完成 |
| 兼容性只是事实 | 接口表 + 承诺写入本节 |

## 6. 什么写在哪（内容归属）

backlog 膨胀的根因是这些内容没有指定的家。写之前查表；backlog 只留一句 + 路径。

| 内容 | 家 |
|---|---|
| 终态、成功判据、anti-scope、当前阶段 | CLAUDE.md North Star 段 |
| 运行须知（命令、耗时、机器产物别手改） | CLAUDE.md Stack & Conventions |
| 主线路径、下一步、触发在望的支线 | backlog.md |
| session 交接（位置 / 下一步 / 悬而未决 / 支线计数） | backlog.md Now 段，整段覆盖、债务结转 |
| 长尾 watch、冰箱（kill + 复活条件） | `docs/watchlist.md`，同支线行格式；backlog 一行指过去 |
| 单个 change 的过程、读数、gate 结果、失败注记、事后订正（`## Errata`） | change 归档（openspec archive 的 proposal.md / `docs/changes/<id>.md`） |
| 已定规格、未开工的步 | 前置探针的归档，或 `docs/notes/`；backlog 主线行只留一句 + 路径 |
| 架构决策 + 为什么 + 失效前提 | capability 级：主 spec `## Architectural Decisions`（change-loop §5 Close，带 Source / Superseded）；项目级：ARCHITECTURE.md / DESIGN.md Decisions |
| change 之间的人裁定（产品 / 流程级） | `docs/decisions.md`，一行一条：日期｜裁定｜理由｜失效前提；论证长的另附 notes 路径 |
| 不属于任何 change 的探针读数、方法教训、外部事实核实 | `docs/notes/<date>-<slug>.md`，一题一文件 |
| 回顾判决 | `retros/`（route check / project review） |
| 工具包自身的流程问题 | toolkit 的 FIELD-LOG.md，不占项目回顾篇幅 |
