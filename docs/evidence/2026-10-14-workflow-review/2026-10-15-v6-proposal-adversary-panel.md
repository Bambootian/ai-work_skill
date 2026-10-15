# v6 方案：草案 → 反方 → 修订（2026-10-15，未定稿，等用户拍方向）

> **读者**：用户本人（拍方向）与之后写 v6 设计契约的会话。
> **来源**：工具包会话（Claude Fable 5.1）读完 `README.md`（10-14 回顾记录）、FIELD-LOG、三份 skill、模板、hooks、GUIDE、5 个项目的 CLAUDE.md 与知识库相关页后写出草案；再起 6 个 fresh-context agent：3 个独立设计（减法优先 / 契约记忆优先 / 船长模型优先），3 个专攻草案（重流程修重流程 / 证据保真 / 可执行性与迁移）。原始输出在本目录 `raw/panel-results.md`（本机，gitignored），草案原文在 `raw/v6-draft-proposal.md`。
> **状态标记**：【拍定】= 直接落实 10-14 的用户拍定；【推导】= 从拍定推出、或 AI 设计，需用户一句话过；【改旧裁定】= 推翻 2026-09-11 / 09-27 的某条用户裁定，必须点头。

---

## 0. 一页结论

v6 是 major（动 GUIDE §5 接口：Hard Rules 条目、路由三行→两行、Close 行、Now 四字段→三字段、openspec-config 的 guidance），带迁移段，5 个 v5.5 项目由版本戳触发迁移。

四个根子各有一组改动，每条都写了替换掉什么：

| 根子 | 改动 | 替换掉什么 |
|---|---|---|
| B 分工放反 | 问人只剩四类；取消 R2 spec 人批准与每 change brainstorm；AI 决定记 `Decided:` 行；里程碑汇总取代 route check；项目参数定一次 | 「语义模糊停下问」、[decide] A/B 停等、每 change 的人批准点、同一额度线问 11 次 |
| B 方向反方 | fresh-context 外部反方（默认 1 个）；大投入前 + 两条机械信号触发；并排表交人 | project review 第 5–7 项由同会话自己写；观察位 #4–#6；R3 向用户问架构 A/B |
| A 记录只增 | decisions 只收 U 类；watch 先写到会被读到的地方；条目到期 AI 审后删行并在汇总列出；skill 正文不放观察位 | 「全部保留 + 靠记忆复查」；两处已过期的槽位 |
| C 约束防旧失败 | change-loop 删 11 处过程约束，保留契约内核；Hard Rules 9→7；路由两行；spec 只写契约；项目层一次性消融 | 一 task 一迭代、5 次上限、TDD 顺序、三分类、Errata 仪式、R0 数值缰绳等 |
| D 单链等待 | 等待期自主做只读 / 隔离写的活 | 「等 = 停」 |
| 工具包回路 | 汇总留 `工具包:` 一行，工具包会话 grep 收割；GREEN 观察带到期日 | 两处「回报一次后删除」的槽位靠人记得删 |

工具包每 change 必读文本预计从约 15KB 降到约 10KB；项目侧热存储（watchlist 125KB + decisions 91KB）靠 C 组收缩，不设新 hook。

---

## 1. 反方要点与回应（并排）

草案 30 条，反方 52 条反对（15 条 blocking）。全部 blocking 与关键 minor 列在下面；「接受」= 草案已按反方修订，「驳回」= 保留草案并写理由。

### 1.1 三个反方都撞到的同一处（草案最大漏洞）

| 反方要点（谁） | 证据 | 回应 |
|---|---|---|
| 草案在 change-loop 里删掉的规则，还活在两处项目 session 必加载、且优先级更高的文本里：模板 CLAUDE.md North Star 段的「Outcome 三分类」行（5 个项目全带），和 `templates/openspec-config.yaml` 的 apply / archive guidance（「每迭代恰好一个 task」、Decisions 的 Source / Superseded、`## Errata`），由 OpenSpec 在 propose / apply / archive 时注入。F2 文件清单两处都漏了（证据保真、可执行性、重流程三方均提，前两者标 blocking） | `templates/CLAUDE.md:8`；`templates/openspec-config.yaml:24,29,31`；new_review_create 与 finance_tool 的 `openspec/config.yaml` 同文；bootstrap Common mistakes「项目 CLAUDE.md 优先级高于 skill」 | **接受**。F2 加：模板两处同步删改；迁移段加「5 个项目 North Star 段删三分类行」「2 个 OpenSpec 项目 config.yaml 对照新模板整段替换」；顺手修 FIELD-LOG 09-15 记的 YAML 长句被 OpenSpec 忽略的问题（短句 + 引号） |
| 删 `Next:` 行后 `warn-route-before-opsx` 的提示文案（Route / mainline / Next lines）过时，而 F2 写「hooks 不变」 | `hooks/warn-route-before-opsx.ps1:11`；5 个项目 Enforcement 段都挂它 | **接受**。改文案（不改脚本名 / matcher，不算接口变更）、5 个项目重部署并跑 echo 用例 |
| 模板 Hard Rules 是 9 条不是 10（10 是 new_review_create 加了 watch 规则后的数）；「外部库先验证」的删除理由「harness 系统提示已含」在仓库里核不到 | `templates/CLAUDE.md` 9 个 bullet | **接受**。数字改 9→7；理由改为：用户 2026-09-08 审阅全局 CLAUDE.md 时已把它判为 4.6 / 4.7 时代补丁并列入「工具包待删 4 处」（知识库 `2026-09-08-124638` 条），且 spec critic 第 3 条仍实查外部库 |

### 1.2 B 组（方向反方）

| 反方要点（谁） | 证据 | 回应 |
|---|---|---|
| 「≥2 个反方、跨家族优先、每条书面反驳」三个参数全是【AI 提议·未定】被写成 skill 文本；数据指向相反：得 8/8 的是 09-19 的单个反方，09-23 的两个反方都低于工作流内回顾且一致地指错方向；固定派两个正是 09-27 用户嫌的「无论内容默认必走」（重流程，blocking） | README §3.6 结果表；`raw/backtest/SCORES.md` D3=8/11、D1=2/5、D5=3/5；FIELD-LOG 09-27 用户原话 | **接受**。默认 1 个；第二个按内容判定（R3 大投入或项目参数开了跨家族），理由写一行；只反驳不接受的要点，接受的直接变动作；要点 + 反驳受 retro 行限约束。三组设计者也都独立得出「默认 1 个」 |
| 「不加载工作流、把 CLAUDE.md 当证据读」在回测里靠 `git archive` 快照 + 改名 CLAUDE.md / AGENTS.md + `claude -p --setting-sources local --strict-mcp-config` 只读实现；普通 Agent 派发达不到——草案没写配方，等于静默降级（重流程、可执行性均 blocking） | `raw/backtest/PREREG.md` 隔离段；本会话 harness 说明：subagent 会被注入与主会话相同的 CLAUDE.md | **接受**。B4 变体写死三行配方（快照到 scratchpad、约束文档改名、`claude -p` 只读 + git log 预导出）；Agent 派发只作退路并在表头标「独立性弱一档」。harness 事实已核：subagent 确实注入 CLAUDE.md，所以退路的独立性真的弱 |
| 把「大投入」映射到 R3 会让反方成日常仪式：取证项目 09-26 / 27 / 28 三天连开三个 R3（可执行性 blocking） | FIELD-LOG 09-27 读数表 R3×2；decisions L86 / L95 / L103 | **接受**。大投入与路由解耦：新板块 / 改 North Star 或主线段 / 花费超项目参数 / 主线步预估 ≥5 个 change；同一板块 ≤1 轮，除非机械信号命中 |
| 三条机械信号从唯一一次转向事后归纳（README 自标过拟合）；信号 1 需要没人维护的计数器；信号 3 与保留的「Outcome 用可观察词汇」互斥；吸收观察位 #4 把后果从「跑对照 spike」换成「再派人评」——回测三个反方都说推迟的是证伪实验，解法是跑它（重流程 blocking） | README §6「只有一个已知转向」；value-review 观察位 #4 | **部分接受**。只留两条、都从既有产物读出：a = 上期承诺核销里同一项第 2 次 ✗（不需要新计数器，承诺核销就是计数器；若该项是可只读跑的实验 → 等待期直接跑，不起反方）；b = 判据报「达成」而主线仍在继续（地图倒核已有）。信号 3 删。其余候选记 FIELD-LOG 带到期观察 |
| 机械信号是判断题，但汇总里没有信号一行，检测点不在任何必写产物里（可执行性 blocking） | FIELD-LOG 09-11「检测点必须在被加载的文本里」；10-12 route check 确实写了「观察位 #5 未命中」 | **接受**。汇总 ⑤ 必写一行「机械信号 a / b：命中 / 未命中」 |
| 「跨家族（Claude + Codex）」把 new_review_create 的环境写进 skill；方向层跨家族未测 | README §1 术语表；§3.6 三臂全同家族 | **接受**。写成中性要求「有第二个模型家族可用则优先」，不点名；跨家族是否更强记 GREEN 观察 |
| 标定集 09-19 / 09-23 快照写进公开部署的 dispatch-prompt 是项目细节泄漏，raw/ 已 gitignore | README §9 | **接受**。只进 FIELD-LOG |
| 「最不满意」一问是 09-11 用户裁定，且是 09-27 那条 RED 的唯一来源；草案降级它却没说明 | FIELD-LOG 09-11、09-27 首句 | **接受**。改为汇总末行必填（未答写「未答」，不编），判决写在问之前，「没有」不等于「在线」；如实标【改旧裁定】交用户 |

### 1.3 C 组（热存储）

| 反方要点（谁） | 证据 | 回应 |
|---|---|---|
| 草案把 watchlist / decisions 划为「冷」，静默改写了拍定 3 的定义（用户原话把它们列在热），还让两个最大膨胀源落到「随便长」一侧（证据保真 blocking） | README §5 第 3 行原话；`raw/doc_access_output.txt` 两者月读 223 / 231 次 | **接受**。沿用用户定义：热 = 每 session 或每路由都读的（CLAUDE.md、backlog、在途契约、项目参数、watchlist、decisions）；C2 / C3 就是 watchlist / decisions 的上限机制。另一条更激进的路线（契约记忆视角提出）：watchlist / decisions 退出活文档——列为给用户的选项（§3 Q3） |
| 「6 个 change 或 6 周」需要条目出生时间或经手 change 数，模板行两者都没有；`## Expired` 发明新归档段；来源是 retro / dry-run 的条目没有「来源 change」可去（重流程 blocking）。change 计数对突发节奏太快（取证项目 20 天 20 个归档），绑在未开始主线步上的 17 条会在那一步到来前被到期（可执行性） | `templates/backlog.md` 支线行格式；watchlist 中 17/99 条绑 n=3 | **接受**。到期默认「经过 2 次里程碑汇总仍未触发」或 ≥8 周（行出生日 `git blame` 一条命令）；绑定具名未来事件 / 未开始主线步的条目在其到来前免到期；处置 = 删行（git 有）+ 汇总 ③ 一行，不建新段；项目可改 |
| C4 的 capability 绑定 grep 依赖 new_review_create 自长的标签格式，模板没有该字段；4/5 项目无物可 grep；「没命中写『无绑定条目』」把路由第三行加回来（三方均提，两方 blocking） | new_review_create CLAUDE.md Hard Rules 末条；模板支线行无绑定键 | **接受**。grep 键改为路由时已在手的东西：本 change 要动的文件路径 / 模块名 + 主线步 + change-id（OpenSpec 项目可加 capability 名）；命中才写一行 |
| 到期日元规则治标：部署的是静态副本，「过期作废」改不掉文件里的字；skill 正文根本不该放观察位 | README §3.5；本次 diff 实测部署版与仓库相同、含两处过期槽 | **接受**。规则改为「skill 正文不放评估位 / 观察位；GREEN 观察只记 FIELD-LOG 并带到期日」，写进 README 修改约定与 FIELD-LOG 头部 |
| CLAUDE.md ≤6KB 是无读数的新数字且「软约束无 hook」——靠记忆执行，正是根子 A；迁移日 2/5 项目就违反 | wc -c 五项目 4.6–8.7KB | **接受**。删数字；CLAUDE.md 体量交 D4 消融去管，汇总 ③ 报 `wc -c` 读数 |
| 常设偏好放进 decisions.md 与「常设」矛盾；AI 技术决定「跟 change 归档」与主 spec Decisions 双写 | GUIDE §6 架构决策行 | **接受**。常设偏好与项目参数同在 CLAUDE.md Stack & Conventions；`Decided:` 行只列并指路径，架构类指主 spec |
| 删「上轮承诺核销」拿掉了 route check 里少有的显式读回机制 | value-review 末两行 | **接受**。并入汇总 ⑤「上期承诺的那一件落了吗」，它同时是机械信号 a 的数据源 |

### 1.4 A / D / E 组

| 反方要点（谁） | 证据 | 回应 |
|---|---|---|
| 「R1 SPEC-lite 可选」让非 OpenSpec 项目的 Loop Contract 没有落脚文件，打破唯一要守的契约记忆；「R2 四件套只在新 capability 跨模块时」与 R2 定义冲突（可执行性 blocking；证据保真 minor） | change-loop §2「写进 tasks.md 或 SPEC-lite 头部」；zd-tool Stack「根 SPEC.md = spec-lite」 | **接受**。R1 最小产物 = 含 Loop Contract 四字段的单文件（Goal / Non-goals 各一句，Scenarios 按需）——可省的是段不是文件；R2 即 OpenSpec 四件套，不细分 |
| D4「列给用户 keep / kill」等于一次问用户十几道「这条规则近 4 周防住过什么」的技术题，正是拍定 1 要收回的；判定者应是复发不是人（三方均提，一方 blocking） | README §5 第 1 条；§6「先删、看复发」 | **接受**。AI 自决：只审约束过程的规则（must / 禁止 / 先…再…），红线、数据契约、anti-scope 式 Domain Rules、运行须知不动；删除清单进迁移 commit 与首份汇总 ②，用户否决即加回并注模型 |
| 删 Errata 规则同时丢了「订正不进 backlog」的分流；change 之间做的技术决定（选反方模型、改探针口径）没有家 | GUIDE §6；decisions.md 已混进 6 个 Errata 块 | **接受**。留一句分流不留仪式名：「订正与无所属 change 的技术决定追加到相关归档末尾或 docs/notes 一行，不进 backlog / decisions」 |
| 等待期活清单把「方向反方」列进去等于第三个触发入口（专家回件已等 18 天，可反复起）；「热存储到期审」会改热文档，与同条「不动热文档」冲突（三方均提） | README §5 第 7 条；§3.4 | **接受**。等待期可做：探针 / 测量 / 裸模型对照（不花钱或按参数）、到期审只产清单（移出在里程碑执行）、工作流回顾一行；反方只按 B2 触发 |
| A3 把两种读者（用户 / AI 校准）合成一份，却留着支线计数 ≥3 这条非里程碑触发与 Now 的记账字段（重流程 blocking） | value-review 触发表；change-loop §5 计数规则；GUIDE §5「Now 四字段」 | **接受**。删支线计数（Now 三字段，接口 major 本就要动）：09-24 以来四份回顾没有一次由它触发；汇总只在主线里程碑 / 板块收官 / 4 周 backstop / 用户问 / 机械信号时写 |
| 「未声明 = 无此限制」与「花钱超项目参数要问」相撞：没声明参数的项目，钱是从不问还是每次问？ | README §5 第 1、6 条 | **接受**。未声明 = 无停止线；但首次产生真实费用的新渠道仍属「钱」，问一次并写进参数行 |
| 删「不加未被要求的范围」让项目 Hard Rule 依赖用户私有的 ~/.claude/CLAUDE.md，其他部署者看不到 | GUIDE §1 原则 3 | **接受**。保留（一行，且官方「范围纪律」四样之一）。减法视角也选择不动它 |
| 「方向」「难撤回」无可核对定义：6 条难撤回里 3 条是技术类 | `raw/decisions-classified.md` L80 / L95 / L103 / L119 | **接受**。方向锚到可核对对象：改 North Star / 主线段 / anti-scope / 板块终态（= 今天的 R3 触发物）即方向；难撤回各一句：改数据契约、改配置身份使历史读数失效、已对外发出、已花钱 |
| 取消 R2 spec 人批准不是拍定，是从拍定 1 + 2 推出来的，还改掉 09-27 用户刚选的「spec 经人批准」 | FIELD-LOG 09-27 | **接受**标注。如实列为【推导 + 改旧裁定】交用户（§3 Q1）；H1 的风险记 GREEN 观察 |
| F1「部署 / 迁移时收割」只在发版时发生，09-11→10-14 一次也不会触发；换个写法不解决没人读 | README §3.5 | **接受**。如实写成手动回路：汇总行固定前缀 `工具包:`，工具包会话任何时候一条 grep 跨项目 retros 收割；README 修改约定要求改 skill 前先读 |

### 1.5 驳回的反对

| 反方要点 | 为什么不接受 |
|---|---|
| 把「route check」文件名与节律原样保留、只改内容（契约记忆视角） | 文件名 route check 是 agent 词汇，读者现在是人；retro 文件名不在 GUIDE §5 接口表里，改为 `retros/<date>-milestone.md` 不算接口变更；value-review 的触发词保留「route check」别名 |
| 四级路由收成「直行 / 记录 / 方向」三态（契约记忆视角 P9） | 实质（取消 R1 / R2 的人机差别、R2 人批）全部采纳，但 R0–R3 名字不换：Route 行是接口，在途 change 与五个项目的归档都在用；R1 与 R2 只剩产物形态之别（单文件 vs OpenSpec 四件套），对人已不可见 |
| watch 条目一律就地放置、撤销 watchlist 作为活文档（契约记忆视角 P2） | 方向对（放到会被读到的地方零机制），但「只许就地放置」会把小项目的条件全挤进 8KB backlog，且主 spec 变 watch 垃圾场的风险它自己也写了。v6 写成「优先就地放置（要动的文件头 / Verify 断言 / spec Requirement 下一行），放不下才进 watchlist 并带到期」。彻底退出活文档列为用户选项（§3 Q3） |
| 「最不满意」直接删掉，改一句「有不满意随时说」（减法视角） | 它两次产出过别的机制没发现的信号（09-24 重锚定、09-27 gate 机械化）；删的是「第一步 + 唯一渠道」的位置，不是渠道本身 |

---

## 2. 三个独立设计视角：共识与分歧

| 议题 | 减法优先 | 契约记忆优先 | 船长模型优先 | v6 取 |
|---|---|---|---|---|
| 两处过期槽 + 观察位表 | 删，今后带到期 | 删，skill 不放观察位 | 删，README 加到期规则 | 删；skill 不放；GREEN 只在 FIELD-LOG 带到期 |
| 问人范围 | 四类 | 四类 | 四类 + `Decided:` 行 | 四类 + `Decided:` 行（≤5 条，难撤回标 ⚠） |
| R2 spec 人批 | 取消 | 取消（并 R1/R2 合并） | 取消 | 取消，R 名保留 |
| 反方数量 | 1，噪音复发再升 2 | （未展开） | 1，跨家族为项目参数 | 1；第二个按内容 / 参数 |
| 里程碑汇总 | 一份 ≤40 行、无代号 | 同文件名、六段 | Part A ≤20 行给人 + Part B 给 agent | 一份 ≤40 行：前半给人无代号，末尾 agent 快照（`模型:`、承诺核销） |
| 「最不满意」 | 删，换常设一句 | 删 | 移末尾必填 | 移末尾必填【改旧裁定】 |
| decisions.md | 只留 U 类 | 退出活文档 | 只留 U 类 + `Decided:` | 只留 U 类（Q3 可选更激进） |
| 到期机制 | 行尾「到期：」token，缺省下个里程碑 | 不加时钟，挂在 hook 响 + 里程碑两个既有检查点 | （未展开） | 两次汇总未触发或 ≥8 周；具名事件免到期；删行 + 汇总列出 |
| 支线计数与主线审批门 | 全删；板块归用户、步骤归 AI | 保留（must_keep） | 保留审批但 AI 可随时提 | 删计数；板块 / 终态 / 主线段增删归用户，步骤拆分归 AI 并在汇总列出 |
| Outcome 三分类 | 删 | （未提） | 改写为注明读者 | 删三分类；Outcome 写「谁能观察到什么不同」 |
| 测试规则 | 只删顺序与绝对句 | 同 | （未提） | 同；「动契约先改 spec」保留 |
| 冻结 spec / 测试移冷 | （未提） | 规则进 GUIDE §6，项目侧执行 | （未提） | 采纳为 GUIDE §6 一行；项目侧动作归项目迁移轮 |
| bootstrap 旧迁移段 | 删到只剩一句指 tag v5.5 | 移到 GUIDE §5 | （未提） | 移到 GUIDE §5 版本表下 |
| 并行 | 不设计 | 不设计 | 不设计 | 不设计（拍定 8） |

三组对 README §6 的处置也一致：采纳「decisions 只留 U」「观察位到期」「常设偏好定一次」「清理放等待期」「给人与给 agent 分开写」「换人做反方」「契约 vs 流程边界」「项目层消融」；推翻「至少两个反方取交集」「hook 按 capability 推送 watch」「写前先搜旧条目作为规则」「三行人话逐 change」。

---

## 3. 需要你定的（只列方向 / 钱 / 时间 / 找谁）

1. **你的触点收缩到哪**【推导 + 改 09-27 裁定】：开工前只剩「立项 brainstorm（只确认 North Star 与主线）」和「方向态 change（动 North Star / 板块终态 / 主线段 / 超参数花钱 / 对外不可逆）先与你定方向」；R2 的 spec 批准与每 change 的 brainstorm 取消；其余决定在里程碑汇总里给你否决。认不认这条线？
2. **「最不满意」一问**【改 09-11 裁定】：从回顾第一步移到汇总末行必填，判决先写、答案只作输入。同意吗？
3. **热存储的形态**：A 沿用你 10-14 的定义，watchlist / decisions 留着但只收 U 类 + 到期删行 + 优先就地放置（推荐，改动小）；B 更激进：两个文件冻结为只读冷档，条件只写到会被读到的地方，裁定只写在生效处。选 A 还是 B？
4. **反方的第一次实战与第二反方**（时间 / 钱）：第一次放在 n=3 开跑前的方向态路由（推荐，兼作标定），还是等板块 5 收官；new_review_create 要不要把 Codex 第二反方开成项目参数（花你的周额度）？
5. **发版与迁移节奏**（时间）：v6.0 major。推荐先迁 new_review_create 跑一个里程碑看 GREEN，再迁其余四个；也可五个一起。现在等专家回件的空档就开工可以吗？
6. **new_review_create 的项目参数初值**（钱）：Codex 周额度停止线、API 累计上限、「发给专家前必问」是否成立。可以迁移时再给，不急。

我自定的默认值（你不改就按它走）：大投入门槛 = 新板块 / 改 North Star 或主线段 / 花费超参数 / 主线步预估 ≥5 个 change；到期 = 两次汇总未触发或 ≥8 周；4 周没有里程碑也出一份汇总（有日期的 backstop 不被事件替换，这是你知识库里的原则）。

---

## 4. 修订后的 v6 改动清单

### A. 人机分工【拍定 1、2、6】
- **A1** 问人只剩四类：方向（需求意图与边界、North Star、板块终态 / 判据、主线段增删）、钱（超项目参数、新付费渠道首次）、时间（排期、预算延长）、找谁 / 对外不可逆（外发、公开、删数据）。其余 AI 自决，写进契约头可选行 `Decided: <一句一条，≤5，难撤回标 ⚠；>5 = SPLIT 信号>`，随 change 归档。模板 Hard Rules「语义模糊停下问」同句替换。
- **A2**【推导 + 改 09-27】 R2 不再「spec 经人批准」；brainstorm 只在立项与方向态；critic 冲突项与「最不放心处」由 AI 裁定并记 `Decided:`；dispatch-prompt「多 reviewer 结论冲突人裁」改为 AI 裁、只有四类交人。
- **A3** 里程碑汇总取代 route check 六项。文件 `retros/<date>-milestone.md`，≤40 行，前半人话无代号：① 你现在能做到的新东西；② 本期我定的事（`Decided:` 聚合，难撤回在前，可否决）+ 花费对参数线；③ 到期移出的条目；④ 反方并排表或「未触发」；⑤ 主线位置 + 下一步 + 上期承诺落了吗 + 机械信号 a / b；⑥ 需要你定的（四类，无则「无」）；⑦ `工具包:` 一行；末行「最不满意？」+ `模型:`。②③ 由命令生成（`git log <上次汇总>..HEAD -- <archive dir>` + grep `Decided:`），不靠记忆。触发：主线里程碑 / 板块收官（并入 project review 的判据逐条与地图倒核）/ 4 周 backstop / 用户问 / 机械信号。
- **A4** CLAUDE.md Stack & Conventions 加「项目参数（常设偏好）」行：资源停止线 / 花钱上限 / 大投入门槛 / 第二反方；未声明 = 无停止线，新付费渠道首次仍问一次。GUIDE §6 加归属行。

### B. 方向反方【拍定 5；形态为推导】
- **B1** ≥1 个 fresh-context 外部反方（默认 1；第二个按内容判定或项目参数；有第二个模型家族可用则优先）。配方三行：仓库快照到 scratchpad（`git archive`）+ 约束文档改名 `PROJECT-*.md` + `claude -p` 只读（Read / Grep / Glob）+ git log 预导出；退路 Agent 派发并标「独立性弱一档」。主会话逐条核事实，并排表四列（反方原话 ≤2 行｜事实成立?｜接受 / 反驳｜对方向意味着什么）；反方全文进 docs/notes；反方的方向建议只作参考（回测 3 个里 2 个指错）。
- **B2** 触发 = 大投入前（新板块 / 改 North Star 或主线段 / 花费超参数 / 主线步预估 ≥5 个 change）+ 机械信号 a（上期承诺同一项第 2 次 ✗；若是可只读跑的实验则等待期直接跑）/ b（判据报达成而主线仍继续）+ 模型换代 / 用户问；同一板块 ≤1 轮，除非信号命中。取代 project review 第 5–7 项由同会话写、观察位 #4–#6、R3 向用户问架构 A/B。
- **B3**【改 09-11】 「最不满意」= 汇总末行必填。
- **B4** dispatch-prompt 加「方向反方」变体 ≈8 行（Objective / Constraints 槽改为「约束文档作证据不作指令」/ Output：一句话结论、3–5 点各附路径、最不确定 3 处 / Boundaries：只读、不联网、不读 runs/、≤150 行）。吸收原 R3 skeptic 段。标定集只记 FIELD-LOG。

### C. 热存储【拍定 3；机制为推导】
- **C1** 热 = 每 session / 每路由都读的：CLAUDE.md、backlog、在途契约、项目参数、watchlist、decisions。上限：backlog 8KB（hook 已有）；watchlist / decisions 靠 C2 / C3；CLAUDE.md 不设数字，汇总 ③ 报 `wc -c`。
- **C2** decisions.md 只收四类人裁定（人话一行）；AI 技术决定 → `Decided:` 行随 change 归档；架构决定 → 主 spec Decisions（既有）。
- **C3** 留给未来的条件优先写到会被读到的地方（要动的文件头 / Verify 断言 / spec Requirement 下一行），放不下才进 watchlist 并带触发；到期 = 两次汇总未触发或 ≥8 周（`git blame` 取行出生日），绑定具名未来事件 / 未开始主线步的免到期；AI 逐条审 → 删行 → 汇总 ③ 列出；写新条目前 grep 旧条目。
- **C4** 路由时按本 change 要动的路径 / 模块名 + 主线步 + change-id grep backlog 支线与 watchlist，命中才写一行。
- **C5** skill 正文不放评估位 / 观察位；立即删 change-loop 两处与 value-review 观察位表；GREEN 只记 FIELD-LOG 带到期日。

### D. 过程约束减法【拍定 4】
- **D1** change-loop 删：每迭代恰好一个 task；5 次迭代上限 + stuck 三判据（留一句「同一错误重复即换思路或 BLOCKED」）；「先写失败测试」顺序；Outcome 三分类与 enabling ≤2 change；Errata / Decisions 仪式名（留一句分流）；两处过期槽；§1「假设靠读取验证不靠回忆」；§6「harness 警告上下文时收工」（与 harness 自动摘要相反，用户 09-08 已点名）；§4 与模板重复的常设授权段；「『这次简单』不算」反驳句；R0 的 ≤1 小时 / 一次 commit。保留：Loop Contract 四字段（+ 可选 Decided）；只在绿提交 + 锚点；失败注记进文件；Verify 真输出；Spec 自检 `Critic:` 行 + 按内容判定；gate 底线 + 按内容判定 + 增量 gate 规则；「gate = fresh-context，inline 不算」+ DONE-ungated；dispatch 槽位 + 禁孙 agent；land the plane。目标 ≤7.5KB（现 11.0KB）。
- **D2** 模板 Hard Rules 9 → 7：路由先行；Verify 真输出；绿提交；「不为变绿弱化或删除失败测试；被测行为移除时测试随删并写明；动契约（数据格式 / CLI / 预登记口径）先改 spec」；不加未被要求的范围；问人四类（替换语义模糊）；subagent 一句（dispatch 纪律 + 常设授权含方向反方）。删「外部库先验证」（用户 09-08 裁定 + critic 第 3 条覆盖）。North Star 段删「Outcome 三分类」两行。
- **D3** 路由声明两行（Route + 主线，删 Next）；Close = Verify 输出 + 出口态 + `Gate:` 行 + backlog 更新 + archive 一条命令；删 `主线:` 复述、工具名点名。hook 文案同步。
- **D4** 迁移时项目层一次性消融：AI 自决只审过程类规则，红线 / 数据契约 / Domain Rules / 运行须知不动；删除清单进迁移 commit + 首份汇总 ②；复发定点回装并注模型。
- **D5** R1 = 单文件含 Loop Contract（Goal / Non-goals 各一句，Scenarios 按需）；R2 = OpenSpec 四件套；lite schema 正式化（`schema: lite` + `skip_specs: true`）；spec 只写契约与 scenarios，过程进 commit / 归档。

### E. 等待期【拍定 7、8】
- **E1** Now 下一步为「等 <外部事件>」且无可路由主线步时不停机：探针 / 测量 / 裸模型对照（不花钱或按参数）、到期审（只产清单）、`工具包:` 行；只读或只写 docs/notes、探针目录、独立 worktree；做完进下次汇总。
- **E2** 并行不设计；README §7 类比表留档 FIELD-LOG「待琢磨」。

### F. 工具包回路与发版
- **F1** 汇总 ⑦ 固定前缀 `工具包:`；工具包会话 grep 跨项目 retros 收割（手动回路，如实写）；README 修改约定加「改 skill 前先读各项目最近两份汇总的 `工具包:` 行」。
- **F2** 文件清单：VERSION v6.0；README 版本表 + 修改约定；GUIDE §1（契约 vs 流程两行）/ §2 速查 / §3（四条工程原则：数据逻辑进 CLI 不进 skill、不用正则审自由文本做隔离、不自定没人要求的契约、环境知识进 Stack 或知识库）/ §5 接口表 + 迁移段 / §6 归属表（热 / 冷、decisions 语义、冻结能力移冷）；templates：CLAUDE.md、backlog.md（Now 三字段、「待人拍的」措辞）、openspec-config.yaml（删 apply guidance 第一条与 archive 的 Decisions 格式 / Errata 句，修 YAML 长句）；hooks：warn-route-before-opsx 文案；skills：change-loop、dispatch-prompt、value-review、project-bootstrap（旧迁移段移 GUIDE §5；description 加 v5.5；Step 1 / 2 人只确认 North Star 与主线；v5.5→v6 段）。
- **F3** 迁移（5 个项目，版本戳触发，单独 docs commit）：CLAUDE.md Hard Rules 替换、North Star 删三分类行、加项目参数行（new_review_create 初值问用户，其余写「无」）；D4 消融；backlog Now 删支线计数；decisions.md 头部加「此后只收四类人裁定」；watchlist 不清理（首次到期审在下一里程碑）；2 个 OpenSpec 项目 config.yaml 同步；route hook 重部署 + echo；在途 change 按旧格式收尾（删行是子集，不补）；finance_tool 先了结 Now 里「v5.5 迁移 commit 待确认」；Toolkit 行 v6.0。
- **F4** FIELD-LOG 收口：09-27 GREEN 观察位用 09-29→10-13 读数关闭（gate 87% 真缺陷，未发现可归因于免跑轮的漏网）；09-22「Loop Contract 要必不缺应进模板或 hook」→ v6 以「R1 文件 = Loop Contract」处置，不加 hook（无契约缺失的 RED）；09-23「守卫自检路径」→ 延后，触发 = 下次改 hook；09-15 YAML → F2 顺手修。

### G. 不做
- 新 hook；改 skill 名或触发词；并行调度；项目侧清理（冻结代码测试移出、PowerShell 逻辑进 CLI、watchlist 实际清扫）——归项目迁移轮。
- 撤回表五项（gate 刀背、估算偏差、额度通用、刀背在代码复杂度）未重提；三位反方逐条核过。

---

## 5. 执行顺序与 GREEN 观察位

按 README 修改约定：① FIELD-LOG 先记本文为 RED 的落点 + ablation 台账（D1 / D2 每刀一行：切除项 / 守护的失败 / 复发信号）→ ② 设计契约 `docs/specs/2026-10-xx-v6-captain-model-design.md`（本文定稿后压成）→ ③ GUIDE / README → ④ skills / templates / hook 文案 + echo 用例 → ⑤ 部署 ~/.claude/skills → ⑥ new_review_create 迁移并跑一个里程碑 → ⑦ 其余四个项目。

GREEN 观察位（全部记 FIELD-LOG，到期 2026-11-30 或注明次数）：
1. 首份里程碑汇总 ≤40 行、无代号、用户有反应（答了末行或否决了 ② 任一条）——2 个里程碑。
2. 汇总 ⑥ 的问题每里程碑 ≤1 条——2 个里程碑。
3. 首次方向反方：并排表行数、接受 / 否决条数、反方方向建议与最终决定是否相反（回测预期相反）——1 次实战。
4. 到期审：移出条数 vs 用户否决条数；真跑暴露的缺陷其条件曾在被移出条目里 = RED——2 个里程碑。
5. 等待期产物是否碰到隔离区外路径——1 个等待期。
6. 字节：change-loop ≤7.5KB、value-review ≤5KB、bootstrap ≤10KB、模板 CLAUDE.md ≤2.5KB；迁移后 new_review_create CLAUDE.md 读数。
7. ablation 复发信号：stuck / 上限（同一错误签名重复 ≥3 次仍在改）、R2 人批（用户在汇总里否决了一条事前批准本可拦住的 R2 决定）、TDD 顺序（gate C 类占比升过 7%）、支线计数（用户再说「钻牛角尖」而信号未亮）——2026-12-31。

---

## 6. 方法与局限

- 面板 6 个 agent 均 fresh-context、只读，各自读到的是同一套文件；设计者之间、反方之间不共享结论。约 101 万 token，18 分钟。
- 反方的「证据」我逐条核过路径与读数；两处反方自标推测（subagent 是否注入 CLAUDE.md；harness 是否含外部库验证）已由本会话 harness 说明核实：前者注入，后者不含。
- 回测仍只有 3 次 2 个日期；gate / decisions 分类由 subagent 做且约一半 change 记录不全（README §9）。本文的量化承诺（字节目标、到期默认值、大投入门槛）是设计值，不是读数。
