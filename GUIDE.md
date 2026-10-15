# my-work-skill v6 使用指南

> v5 = v4 的契约内核 + 面向 2026 frontier class 模型（能力下限 Opus 5）的减法重构。
> v5.1 主线锚定；v5.2 WORKFLOW.md 退役、对齐 OpenSpec 1.13；v5.3 版本戳；v5.4 / v5.5 迁移回灌与用户裁定。
> **v6.0 = 船长模型**：人只定方向、钱、时间、找谁；AI 决定其余并在里程碑汇总里给人否决；方向层
> fresh-context 反方；热存储有上限、条目到期；过程约束减法。v6.1 = superpowers 退役、随时可说主线错了。设计契约：
> `docs/specs/2026-08-14-v5-subtraction-design.md`、`docs/specs/2026-09-08-v5.1-mainline-anchoring-design.md`、
> `docs/specs/2026-10-15-v6-captain-model-design.md`（证据与反方并排记录在 `docs/evidence/2026-10-14-workflow-review/`）。

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

**v6 两条边界**（2026-10-14 取证，new_review_create 20 个 change）：

- **契约 vs 流程**：契约 = 数据格式、CLI 接口、预登记口径、North Star 红线、架构决策与失效前提、
  主线位置、在途 Loop Contract 与失败注记、常设偏好——忘了会做错且没人能发现，必须跨 session 稳定存在。
  流程 = 怎么拆 task、写几份文档、派几个视角、问不问人——交给模型当场判断。约束结果和红线，不约束过程。
- **人机分工**：人是船长，只定方向、钱、时间、找谁 / 对外不可逆；判不了的技术题全部交 AI，AI 的决定记
  `Decided:` 行，难撤回的在里程碑汇总里留否决机会。发现问题不能只靠人：方向层由 fresh-context 反方承担
  （回测：同模型同信息只换位置，外部反方 8/8 对工作流内回顾 2/8；但方向建议 3 个里 2 个指错，所以反方
  只提问题，方向由人看并排表后定）。

**每加一条约束先答四问**：它替换掉了什么；热存储净减多少；防哪种失败；近几周在当前模型上出现过吗。
用新的重流程修旧的重流程是头号错误。

**四条工程原则**（真缺陷根源分类：212 条里机制带来 14%、修复带来 10%，集中在四类做法）：数据逻辑进 CLI
命令，skill 只编排、不嵌数据逻辑；能用真隔离或结构化手段时不用正则审查自由文本；不自定没人要求的契约
（「永不打 traceback」「整包逐字节相同」追不到任何判据）；环境知识进 CLAUDE.md Stack 或知识库，不散落。

**官方仍要求外部支撑的四样**（《Prompting Claude Fable 5》，对整个 frontier class 成立）：
文件化持久记忆、fresh-context 验证 subagent、进度声明对照 tool result 审计、
意图上下文 + 短指令形式的范围纪律。本工具包分别以 Loop Contract 与 land-the-plane、
分级 gate 评审 + spec critic + 方向反方、证据 gate、North Star 段 + backlog 主线承载。

## 2. 循环速查（数值与判据的权威在 change-loop / value-review skill，冲突以彼为准）

| 要素 | 内环（task） | change 环 | value 环 |
|---|---|---|---|
| 终止 | 绿 + commit；同一错误重复 → 换思路 / BLOCKED | DONE / DONE-ungated / BLOCKED / SPLIT | 里程碑汇总 ≤40 行 / project review ≤120 行，写给人；只问四类 |
| 回退 | 绿锚点 reset；fix-forward 仅限迭代内 | spec 层 `/opsx:update`（不静默改 spec）；tasks 由你在 spec 范围内自治改 | 人批准前零落地；最多提 1 个新 change 且在主线上 |
| 粒度 | 一 task 一 commit | 0.5–2 天；超预算 = SPLIT 不是加班 | 触发：主线里程碑 / 板块收官 / 4 周 backstop / 机械信号 / 大投入前 / 模型换代 |
| 验证 | 具名命令 + 期望输出 | spec critic 按内容判定；Verify 全跑；Gate 行 | 已证明 ≠ 已交付：判据证据取自用户产物；方向反方并排表 |

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
| 多 change 并行调度 | 待琢磨 | 用户 2026-10-14 裁定要做但不急；冲突类型表在 FIELD-LOG 同日条；先只做等待期只读 / 隔离写 |
| 至少两个反方取交集 | 拒 | 回测：单个反方 8/8，两个同家族反方 2/5、3/5 且一致地指错——一致性不是正确性过滤器；默认 1 个，第二个按内容判定 |
| superpowers 插件（brainstorming / TDD / debugging / writing-plans…） | 退役（v6.1） | 只剩 brainstorming 在用，顶尖模型不需要 skill 才会讨论；SessionStart 法条式注入（「你没有选择」）正是官方说会压低输出的写法；挡它的两个 hook 一起退役 |

## 4. 工具链排查要点

命令突然失效 / skill 不触发 / 文档与命令面不符时：查版本（`/plugin list`、
`npx openspec --version`）→ 跑最便宜的真实命令做 break-check → hook echo 用例复验
（hook 静默死掉是最坏失败模式）→ 先改文档再改实践（约束先行）。
项目行为像旧版（要求确认 subagent、看不见 hook 提醒、问技术题）→ 先看项目 Toolkit 行版本与
`~/.claude/my-work-skill.toolkit-version` 是否相等，不等就是没迁移，不是 skill 坏了。

**Hook 两条法则**（2026-09-08 实测 Claude Code 2.1.259）：工具事件（PreToolUse /
PostToolUse）下模型看得见的是 JSON `additionalContext` 或 exit 2 + stderr，`exit 0 + stdout`
只进 debug 日志（SessionStart / UserPromptSubmit 例外）；脚本只含 ASCII 且 stdin / stdout / stderr
都显式 UTF-8；注册路径走 `$CLAUDE_PROJECT_DIR`（hook 的 cwd 跟工具当前目录走）。echo 用例在独立
隐藏控制台跑；会话乱码 → `cmd /c "chcp 65001 >nul"`（Git Bash 里写 `cmd //c`）。
**OpenSpec config.yaml**：guidance / rules 每项必须是字符串——含「冒号 + 空格」的未加引号条目会被
解析成映射，OpenSpec 打印 "must be an array of strings" 并整体忽略该段（2026-09-15 实测）；一律双引号。

## 5. 版本对照速查

**接口与兼容承诺**（机器级 skill 与项目文件之间的契约；minor 版本内只增不改不删，要改或删 =
major + 迁移段。在途 change 跨版本安全的前提就是这张表：状态在文件里，新 skill 接旧契约）

| 接口 | 内容（v6.0） |
|---|---|
| CLAUDE.md 段名 | North Star / Stack & Conventions（含项目参数行）/ Toolkit（含 `版本:` 行）/ Session Start / Hard Rules / Enforcement |
| backlog.md 段名 | Now（三字段：主线位置 / 下一步 / 悬而未决）/ 主线 / 支线 / Done |
| Loop Contract | Outcome / Verify / Budget / Exit 四字段 + 可选 `Decided:` |
| 路由与收尾 | Route / 主线 两行；Close 的 `Gate:` 行 |
| 回顾产物 | `retros/<date>-milestone.md`（≤40 行）/ `retros/<date>-project-review.md` |
| hooks | `hooks/` 清单、脚本名、matcher（v6.0 只改 warn-route-before-opsx 文案；v6.1 退役两个 superpowers 守卫——清单只减、旧注册留着无害，按 minor 处理，这是「删 = major」的例外） |
| openspec/config.yaml | schema / context / rules.<artifact> / operations.apply\|archive.guidance（每项为引号字符串） |
| 版本戳 | `VERSION` = tag；项目 Toolkit 行 `版本:`；机器 `~/.claude/my-work-skill.toolkit-version` |

**v5.5 → v6.0**（船长模型，FIELD-LOG 2026-10-15；证据 `docs/evidence/2026-10-14-workflow-review/`）

| v5.5 | v6.0 |
|---|---|
| 「语义模糊停下问人」；R2 spec 经人批准；每 change 先 brainstorm；[decide] A/B 停等人拍 | 问人只有四类（方向 / 钱 / 时间 / 找谁）；R2 critic 判定后直接进循环；brainstorm 只在立项与 R3；AI 决定记契约 `Decided:` 行，难撤回在汇总里留否决 |
| route check 六项 + 首问「最不满意」，读者是 agent | 里程碑汇总七段写给人、无代号；「最不满意」移到末行必填，判决先写 |
| project review 第 5–7 项由同会话写；观察位 #4–#6 | 死胡同 / 贬值 / 停掉理由由 fresh-context 方向反方写，并排表交人；触发 = 大投入前 + 机械信号 a / b |
| watchlist / decisions 只增不减，靠记忆复查 | decisions 只收四类人裁定；watch 优先写到会被读到的地方；两次汇总未触发或 ≥8 周到期，AI 审后删行并在汇总列出；路由时按路径 grep 命中才列 |
| 支线计数（Now 四字段）+ 主线段只经回顾批准增删 | 删计数（Now 三字段）；板块 / 终态 / 主线段归人，板块内步骤拆分归 AI 并列入汇总 |
| 一 task 一迭代、5 次上限、stuck 三判据、先写失败测试、Outcome 三分类、Errata 仪式、R0 ≤1 小时、路由三行、Close `主线:` 行 | 全部切除（ablation 台账见 FIELD-LOG）；保留契约内核：Loop Contract、绿提交 + 锚点、失败注记、Verify 真输出、critic / gate 按内容判定 + 底线、dispatch 纪律、land the plane |
| Hard Rules 9 条（含「外部库先验证」「测试是承重墙」） | 7 条：测试条改为「不为变绿弱化 / 删除；行为移除测试随删；动契约先改 spec」；删外部库验证（用户 2026-09-08 裁定 + critic 第 3 条覆盖） |
| 资源限制散在 decisions（同一额度线问 11 次） | CLAUDE.md Stack 项目参数行，定一次 |
| 等待外部事件 = 停 | 等待期做只读 / 隔离写的活，进下次汇总 |
| skill 正文带「回报一次后删除」的槽位 | skill 正文不放观察位；GREEN 观察只记 FIELD-LOG 并带到期日 |
| openspec-config 的 guidance 复述一 task 一迭代 / Errata，且长句被 OpenSpec 忽略 | 只复述契约条目，每项双引号字符串 |

**v6.0 → v6.1**（2026-10-15，用户裁定）：superpowers 插件退役，立项 brainstorm 改为对话（只问属于人的题，打包一次问完）；
hooks 6 → 4（退役 block-replaced-skills、block-superpowers-specs-dir）；change-loop 与 value-review 加「任何时候觉得主线错了，
当场一行说出来，不必等回顾」——v6.0 只允许在汇总里提，是工具包自己造的新锁。

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
| gate 评审派发无授权文本；inline 替代不可见 | CLAUDE.md 常设授权；Close 必填 `Gate:` 行；底线 gate 没跑 = DONE-ungated；R0 免 gate |
| spec 写完直接进循环 | spec critic（fresh-context，分级）→ 修 blocking → R2+ 人批准 |
| value-review = 逐 change 三分类，5 archive / 4 周 | route check + project review；主线里程碑 / 支线计数 / 4 周 backstop / 板块 / 8 周 / 模型换代 |
| 5 hooks，Tier 2 = exit 0 + stdout | 6 hooks（+ warn-backlog-size）；JSON additionalContext / exit 2 + stderr；stdin UTF-8 |

**v5.1 → v5.5**（2026-09-11，详见 FIELD-LOG 同日各条）：WORKFLOW.md 退役（hook 源码落 `hooks/`，archive 交回
`openspec archive -y`，opsx 约定下沉 `templates/openspec-config.yaml`，对齐 OpenSpec 1.13，validate 不加
`--strict`）；版本戳（`VERSION` ↔ 项目 Toolkit 行 ↔ 机器标记文件，Session Start 比对）；echo 配方读
`$LASTEXITCODE`、hook 输出 UTF-8、迁移起点按形态推断；无人值守迁移先提交后确认；North Star 不再写当前阶段。

### 历史迁移步骤（v3 → v5.5；从 project-bootstrap 迁出，只有 Toolkit 行 < v5.5 的项目才用）

按项目 Toolkit 行版本起依次执行（无 `版本:` 行 = v5.3 前立项，按形态推断起点：有 NORTH_STAR.md /
PROTOCOL.md / warn-toolchain-stale → v4；backlog 无 Now / 主线段 → v5.0；hook 无 stdin UTF-8 行 → v5.1；
config.yaml 无 operations 段 → v5.2；hook 无 OutputEncoding 行 → v5.3；拿不准取更早的）。

- **v3 / v4**：NORTH_STAR.md 只保留终态 + 判据 + anti-scope 并入 CLAUDE.md North Star 段后删除该文件
  （Review Log 与历史注记进 git）；`openspec/` 与既有 hooks 保留；移除 `$PROFILE` 中的 `function claude`
  wrapper；删 PROTOCOL.md 与项目内 WORKFLOW.md 副本；注销 warn-apply-phase、warn-toolchain-stale 两个
  hook，删 `.claude/last-toolchain-refresh`。
- **v5.0 → v5.1 backlog 瘦身**（超 8KB 即做）：① 每个历史段按 §6 归属表把读数 / 裁定 / 教训 / 协议抄本
  各抽成一条，搬到 `docs/notes/<date>-<slug>.md`、`docs/decisions.md` 或对应 change 归档（backlog 留一句
  + 路径）；逐 change 的开工前记录与收工摘要整段追加到该 change 归档末尾（OpenSpec：proposal.md，R1 为
  spec-lite.md；其他：`docs/changes/<id>.md`；段名 `## Migrated notes`）；② 挂不到任何 change 或文件的
  交接叙事才删；③ 最新交接压成 Now；④ watch 压成支线一行，长尾进 `docs/watchlist.md`；done 压成 Done 段
  一行；⑤ 无主线段 → 从 North Star + 现有 roadmap 写出。搬，不删信息。超 100KB 用脚本：先量各段字节、
  按字节切块读、建「源行号区间 → 目标文件」映射并断言每一源行恰好归属一次、先算完再写；Bash 里跑 Python
  设 `PYTHONUTF8=1`。项目 CLAUDE.md 对照模板补齐并删除冲突旧规则（subagent「用户确认后再开」、archive
  计数触发、四行路由声明、toolchain-refresh 引用）。
- **v5.1 → v5.2（OpenSpec 项目）**：全局 CLI 先升到最新；`openspec update` 会整体覆盖生成文件，先
  `git log --oneline -- .claude/commands/opsx .claude/skills/openspec-*` 确认没有本地定制再 update（不交互）；
  `openspec/config.yaml` 对照模板补 context / rules / operations 段（`schema:` 行不动）；`.claude/scripts/`
  对照 `hooks/` 重部署全部 hook 并重跑 echo 用例。
- **v5.2 → v5.3**：Toolkit 行补 `版本:`。
- **v5.3 → v5.4**：`.claude/scripts/` 对照 `hooks/` 重部署（补 OutputEncoding、Tier 1 提示语栈无关），
  按 hooks/README 新配方重跑 echo 用例（旧配方 exit 永远 0）。
- **v5.4 → v5.5**：CLAUDE.md North Star 段删「当前阶段重点」行，改为指向 backlog Now。

## 6. 什么写在哪（内容归属）

backlog 膨胀的根因是这些内容没有指定的家；记录膨胀的根因是写入有规则、读回靠记忆。写之前查表；
**热存储**（每 session 或每路由都读：CLAUDE.md、backlog、在途 change 契约、项目参数、watchlist、decisions）
有上限：backlog ≤8KB（hook）；watchlist / decisions 靠只收四类 + 到期收缩；留给未来的条件优先写到它会
被读到的地方。**冷存储**（归档、git、docs/notes、retros、冻结能力的 spec 与测试）随便长。

| 内容 | 家 |
|---|---|
| 终态、成功判据、anti-scope | CLAUDE.md North Star 段（当前阶段只在 backlog Now） |
| 运行须知（命令、耗时、机器产物别手改）；项目参数（资源停止线 / 花钱上限 / 大投入门槛 / 第二反方） | CLAUDE.md Stack & Conventions |
| 主线路径、下一步、触发在望的支线 | backlog.md |
| session 交接（位置 / 下一步 / 悬而未决） | backlog.md Now 段，整段覆盖、债务结转 |
| 留给未来的条件（watch） | 优先：要动的文件头 / Verify 断言 / spec Requirement 下一行；放不下 → `docs/watchlist.md`（同支线行格式，带触发，到期规则同支线） |
| 单个 change 的过程、读数、gate 结果、失败注记、AI 决定（`Decided:`）、事后订正 | change 归档（openspec archive 的 proposal.md，R1 为 spec-lite.md / `docs/changes/<id>.md`）末尾 |
| 已定规格、未开工的步 | 前置探针的归档，或 `docs/notes/`；backlog 主线行只留一句 + 路径 |
| 架构决策 + 为什么 + 失效前提 | capability 级：主 spec `## Architectural Decisions`（注明来源 change；被推翻的改写为 Superseded）；项目级：ARCHITECTURE.md / DESIGN.md Decisions |
| 人的裁定（只限方向 / 钱 / 时间 / 找谁 / 对外不可逆） | `docs/decisions.md`，一行一条人话：日期｜裁定｜理由｜失效前提；技术决定不进这里 |
| 冻结 / 退役能力的 spec、守它的测试、探针 | 移出日常读取与 Verify 路径（冷目录 / 默认不跑的 marker），搬不删；ARCHITECTURE 留一行指针 |
| 不属于任何 change 的探针读数、方法教训、外部事实核实、反方全文 | `docs/notes/<date>-<slug>.md`，一题一文件 |
| 里程碑汇总 / 工程复盘 | `openspec/retros/`（OpenSpec 项目）/ `docs/retros/`（其他）：`<date>-milestone.md` / `<date>-project-review.md` |
| 工具包自身的流程问题 | 汇总 ⑦ `工具包:` 一行 → 工具包会话 grep 收割进 toolkit FIELD-LOG |
