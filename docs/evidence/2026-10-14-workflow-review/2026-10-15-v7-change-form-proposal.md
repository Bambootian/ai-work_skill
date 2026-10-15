# v7 方案：change 形态脱离 OpenSpec（spec-in-place + 单文件 change）——设计 → 反方 → 修订（2026-10-15，未定稿，等用户拍方向）

> **读者**：用户本人（拍方向）与之后实现 v7 的会话。
> **来源**：用户 2026-10-15 的方向判断（原话见 §0）→ 3 个 fresh-context 独立设计（一页纸形态 / 保留 OpenSpec 收窄 / 契约记忆与迁移现实，原文 `raw/openspec-designs.md`）→ 工具包会话合成 v7 草案（`raw/v7-draft-proposal.md`）→ 2 个 fresh-context 反方（重流程与契约记忆丢失 / 可执行性与迁移现实，原文 `raw/v7-refute.md`）→ 本修订。raw/ 在本机，gitignored。
> **状态**：方向【用户拍定】；形态细节【AI 设计】，技术题由 AI 定，§7 只列方向 / 时间题。

---

## 0. 结论

用户方向（原话）：「主 spec 是真的契约记忆，这是值得守住的部分；openspec 的四步仪式文件，目前只能证明『写下契约让 fresh-context critic 能打』有价值，证明不了四个文件比一页说明简洁清晰的纸或者流程编排图更好，绝非当前时代的最优解；应该像跳出 superpowers 那样，思考脱离 openspec 的限制，设计我们自己 skill 的形态最优解。」

三份独立设计中两份收敛到同一形态：**一个 change 一个文件；主 spec 在 change 内就地改；delta 就是 git diff；归档就是 git mv；退役 opsx 生成 skill、validate、archive 合并、config 注入、route hook。** 第三份（保留 OpenSpec、自定义 schema 收窄）自己的结论是：省掉的只有 design.md，留下的恰是用户点名的仪式，还给工具包文本添第三个家。两个反方都没找到推翻方向的反例；站不住的是合成稿的四处设计与若干读数，已全部按反方修订（§4）。

**v7.0 = major**（动 GUIDE §5 接口：删 config.yaml 行、hooks 4 → 3、Loop Contract 位置、归档文件名）。

---

## 1. 读数（反方核过、已按源数据订正；均取自 new_review_create 09-15 → 10-15）

- 主 spec「月读约 230 次」的构成：Bash 228 = grep 110 + sed 53 + openspec CLI 40 + cat/head 11 + git 10 + python 4；Read 12 次（11 次带 offset 落在 Requirements 段）。AI 把主 spec 当查表用（按 Requirement 名 / Decision ID 定位），不通读。⇒ 主 spec 的文件与结构必须留；读法不依赖 OpenSpec（40 次 CLI 读是 `validate --specs` / `show`，可由 grep 替代）。
- `openspec validate <change>` 月 202 次，配对出结果的 11 次失败全是「MODIFIED 块漏抄旧 scenario」（≥4 个不同 change）——delta 机制自造的风险；`validate --specs` 24/24 通过。
- `openspec archive` 月 49 次调用，配对出 26 次 OK、0 次拦截（约 20 次结果未配对）；它从未在 validate 之后再拦过东西。Architectural Decisions 的 Source / Superseded 一直手写：338 条 Decision 里 316 条带 Source，缺的 22 条全是 06-08 / 06-12 初建时的，此后每份被动过的 spec 100% 带 Source；CLI 源码 0 处实现。
- 7 个生成 skill 里 5 个（explore / sync / archive / verify / update）零调用；propose / apply 含 29 处「ask the user / wait for a new user request」，与船长模型正面冲突；每个 R2 载入 32.9KB 生成指令，change-loop 本体 9.3KB。
- delta 文件累计 1,145KB ≈ 主 spec 全量 1,158KB 的影子复制。design.md 的决策进主 spec AD 的比例：全时段约 75%，近 5 个 R2 只有 49%（51 → 25 条）——另一半是备选、风险、迁移叙事。
- 在途期直接改主 spec 的先例约 9 个 commit / 5 个月，其中 5 个在 writing-review-form 一个 change（gate 修复期），全是 ≤7 行外科式改动，0 次丢 scenario；另约 10 个「归档外 commit」是 v5.2 前 Close 时的手工合并，仍属交付态写入。⇒ 就地改是例外不是常态，但外科式改动比 MODIFIED 整块重打字更不易丢 scenario（后者一个月漏 11 次）。
- 归档的消费者在找上一轮的 Close 与读数（`grep '^## Close'` / `passed` 124 次），不重读 proposal 叙事。09-24 以来 13 个 R2 / R3 归档 13/13 带 delta ⇒ 对照路线「delta 只在契约真变时写」几乎省不到东西。
- 近 12 个归档：10 个当天归档、1 个次日、1 个 9 天（改 spec 最多的那个）。近 10 个 R2 的 propose commit 全部同时加入 proposal + delta + tasks（单 commit）。
- 口径注：只计主会话 transcript，正则分类，validate 26 次、archive 约 20 次结果未配对。

---

## 2. 修订后的形态

### 2.1 目录（不搬家，三种既有形态如实并存）
- 既有 OpenSpec 项目（new_review_create、finance_tool）：`openspec/specs/<cap>/spec.md`、`openspec/changes/<id>/`、`openspec/changes/archive/<date>-<id>/`、`openspec/retros/` 原地，文件名不改；85 + 12 个旧归档一字不动。
- 新中型项目（有能力主 spec）：`docs/specs/<cap>/spec.md`、`docs/changes/<id>/change.md`、`docs/changes/archive/`、`docs/retros/`。
- 小项目（无主 spec；zd-tool / sports / energy 现状）：根 `SPEC.md` → 收尾移入 `docs/changes/<id>.md`，不变。
- Session Start 找在途 change 写两句：「`<changes dir>/*/change.md`，或根 `SPEC.md`」。不加配置项；specs / changes 目录以项目里存在的为准（`openspec/` 或 `docs/`）。

### 2.2 一个 change 一个 `change.md`（R1 与 R2 同形；目录可放旁文件，change.md 是唯一必有文件）
```
# <id>
Route: R<n> — <一行理由>
主线: …
## Loop Contract          Outcome / Verify / Budget / Exit / Decided（可选）/ Critic: / Gate:
## Why                    ≤10 行人话：问题、为什么现在、谁能观察到什么不同
## Non-goals
## Spec 改动               一行一条：<cap>/spec.md: ADDED <名> | MODIFIED <名>（改了什么）| REMOVED <名>（理由）| Decision <ID> 新增 | <ID> → Superseded。正文在主 spec，差异 = git diff
## Decisions（可选）        只写会决定 Fails when / Superseded 的决策与备选，一条一段：为什么 / 失效前提 / 没选 X 因为；拟进主 spec AD 的标 ★，Close 时只搬 ★
## Scenarios              本 change 不动主 spec 时写 WHEN/THEN；动了主 spec 则只写端到端验收（WHEN/THEN 在主 spec）
## 流程（可选）            ≥3 阶段且带分支 / 重试 / 多执行方的编排才画，mermaid；顺序与分支本身是契约时画在主 spec 那条 Requirement 里，替换编号列表 + 例外散文
## Tasks                  - [ ] N.N <任务> — 验证：<命令 → 期望>
## 注记                    失败注记 append（tried / observed / hypothesis）
## Close                  Verify 真输出 / Outcome 一行 / Gate 行 / Decided 聚合 / 出口态 / 读数；归档后订正追加于此
```
接口只锁 `## Loop Contract`、`## Tasks`、`## Close` 三个段名与 `Decided:` 行（有 grep 消费者）；其余段名是模板建议，可增删不升版。

### 2.3 主 spec 就地改（有 specs 目录的项目，R1 / R2 同规则）
- 路由后直接改 Requirement / Scenario；新 capability 新建 spec.md（6 行骨架写在 change-loop 正文：标题 / Purpose（不得留占位）/ Requirements / Architectural Decisions）。
- Decision 写进 `## Architectural Decisions`，带 **Fails when** 与 `*Source: change <id> (<date>)*`——**只写一次，不设 (in flight) / (archived) 两态**（反方：两态标记不在任何读路径上，近 4 个月 Source 覆盖率已 100%，两态是为新形态自造的风险设新仪式）。被推翻的旧条首行改 Superseded。
- 在途性由两样既有东西承担：`ls <changes dir>/*/change.md` 列出在途 change；其 `## Spec 改动` 清单列出被改的 Requirement。里程碑汇总 ⑤ 顺带列出在途 Requirement（读清单，不加标记）。
- **diff 基线 = 加入 change.md 的那个 commit 的父**：`BASE=$(git log --diff-filter=A -1 --format=%h -- <changes dir>/<id>/change.md)^`。不依赖「spec 改动另起 commit」的习惯（近 10 个 R2 都是单 commit），也含工作树未提交改动。
- **critic 与 gate 用同一条命令、同一范围**：`git diff $BASE -- <## Spec 改动 列出的 spec 文件>`。范围限定到清单里的文件，防并行或他人改动混入。critic 输入 = change.md + 该 diff + 代码只读；gate 输入 = 代码 diff + change.md + 该 spec diff（反方：原稿 gate 拿「段」不拿 diff，放掉机器保险后删 scenario 的 `-` 行就没有读者了）。dispatch-prompt 7 条清单不变，第 1 / 5 / 6 条改措辞。
- WITHDRAWN：`git diff $BASE -- <spec 文件> | git apply -R` 只撤本 change 的 hunks（不 checkout 整文件）；change.md 写 WITHDRAWN 段后 git mv 归档。
- SPLIT：子 change 的 `## Spec 改动` 继承相关行，Source 行里的父 id 不改（父归档为 SPLIT 并指向子）。BLOCKED / 等待期：在途主 spec 段算热存储，等待期不碰；里程碑汇总 ⑤ 列出。

### 2.4 Close（有序五步，一个 commit `archive(<id>): …`）
① Close 段 append（Verify 真输出 / Outcome / Gate / Decided / 出口态）；② 核主 spec：本 change 的 Decision 都带 Source、被推翻的已 Superseded、新 spec 的 Purpose 非占位；③ `git add` 旁文件后 `git mv <changes>/<id> <changes>/archive/<date>-<id>`，`test ! -d <changes>/<id>`；④ backlog 更新（主线打勾 / 支线删行 / Now 覆盖）；⑤ 可选 lint：`openspec validate --specs`（只对 `openspec/` 项目有效）或通用一行 `grep -L '#### Scenario' <specs dir>/*/spec.md`。
归档后复原「这个 change 改了哪些契约」：`git diff $(git log --follow --diff-filter=A -1 --format=%h -- <archive>/<id>/change.md)^..<archive commit> -- <specs dir>`，写进 change-loop §5 一行。

### 2.5 value-review 不变
① 从归档 change.md 的 Outcome 行汇总；② `git log … -- <archive dir> docs/notes` + grep `Decided:`；⑤ 加「在途 change 的 Spec 改动」一行。

### 2.6 退役
项目内 7 个 openspec-* skill（79KB）+ 7 个 opsx command（76KB）、`openspec/schemas/lite/`、config.yaml 的 rules / operations、`templates/openspec-config.yaml`、hook `warn-route-before-opsx`（4 → 3，matcher 已无对象，路由两行进了文件头）、bootstrap 的 OpenSpec 前置 / init / schema init、「Requirement 正文保留英文 SHALL / MUST（validate 依赖）」要求。

---

## 3. 守住 / 放掉 / 真损失

- **守住**：主 spec 文件与结构（Requirement + WHEN/THEN Scenario + AD 的 Source / Superseded / Fails when 三件，格式仍 OpenSpec 兼容，可逆）；Loop Contract 四字段 + Decided；一份 fresh-context critic 可攻击的书面物（change.md + spec diff）；决策与备选有家（可选 Decisions 段，只搬 ★ 进 AD）；归档作冷存储、`Decided:` 可 grep、`git log -- <archive dir>` 圈定一期；85 + 12 个归档与 24 份主 spec 一字不动。
- **放掉**：四件套拆分、delta 文件、`openspec validate <change>`、archive CLI 合并、opsx 分步引导与停等、config 注入、`.openspec.yaml` / schema / skip_specs、英文 SHALL / MUST 要求；design.md 里不影响 Fails when / Superseded 的叙事。
- **真损失（如实）**：
  ① 主 spec 在 route → Close 之间写的是意图不是已交付。缓解靠三样既有东西：在途 change 可 `ls` 出来、`## Spec 改动` 清单、短窗口（近 12 个归档 10 个当天归档）。**前提：change 串行，或并行时每个 change 一个 worktree**——同分支并行就地改同一 spec 是不可见覆盖（反方指出原稿把它写成了优势）。这条进拍定 8 并行设计的硬前提。
  ② 「MODIFIED 丢 scenario」的机器保险。替代：critic 与 gate 都读同一条 spec diff，`-` 行可见；可选 lint 查「Requirement 无 scenario」（`docs/specs/` 新项目只有 grep 一行，无 CLI）。实证：就地外科式改动 5 个 commit 0 次丢 scenario，而 MODIFIED 整块重打字一个月漏 11 次。
  ③ WITHDRAWN 要用 `git apply -R` 撤本 change 的 hunks（85 个归档里 1 例）。
  ④ 新 spec 的 Purpose 没有机器占位检查（CLI 曾抓过 2 处自己写的 TBD）：骨架写明不得留占位，Close ② 核一眼。

---

## 4. 反方要点与回应（并排）

| 反方要点（谁） | 证据 | 回应 |
|---|---|---|
| `(in flight)` / `(archived)` 两态 Source + Close 翻写 + dispatch 补行是三件新仪式，守的是新形态自造的风险，且标记不在读路径上（读 Requirement 的人看不到挂在 Decision 上的标记）；「决策时写 Source 更可靠」无 RED，近 4 个月覆盖 100%（重流程 blocking） | 主 spec 338 Decision / 316 Source，缺的 22 条全是 06 月初建；`grep 'in flight'` 0 命中；读路径是 grep Requirement → sed 读段 | **接受**。Source 只写一次；在途性由 `ls` + 清单承担；dispatch Context 槽只改一句措辞 |
| design.md 决策约一半（近 5 个 R2 51 → 25）从未进 AD，备选 / 为什么不选在新骨架无家；75% 是全时段数；设计 2 抛给人的「R2 设计决策还要不要留书面物」被合成稿删掉（重流程 blocking） | writing-review-form D4 / D5 / D13、multi-cite-coverage L52 / L170 带备选；GUIDE §3 自己的理由「防止半年后重新调研」 | **接受**。change.md 加可选 `## Decisions`（只写决定 Fails when / Superseded 的决策与备选，★ 进 AD）；读数改 49%；形态是技术题由 AI 定，不再问人 |
| 「并行时冲突可见」写反：同分支就地改同一 spec 是静默互相覆盖，A 的 critic diff 会吞 B 的改动；未声明对拍定 8 的依赖（重流程 blocking） | FIELD-LOG 待琢磨表「主 spec 归档合并的非原子读改写」；用户偏好「就在当前分支做」 | **接受**。写成前提：串行，或并行时每 change 一个 worktree；critic / gate diff 限定到清单文件；进并行冲突表 |
| gate 拿「段」不拿 diff，critic 跑在内环之前，而就地改主 spec 发生在内环里——`-` 行没有 fresh-context 读者（重流程 blocking） | writing-review-form 5 个在途改 spec 的 commit 全在 critic 之后 | **接受**。gate 与 critic 同一条 diff 命令 |
| 基线取 route commit 自身：近 10 个 R2 的 propose commit 都同时加入 proposal + delta + tasks，v7 同形习惯下 `route..HEAD` 为空，critic 对空 diff 报 PASS；WITHDRAWN 的 checkout 同样回不掉（可执行性 blocking） | `git log --diff-filter=A` 10/10 单 commit | **接受**。基线 = 加入 change.md 的 commit 的父，不写 `..HEAD`；WITHDRAWN 用 `git apply -R` |
| 三处合起来没定义：有主 spec 的项目 R1 要不要就地改；小项目根 SPEC.md 去留；glob 匹配不到根 SPEC.md 与平铺 `docs/changes/<id>.md`；energy 此刻有在途根 SPEC.md（可执行性 blocking） | energy/SPEC.md 在途自 09-20；nrc 近 7 个 R1 有 3 个带 delta | **接受**。§2.1 写明三种形态并存；R1 / R2 同规则；Session Start 两句 |
| 其余四项目都在 v5.5，不是 v6.1；「只改两处」漏了 v5.5 → v6.0 → v6.1；「现在切」等于解除分批裁定 ④ 却未声明（可执行性 blocking） | 四项目 CLAUDE.md 版本行均 v5.5 | **接受**。迁移累计一次做；§7 第 1 题明写「选现在 = 同时解除分批裁定」 |
| 读数夸大：228 不全是 grep / sed（163 + 40 CLI）；「约 20 个在途手改」实为约 9，另 10 个是 v5.2 前 Close 时手工合并；archive 45 应为 49 且 20 次未配对；75% 双写近期只 49% | 源设计原始分解 | **接受**，§1 全部订正 |
| 可选 CLI lint 不是零成本：CLI 在 = `openspec update` 随时重生成 7 skill；`docs/specs/` 新项目跑不了 validate；只为一条可选命令活着的 config.yaml 是既定前提 | FIELD-LOG 09-11 重生成先例 | **部分接受**。写明「永不 `openspec update`」；lint 只覆盖两个旧项目，新项目用 grep 一行；config.yaml 留不留在迁移 ⑦ 实测后定（validate 不依赖它就删）。CLI 卸不卸交人（§7 第 2 题） |
| 把 9 个段名全升为接口是造锁 | 只有 Loop Contract / Decided / Close / Tasks 有 grep 消费者 | **接受**。接口只锁三段名 + Decided 行 |
| 冻结能力 5 份主 spec 移冷搭车进迁移，破坏「一个 commit 可 revert」，且是未被要求的范围 | 用户全局 CLAUDE.md「不顺手改邻近代码」 | **接受**。拿出，作项目侧独立 R1，记 backlog 支线 |
| SPLIT / BLOCKED / 等待期的长窗口没处置；Close 顺序与 commit 数未定；`git mv` 不搬未跟踪旁文件；复原配方缺失；GUIDE §2 / §3 / §4 四处 OpenSpec 前提文本未列；迁移漏 backlog Now 待确认行、引用清扫、部署与标记、nrc Enforcement 行仍列已退役 hook；v6 GREEN 与 v7 同期无标注机制；「一个文件」会被读成禁旁文件（均 minor） | 各处路径与行号见 raw/v7-refute.md | **全部接受**，已写进 §2.3 / §2.4 / §6 / §8；nrc Enforcement 行已单独修（commit 于 2026-10-15） |

反方站得住的（他们试过打）：退役 7 skill / 7 command / config 注入 / lite schema / route hook；R1 R2 同形单文件（breadth-gate 的 spec-lite 已是该形）；主 spec 与归档 0 改动且格式可逆；delta → git diff 对旧文本零损失（旧文本从来只在 git 里）；就地外科式编辑不易丢 scenario 的实证；拒绝对照路线的理由；删 SHALL / MUST 要求；value-review ②③ 命令照样成立；src / tests / Codex 端 / watchlist / decisions 无前瞻性引用需要改。

---

## 5. 对照路线（保留 OpenSpec、自定义 schema 收窄到 proposal + tasks）为什么不选

它自己的设计结论：schema 没有 `specs` artifact 时主 spec 永不自动合并，所以主 spec 也得直接改——与本形态的真实差别只剩文件数（3 vs 1）和「仍跑 opsx 命令面」。删掉的只有 design.md；留下的恰是用户点名的仪式：delta 格式（13/13 R2 带 delta，省不掉）、validate、每 change 的 yaml 标记、experimental 的 schema 还要手改 2 个 requires 字段、`skip_specs` 二值判断扩到 R2；还给工具包文本添第三个家（schema instruction + 模板），正是 v6 面板三方都撞到的「被删规则活在另一处加载文本里」的形态。它值得选的唯一情形：想为「MODIFIED 不丢 scenario」这层机器保险继续付整条 OpenSpec 版本面的维护（4 个月 3 次重生成、1 次 guidance 被整体忽略一个月、lite 不是内建）。

---

## 6. 接口与迁移

- **接口（major v7.0）**：GUIDE §5 删 `openspec/config.yaml` 行（或改为「遗留，仅 schema 行」，看迁移 ⑦ 实测）；hooks 4 → 3；Loop Contract 位置 = change.md 头部；归档文件名 change.md；新增「change.md 接口段名：Loop Contract / Tasks / Close + Decided 行」一行。
- **工具包侧**：change-loop §1（R1 / R2 产物、三种目录形态）/ §2（Loop Contract 宿主）/ §5（Close 五步、复原配方）/ §6（Session Start 两句）；dispatch-prompt critic 段（输入与第 1 / 5 / 6 条）与 reviewer 段（spec diff）；value-review ⑤ 一句；bootstrap Step 0 删 OpenSpec 前置 / Step 2 中型项目改为建目录 + 6 行主 spec 骨架 / description 去 OpenSpec 字样 / 迁移段加 v6.1 → v7.0 并写明「永不 `openspec update`」；GUIDE §1 边界句 / §2 回退格「主 spec 就地改 + git」/ §3 加「OpenSpec 四件套 | 退役（v7.0）」行 / §4 两段 OpenSpec 排查文本标历史 / §5 / §6；templates/CLAUDE.md Session Start 与 Enforcement；删 templates/openspec-config.yaml；删 hooks/warn-route-before-opsx.ps1 + README 表；README 树与版本表；VERSION；FIELD-LOG 条目（ablation 四行：四件套拆分 / delta + validate / archive CLI / route hook，复发信号不以文件名为对象）。部署 `~/.claude/skills` + 标记 v7.0。
- **new_review_create 迁移**（当前 0 个在途 change；一个 docs commit，可 `git revert`）：① 主 spec 0 改动；② 85 个归档 0 改动；③ `git rm` 7 个 openspec-* skill、7 个 opsx command、`openspec/schemas/lite`；④ config.yaml：先删，跑 `openspec validate --specs`，不依赖则保持删除，依赖则留 `schema: spec-driven` 一行；⑤ settings.json 删 Skill matcher 块、删 route hook 脚本；⑥ CLAUDE.md：Session Start 两句、Stack 内容归属一行（归档 proposal.md → change.md）、Enforcement 行、Toolkit 行 v7.0；⑥′ 引用清扫 `grep -n -E 'opsx|openspec (archive|validate|new)|proposal\.md|spec-lite|\.openspec\.yaml|schema: lite|SHALL' CLAUDE.md backlog.md docs/watchlist.md docs/decisions.md skills/`，逐条改或标历史；⑦ `openspec validate --specs` 记基线（今日 24 passed）；⑧ backlog Now 加「v7 迁移 commit 待确认」一行；⑨ 删除清单进首份里程碑汇总 ② 供否决。config context 里的测试命令纪律随 opsx 读者消失一起退役，CLAUDE.md Stack 同句仍在。
- **其余四项目**：均在 v5.5 → 累计做 v5.5 → v6.0 → v6.1 → v7.0 一次；finance_tool 另有 OpenSpec 生成物与 v5.5 config；zd-tool / sports / energy 只改 Session Start 两句、Enforcement 行、Toolkit 行（energy 的在途根 SPEC.md 按旧契约收尾）。
- **FIELD-LOG 同期标注**：v7 条目加「v6 GREEN × v7 影响」表——不受影响（首份汇总 ≤40 行、⑥ ≤1 条、首次反方、到期审、等待期越界）/ 受影响（第 6 条 CLAUDE.md 字节与 Hard Rules 条数：迁移后重记基线）/ 失去对象（ablation 第 7 条里以 tasks.md / openspec-config 为对象的复发信号改写为 change.md Tasks 段 / 作废）；v6.0 条目 GREEN 末尾追加「（v7 同期自 <date>）」。

---

## 7. 需要你定的（方向 / 时间）

1. **时机**：现在切——n=3 第 5 步估 2–3 周才开跑，整步在新形态里跑完正好一次完整 GREEN；**选它 = 同时解除 10-15 的分批裁定（其余四项目累计一次迁到 v7.0）**，v6 的 7 条 GREEN 与 v7 同期按 §6 表标注。还是等 new_review_create 首份 v6 汇总出来再切。推荐现在。
2. **OpenSpec CLI**：留在机器上只作两个旧项目的可选 lint（bootstrap 写明永不 `openspec update`；新项目无 CLI 可用）；还是像 superpowers 一样整体卸载，lint 全靠 reviewer + grep 一行。两者都守住主 spec。
3. **主 spec 在途期写意图**（推荐；串行时与现状等价；并行需每 change 一个 worktree，进拍定 8 的前提）——还是坚持主 spec 永远只写已交付（那要保留 delta 段到 Close 再合，仪式回来一半）。
4. **finance_tool**（09-11 起零提交）：醒来时按累计迁移做，还是留在 v5.5 不动。

默认（不改就按它走）：change.md 的 Decisions 段可选、只写决定 Fails when / Superseded 的决策与备选；流程图只在契约所在处（主 spec）画，change.md 默认不画，给你看的图进里程碑汇总；5 份冻结能力主 spec 移冷不搭车，作项目侧独立 R1 记支线。

---

## 8. 风险与观察位（到期 2026-11-30 或注明次数）

- change.md 长成新的 58KB tasks.md：体量来自 gate / 验收日志内联；原则「读数指路径不粘贴、长日志进 docs/notes」；信号 change.md > 40KB——1 个 R2。
- critic 质量：攻击面从 4 文件变 1 文件 + diff；基线 spec critic blocking 约半数真缺陷；明显下降 → RED，先试让 critic 读整段主 spec——2 个 R2。
- 就地改丢 scenario：每个 R2 的 Close 顺手 `grep -c '#### Scenario'` 前后对比一次，减少且无 REMOVED 说明 = RED——2 个 R2。
- 主 spec 格式漂移：`openspec/` 项目可选 validate；`docs/specs/` 项目只有 grep——首个新项目立项时看。
- 并行前提：拍定 8 设计时把「就地改主 spec 需 worktree-per-change」「critic / gate diff 范围被污染」「WITHDRAWN 回退抹掉并行改动」三行加进冲突表。
- 首个 v7 change 的 Decisions 段用没用、★ 进 AD 几条、备选是否真写了——1 个 R2。
