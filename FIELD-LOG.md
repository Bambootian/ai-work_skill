# Field Log（实测日志，append-only）

> 工具包自身的 RED/GREEN 证据链，接棒 WORKFLOW.md 附录 H 的版本备注职能（WORKFLOW.md 已于 v5.2
> 退役，原文见 tag v5.1）。
> 记录纪律（README 修改约定的落地点）：改 skill 正文之前，证据先记入本文件（RED——
> 运行时失败、使用投票、官方指导均为合法形态）；改完补齐修复对照与验证证据，
> GREEN 观察项登记在对应条目的 ablation 台账中。
> 绕规则的原话逐字记录——它们是 rationalization 表的原料。新条目追加在最上方。

## 2026-09-11 — new_review_create 迁移回灌（v5.5 补丁；340KB backlog、45 归档）

new_review_create（v4 立项，OpenSpec）按 v5.5 完成迁移（3 commits，未 push，主线段与 Now 待人
逐行确认）。回报 6 条真踩 + 6 条替人拍的判断 + 4 条既有状态 + 4 条建议。处置：

| # | 观察 | 处置 |
|---|---|---|
| 1 | 含中文字面量的 echo 测试脚本无 BOM → PS 5.1 按 GBK 读，引号被吞，整脚本解析失败 | README：测试脚本含中文必须带 BOM，或脚本 ASCII + 夹具按字节写 |
| 2 | 工具命令里内联 `Remove-Item -Recurse -Force` 被 harness 静态拦截 | README：清理放 .ps1 里或留给系统 |
| 3 | warn-backlog-size 的 Bash 用例载荷要带 `cwd`；README 措辞让人以为是进程工作目录，第一版得 0 差点误判失效 | README 用例表改写，给出载荷形状 |
| 4 | 340KB backlog 读不下：Read 单次 25K token，归档区密度 3 倍，按行切块撞上限 | 瘦身段：超 100KB 先量字节再按字节切块 |
| 5 | Bash 里 Python 打印中文要 `PYTHONUTF8=1` | README + 瘦身段 |
| 6 | 行号映射 off-by-one 被「每行恰好归属一次」断言抓住 | 瘦身段：脚本搬迁配方（映射 + 断言 + 先算后写） |
| 判 1 | **heavy-test 模板极性缺口**：`addopts = -m 'not e2e'` 已让裸跑安全，模板「裸跑即拦、`-m` 即放」会拦日常命令、放行 `-m e2e` | Day-1 三问改四问，第 2 问「裸命令是否已由配置默认安全」，是则不装；模板头注加 PRECONDITION；Step 3 落点措辞同步 |
| 判 6 | 「迁移 commit <hash> 待确认」写不进自身，多一个 pin commit；skill 说一个实际 2+1 | 迁移段：不写 hash 写主题；docs commit 可多于一个 |
| 既有 1 | 旧 settings.json 的 warn-destructive-git 只挂 `Bash`，PowerShell 调用从未被看住（finance_tool 同） | 迁移通用动作 ③ 加 settings.json matcher 核对 |
| 既有 2 / 3 / 4 | CLAUDE.md 声称的 $PROFILE wrapper 不存在；项目级 v4 skill 副本两处被扫描；CRLF/LF 混用 | 引用清扫 / Step 0 删副本已覆盖；行尾无害 |
| 建议 4 | GUIDE §6 写 `retros/`，value-review 写 `openspec/retros/` | §6 行改为与 value-review 一致 |

判 2–5（主线板块推断、叙事只留 git、会话块归档归属、Watch-Item Lifecycle 段保留）是项目决策，
待用户在 new_review_create 逐项确认，不进工具包。正面确认：bypass 模式下 hooks 照常触发；
`openspec update` 非交互干净；先瘦身再挂 hook 的顺序对，瘦身窗口内 PostToolUse 一次没响。
无接口变化，不升版本。

## 2026-09-11 — finance_tool 迁移回灌（v5.5 补丁；首个 OpenSpec 项目）

finance_tool（v5.0 立项，OpenSpec，12 归档）按 v5.5 完成迁移，无人值守走「先提交后确认」。
回报 7 条真踩 + 5 条顺手确认。核实与处置：

| # | 观察 | 处置 |
|---|---|---|
| 1 | 项目 `.claude/skills/` 有 v4 副本（含死的 toolchain-refresh），用户级是 v5.5；两处都被扫描，同名谁生效不透明 | Step 0：项目级工具包 skill 副本一律删除，只留用户级一份 |
| 2 | `openspec config profile` 无非交互加单 workflow 的方法（本机核实：只有交互选择器或 preset）；该会话直接改全局 config.json 加 update / sync（现为 core 六个 + verify） | Step 0 写明：非交互只能编辑 config.json 的 workflows；机器级，影响所有项目，是期望状态 |
| 3 | `openspec update` 整体覆盖生成文件；事后才查无本地定制 | v5.1→v5.2 段：update 前先 `git log` 生成目录确认无定制 |
| 4 | 交互会话但 harness 说用户不在实时看，按无人值守先 commit | 迁移段加判定：以 harness 说明为准，拿不准按无人值守 |
| 5 | R1 归档只有 spec-lite.md，无 proposal.md | 瘦身①、change-loop Errata、GUIDE §6 都注「R1 为 spec-lite.md」 |
| 6 | 删 skill 不等于删引用：living spec 仍写 toolchain-refresh、「NORTH_STAR.md MUST NOT 被修改」 | 迁移段加「引用清扫」：CLAUDE.md / backlog 直接改，living spec 记支线走 change-loop |
| 7 | `git rm` 后 `git add -A -- <已删文件>` 报 pathspec | 不记（git 常识） |
| 顺手 | warn-backlog-size 当场生效，瘦身期间每条命令都响 | 迁移段：hooks 重部署放瘦身之后 |
| 顺手 | 项目自有 warn-due-checkpoints：BOM + 中文 + 无 OutputEncoding，SessionStart 乱码 | 迁移段：项目自有 hook 按写法法则体检，不合规记支线 |
| 顺手 | Git Bash `!` 前缀把 `/c` 改写成 `C:/`，我给的 `chcp 65001` 没跑 | README / GUIDE §4：Git Bash 里写 `cmd //c` |
| 顺手 | core.autocrlf=true 下 LF 文件 commit 刷 CRLF 警告 | 无害，不动 |
| 乱码 | 该会话按配方跑前 65001、跑后恢复 65001，终端仍在跑用例期间被画坏（ASCII 被吞 = cp936 把 TUI 的 UTF-8 多字节当双字节解） | **根治**：echo 用例改在独立隐藏控制台跑（`Start-Process cmd -WindowStyle Hidden -Wait -PassThru`），`chcp` 永远打不到会话窗口。本机验证：子控制台设 437、父控制台前后都是 936、exit 2 与输出正常捕获 |

正面确认：cp936 + 中文载荷 + 坏 JSON 全过；Tier 1 两个 hook 在会话里真拦住了 Skill 与 Write。
无接口变化，不升版本。

## 2026-09-11 — zd-tool 迁移回灌（v5.5 补丁，无项目动作）

zd-tool（v4.1 立项的小型项目）按 v5.5 完成迁移，回报 6 条 toolkit 项 + 2 条通用坑（后者由该会话
自行入知识库）。逐条核实后处置：

| # | 观察 | 处置 |
|---|---|---|
| 1 | **Tier 1 heavy-test hook 对字面量也拦**：commit message 里「bare pytest」命中 `\bpytest\b`，`git commit` 被硬拦。README 只记了 Tier 2 的同形误报，Tier 1 后果不同 | README「已知误报」补 Tier 1 条目 + 绕法（`git commit -F <file>` 或换措辞）；模板头注与提示语同样写明。不改正则：加「命令位置」判断会与 runner-name split、`python -m pytest`、`VAR=1 pytest` 前缀互相绊，静默失效的代价大于每项目一次的误报 |
| 2 | `~/.claude/my-work-skill.toolkit-path` 带 UTF-8 BOM（PS 5.1 `>` 默认写 BOM，PS 读吞掉所以一直没事，bash / python 读到 `﻿`）。该会话已无 BOM 重写；本机核实两个标记文件现均无 BOM | bootstrap Step 0 写明两个标记文件无 BOM 写入（`[IO.File]::WriteAllText` + UTF8Encoding($false)），已有带 BOM 的同法重写 |
| 3 | 瘦身步骤②「剩余交接叙事删（git 有）」用户不接受：要求逐 change 的开工前记录 / 收工摘要补进各归档；分两次 commit 才到位 | 步骤①加「逐 change 记录整段追加到该 change 归档末尾（`## Migrated notes`）」，②改为「挂不到任何 change 或文件的才删」 |
| 4 | heavy-test 模板占位符不止三个：提示语与头注里还有 `<TEST_CMD>` `<SAFE_FILTER_EXAMPLE>` `<SAFE_FILTER>`（本机核实：6 种 token） | 模板改为**恰好三个** token（提示语指向 CLAUDE.md Stack 段的 filter 示例，头注改普通措辞）；README 填空段加「填完 `grep -E '<[A-Z_]+>'` 为空」 |
| 5 | 正面：settings.json 新加 PostToolUse 同 session 立即生效，不用重启 | README 写明，「挂载后真跑一次」可当场做 |
| 6 | echo 配方把 `2>&1` 放进 cmd 字符串内部，stderr 与 exit 一次拿到 | README 配方加 `2>&1` |

验证：模板改后 Python 驱动 32/32 重跑通过；用 zd-tool 参数填充后 `grep -E '<[A-Z_]+>'` 为空。
无接口变化、无项目动作，不升版本号。

## 2026-09-11 — v5.5 用户裁定：无人值守迁移先提交后确认（B1）；观察位 #7 升级为规则（B2）

- **B1**：bootstrap 迁移段改为「有人在场确认后落盘；无人值守可先落盘并单独提交，backlog Now
  悬而未决记『迁移 commit <hash> 待确认』，不同意 revert」。依据：迁移只改文档，git 可逆；sports
  实跑证明卡在确认上会让自治会话停摆。新项目立项（Step 2）不变——brainstorm 本身就要人在场。
- **B2**：观察位 #7 命中 1 次即升级（用户裁定，不等第二次）：templates/CLAUDE.md North Star 段删
  「当前阶段重点」，改为指向 backlog Now；bootstrap Step 1 四要素改三要素；GUIDE §6 归属表同步；
  value-review 观察位表移除 #7 并记升级。迁移 v5.4 → v5.5 = 项目 CLAUDE.md 删该行。
- 观察：观察位机制首次走完「AI 检测 → 告知人 → 人拍 → 升级为规则」闭环，从命中到升级同一天。

## 2026-09-11 — v5.4 sports 首次迁移回灌：echo 配方假阳性、hook 输出编码、迁移起点推断

### RED（改前证据；形态 = 首个迁移项目的实测报告 + 本机复现）

- sports（v5.0 立项的小型项目）按 v5.3 跑「部署工作流」，无人值守完成迁移（3 commits，5 hooks，
  echo 18/18）。回报 7 条 toolkit 缺陷 + 3 条流程观察（原文：sports scratchpad
  `deploy-issues-2026-09-11.md`）。
- **A1 高**：hooks/README 与 bootstrap 的 echo 配方 `cmd /c "... & echo exit=%errorlevel%"` 永远打 0——
  cmd 单行在执行前展开 `%errorlevel%`。本机复现：README 形式 0，`cmd /v:on` + `!errorlevel!` 2，
  PowerShell `$LASTEXITCODE` 2。今天 v5.2 的 32/32 是 Python 读 returncode，所以没撞上；照 README
  做会把失效的 Tier 1 判成通过——正是「静默死掉的 hook 比没有更坏」。
- **A2 中**：脚本只设 InputEncoding，stdout / stderr 仍按控制台代码页 936 编码；输出里引用输入原文
  （被拦的命令）的中文在会话里乱码。本机复现 stdout 与 stderr 同样：无 OutputEncoding 时 cp936
  字节、加一行后 UTF-8 字节，exit 不变。附带发现：子进程 `chcp` 改的是共享控制台的代码页（子 cmd
  设 437 后主控制台查到 437），用户会话乱码到重启就是这个——配方没恢复代码页。
- A3 低：两个 Tier 1 block 的提示语假定 OpenSpec（小型项目被拦时指路 /opsx:propose）。A4 中：v5.3 前
  立项的项目无 `版本:` 行，迁移段「从 Toolkit 行版本起」无处读，sports 用 commit 日期对 tag 日期推出
  v5.0。A5 低：「暂无重测试」无落点，下个 session 重问三问。A6 低：warn-backlog-size 挂载真跑要造
  超标文件，无配方。A7 低：warn-destructive-git 对命令文本字面量也响（写 fixture / 文档），只记不改。
- 流程观察：B1 迁移「人确认后落盘」与无人值守冲突，sports 先 commit 后确认；B2 value-review 观察位
  #7 命中 1 次（CLAUDE.md「当前阶段重点」停在已收官的 M0），已按处理法改指向 backlog Now；
  B3 操作教训：ASCII 检查用 python 读字节（`grep -P` 在非 UTF-8 locale 报错且 `|| echo` 给假通过）、
  一条命令只做一件事（heredoc 后半段解析失败但前半段已落盘）——本仓库今天两次踩同一坑。

### 修复（v5.4）

| 项 | 处置 |
|---|---|
| A1 | hooks/README、bootstrap Step 3、GUIDE §4：配方改 PowerShell 读 `$LASTEXITCODE`，写明 `%errorlevel%` 陷阱与 `/v:on` 替代；跑前记代码页、跑后恢复 |
| A2 | 6 个脚本补 `[Console]::OutputEncoding = UTF8`；写法法则改「stdin 和 stdout / stderr 都显式 UTF-8」 |
| A3 | block-replaced-skills / block-superpowers-specs-dir 提示语改栈无关（change-loop 路由 / SPEC-lite / docs/changes；OpenSpec 项目对应 propose / apply / openspec/changes） |
| A4 | bootstrap 迁移段：无 `版本:` 行按形态推断起点（NORTH_STAR / PROTOCOL / warn-toolchain-stale → v4；无 Now / 主线 → v5.0；hook 无 stdin UTF-8 → v5.1；config.yaml 无 operations → v5.2；hook 无 OutputEncoding → v5.3；拿不准取更早） |
| A5 | Step 3：「暂无重测试」落点 = CLAUDE.md Stack 一行 + backlog 支线一行（触发：出现重型测试），之后不重问 |
| A6 / A7 | README 补 warn-backlog-size 真跑配方（备份 → 追加 9KB 中文 → 触发 → 恢复 cmp）；A7 记为已知误报 |
| B3 | 写法法则补「ASCII 检查用 python 读字节」 |
| 版本 | VERSION v5.4；迁移段 v5.3 → v5.4 = hooks 重部署 + 新配方重跑 echo（sports 也会被版本戳再触发一次——这正是它该干的） |
| 待人拍 | B1 自治会话可否先提交后确认；B2 观察位 #7 是否升级为规则（删模板「当前阶段重点」改指向 backlog Now） |

### 验证（2026-09-11）

- 本机复现 A1 三种配方（0 / 2 / 2）、A2 stdout 与 stderr 字节对照、chcp 泄漏（437 → 恢复 936）。
- 6 个脚本改后 Python 驱动 32/32 重跑通过；README 新配方对 block hook 实跑 `exit=2`，代码页跑前
  跑后一致（65001）。
- 复现脚本本身踩了 B3 的坑一次（BOM-less UTF-8 .ps1 含中文被 PS 5.1 按 cp936 读，字面量变
  mojibake）——再次印证脚本只含 ASCII 的法则；测试夹具用 UTF-8 字节写文件。
- **toolkit 会话自己也把用户终端弄乱了一次**（用户截图为证，重启才恢复）：复现 A1 / A2 时在 Bash
  与 PowerShell 两个工具里都跑过 `chcp 936`，第一次探针没先记代码页。哪一次调用打到了用户终端
  无法从证据锁定（Bash 工具的控制台在用户重启后仍读 936，可能是独立控制台且系统默认即 936；
  PowerShell 工具那次跑前跑后都读 65001）；机制本身已验证。教训写进 README 配方：记代码页必须在
  任何 chcp 之前，用 try/finally 恢复；已乱时 `chcp 65001` 即刻恢复，不必重启。本会话之后不再
  跑 chcp。

### GREEN 观察位（sports 重跑 v5.3 → v5.4、其余三项目迁移时回填）

- ① 版本戳是否在 sports 下次 session 触发 v5.4 迁移；② 新配方 exit 是否如实（block 用例 2）；
  ③ 迁移起点推断是否与实际立项版本一致；④ 「暂无重测试」是否不再被重问。

## 2026-09-11 — v5.3 版本戳：机器级 skill 与项目文件的漂移可检测

### RED（改前证据；形态 = 用户提问 + 本机实测）

- 用户提问：skill 装在机器用户级，各项目在不同时间部署；机器 skill 更新后项目仍是旧版部署，
  未执行中 / in-progress 两种项目会不会冲突，有什么机制。
- 本机实测（v5.2 部署当日）：finance_tool 与 new_review_create 的项目文件都停在 v5.0 时代
  （无 Now / 主线段，backlog 12.7KB / 340KB；无常设授权；hooks 含已切除的 warn-apply-phase /
  warn-toolchain-stale，Tier 2 旧写法模型看不见，Tier 1 无 stdin UTF-8），机器 skill 已是 v5.2；
  finance_tool CLAUDE.md 还留着「subagent 需确认」条款——项目 CLAUDE.md 优先级高于 skill，
  这条会压掉 v5.1 起的常设授权，且无任何报错。两项目均无在途 change。
- 根因：① bootstrap Step 0 在任何项目里跑都覆盖机器级 skill，立新项目 = 静默升级所有老项目的
  skill 层；② 项目文件与 skill 都没有版本戳，漂移只能靠 Session Start 的形态启发式（North Star /
  Now / 主线）撞上，config.yaml、hook 写法、旧规则条款都不在检查范围。
- 冲突分四类（危险降序）：优先级倒置（旧项目规则压新 skill，静默）；harness 漂移（旧 hook
  看不见 / 放行，模型无法自察）；形态不匹配（有部分兜底）；在途 change 跨版本（最安全：状态在
  文件，Loop Contract 四字段 v4.1 起未变，新增行 Close 补）。

### 修复（v5.3）

| 项 | 处置 |
|---|---|
| 版本戳 | 仓库根 `VERSION`（= tag）；bootstrap Step 0 部署 skill 后写 `~/.claude/my-work-skill.toolkit-version`；Step 2 与迁移收尾把版本写进项目 CLAUDE.md Toolkit 行 |
| Session Start | templates/CLAUDE.md 第一步改为比对 Toolkit 行版本与机器标记文件，不等或缺失 → 先迁移再路由；形态检查保留作兜底 |
| 迁移时机 | bootstrap 迁移段：绿树 task 边界、单独 docs commit、在途契约不动、Close 补行；Toolkit 行改版本 = 迁移完成的定义；v5.2→v5.3 段只补版本行 |
| 兼容承诺 | GUIDE §5 接口表：CLAUDE.md / backlog 段名、Loop Contract 四字段、路由三行、hooks 清单、config.yaml 键、版本戳；minor 只增不改不删，改 = major + 迁移 |
| 不做 | SessionStart hook（先文本比对；模型跳过再降 hook，零误报场景）；项目级 `.claude/skills/` 钉版本（隔离彻底但改进不再自动到达；版本戳无论如何先做） |

### 验证（2026-09-11）

- 本机部署 v5.3 skill 副本并写标记文件 `~/.claude/my-work-skill.toolkit-version` = `v5.3`；两个
  存量项目 CLAUDE.md 无版本行 → 下次 Session Start 按「任一缺失」触发迁移（预期）。
- 存量项目迁移本身是各项目实践，用户逐项目跑 bootstrap 确认落盘。

### GREEN 观察位（两个存量项目迁移时回填）

- ① Session Start 是否真的先比对再路由（还是直接开工）；② 迁移 commit 是否落在绿树 task 边界；
  ③ finance_tool 旧确认条款是否被 grep 删除；④ 迁移后 Toolkit 行版本是否改为 v5.3。

## 2026-09-11 — v5.2 WORKFLOW.md 退役：hooks/ 落地、archive 交回 OpenSpec、opsx 约定下沉 config.yaml

### RED（改前证据；形态 = 官方文档核实 + 存量项目实测，非运行时失败）

- 用户判断：WORKFLOW.md v3.6 的流程已全部抽象进 skill 并迭代多轮，留着无意义（8 月 9 日条目
  「第 6 部分是否保留属产品决策」至此裁定）。核实活依赖（skills / templates / GUIDE / README）
  只剩三块：附录 G hook 源码（bootstrap Step 3，唯一无家的内容）、§5.8.1–5.8.4 archive
  （change-loop Close）、§5.4.1 R-revision（change-loop 正文本就没有，只剩 GUIDE §2 一个名字）。
- OpenSpec 1.5.0（上次对齐，2026-06-28）→ 1.13.0（2026-09-09，8 个 minor）核实（npm registry +
  docs/*.md + CHANGELOG 一手）：① `openspec archive` 自动合并 ADDED/MODIFIED/REMOVED/RENAMED、
  首次归档自动建主 spec、delta 的 `## Purpose` 被采用（1.7）、`retire_capabilities`（1.8）——
  §5.8.2/5.8.3 手工 seed / merge 过时，只剩工具包自己的 `## Architectural Decisions` 约定是活的
  （finance_tool 5 + new_review_create 14 个主 spec 全有此段）；② `/opsx:update`（1.6）覆盖
  R-revision「停 apply → 改 spec → validate → 继续」；③ 1.8 起 normal 模式不强制英文 SHALL/MUST、
  1.11 起 strict 对 Purpose 占位报失败——§5.8.4 的 `--strict` 会误伤；④ `openspec/config.yaml` 的
  context / rules.<artifact> / operations.apply|archive.guidance（1.7）是官方项目级注入机制，经
  `openspec instructions` 进每个 opsx skill 的 prompt——两个存量项目的 config.yaml 都只有
  `schema:` 一行，从未用过；⑤ 两个存量项目都缺 `/opsx:update`（生成于 1.5.0 / 1.11.0），需
  `openspec update`。
- 用户裁定：约定下沉 config.yaml（只放 opsx 流程内才用到的条目，权威仍在 change-loop）；R1 改用
  自定义 schema 记支线不做；validate 改 normal。

### 修复（v5.2）

| 项 | 处置 |
|---|---|
| 附录 G | `hooks/`：6 个真实 .ps1（4 个自附录 G + bootstrap 内联的 2 个迁出）+ README（原则 / 清单 / settings.json 片段 / heavy-test Day-1 三问 / echo 用例表）。全部按 v5.1 写法法则写成：ASCII、stdin UTF-8、坏 JSON exit 1、Tier 2 用 JSON additionalContext——Tier 1 三个旧脚本原先没设 stdin 编码，中文载荷会解析失败静默放行，此次一并修 |
| §5.8 archive | change-loop §5 Close 自包含：`openspec archive <id> -y` → Decisions 追加（Source / Superseded）→ `validate --specs` + `list`，不加 `--strict`；§5.6/§5.7 改为具名 `/opsx:verify` / code-simplifier |
| §5.4.1 | GUIDE §2 回退项改 `/opsx:update` |
| 第 1 / 第 3 部分 | bootstrap Step 0 内联 superpowers 安装三条命令；Step 2 内联 ARCHITECTURE.md 一句 |
| config.yaml | 新模板 `templates/openspec-config.yaml`：context（Stack 同步 + SHALL/MUST 保留 + 测试命令纪律）/ rules.tasks（Loop Contract 头部、task 带验证）/ rules.specs（Purpose）/ operations.apply（一 task 一迭代、超范围 SPLIT）/ operations.archive（-y、Decisions、validate、Errata）；bootstrap Step 2 生成，迁移段加 `openspec update` + 补 config + 重部署全部 hook |
| 指针 | templates/CLAUDE.md Toolkit 行、GUIDE 头注 / §5 v5.1→v5.2 表 / §6 Decisions 行、README 目录树 / 修改约定 / 版本表 |
| WORKFLOW.md | `git rm`；原文永在 tag v4.1 / v5.0 / v5.1；docs/specs、docs/plans、本文件历史条目的引用不改（指向 tag 中的文件） |

### 验证（2026-09-11）

- hooks/ 6 个脚本 echo 用例 32/32 通过（Windows PowerShell 5.1，`cmd /c "chcp 936 >nul & powershell
  -NoProfile -File x.ps1 < in.json"`，in.json 无 BOM UTF-8 含中文；heavy-test 模板按 zd-tool pytest
  参数填充，含 `python -m pytest` 陷阱用例）：Tier 1 block exit 2、放行 exit 0；Tier 2 命中输出一行
  JSON additionalContext、未命中静默；warn-backlog-size 中文路径超标 exit 2；所有脚本坏 JSON exit 1。
  驱动脚本在 scratchpad，不入库。
- 活文件 grep：skills / templates / GUIDE / README / hooks 无 WORKFLOW / 附录 G / R-revision 引用
  （bootstrap 迁移段「删项目内 WORKFLOW.md 副本」是 v3/v4 迁移动作，保留）。

### 支线与 GREEN 观察位（下个 OpenSpec 项目 change 回填）

- **支线：R1 改用 OpenSpec 自定义 schema**（`openspec schema init lite --artifacts "specs,tasks"`，
  `openspec new change x --schema lite`）取代非标 `spec-lite.md`——收益：R1 进 status / archive /
  主 spec 合并；陷阱：schema 无 id 为 `specs` 的 artifact 则永不合并主 spec。触发：下一个 R1
  change 路由时评估，先在一个项目试跑。
- 观察位：① 下一个 R2 归档，`/opsx:archive` skill 是否按 config.yaml archive guidance 维护
  Decisions 段且不加 `--strict`；② 下一个 propose，tasks.md 头部是否出现 Loop Contract
  （rules.tasks 注入是否生效）；③ 存量项目 `openspec update` 后 `/opsx:update` 是否可用，旧 change
  是否因 1.8+ 校验变严（MODIFIED 漏 scenario、子任务计入进度）而 validate 失败。
- 检测点（2026-09-11 晚补，用户问「AI 当时能感知吗」）：项目 session 不读本文件，检测器必须在它
  加载的文本里——支线写进 change-loop §2 R1「评估位」，观察位 ①② 写进 §5 Close「观察位」，命中
  即回报人并回填本条目；回报一次后由工具包侧删句。③ 已由 finance_tool / new_review_create 迁移
  部分回答：`/opsx:update` 可用，`validate --specs` 未报错（1.13.0 重生成后）。

## 2026-09-11 — value-review 补强三条 + 四个自检观察位（用户裁定）

- **触发**：用户问「value-review 设计是否周全」；作者对照 15 份 retro 的证据提出 7 点。用户裁定：
  前三条进正文，后四条记观察位，且**由 AI 在回顾时自行检测并告知，不靠人发现和提醒**。
- **进正文**（skills/value-review/SKILL.md）：① project review 新增「地图倒核」（剩余主线步全做完，
  判据真能达成吗；尺子错则位置全错，证据：review-engine 24 个质量 change 与 roadmap 交集为零而回顾
  照判健康）；② route check 第一行固定问人「这段时间你用下来最不满意的一件事是什么」（15 份 retro
  中真正有用的信号全来自人）；③ project review 建议前必须先写「停掉的最强理由」，写不出才允许
  [continue]（旧 North Star 检查从未失败过，不会失败的检查等于没有）。
- **观察位 #4–#7**：信号与升级方式表写进 skill 末尾「v5.1 观察位」段，检测点 = 每次 route check /
  project review；命中即在 retro 末尾写「观察位命中 #n」并告诉人。落在 skill 而不只在本文件，是因为
  项目 session 不读 FIELD-LOG——检测器必须在回顾时被加载的文本里。
  - #4 贬值检查连续 2 份只有定性判断 → 升级为强制 spike
  - #5 剩余步数连续 3 次不减 → 升级为趋势行
  - #6 连续 2 次 backstop 都判阻塞于同一外部事件 → 升级为 pause / 继续二选一
  - #7 CLAUDE.md 当前阶段重点与 backlog Now 不一致 → 删前者指向后者
- **GREEN 回填位**：首个真实周期后记录——问人那一行是否产出了程序没发现的信号；「停掉的最强理由」
  是否出现过写不出的情况；四个观察位各命中几次、AI 是否主动告知。

## 2026-09-08 — v5.1 主线锚定：四项用户报告 + 两条 harness 静默失效

### RED（改前证据；形态 = 用户实践报告 + 实测度量 + harness 实跑）

- **用户报告（v5 实践一轮后，原话要点）**：① backlog「越来越复杂……session 起始必读……AI 读着很耗
  token、容易有遗漏，人阅读起来也非常的不清晰」；② 起 fresh-context reviewer「经常被会话规则说无用户
  批准不允许调用 subagent 的规则挡……有时甚至自行就在本会话中直接跑了，脱离了工作流的设计」；
  ③ propose 产物「应该每次在生成后加一轮起 subagent 做内容的对抗式自检……确实每次都能自检出不少问题」；
  ④ value-review「只是在回顾……是否是技术自嗨」，要的是「最终想要的效果……主线路径是什么……是否偏离
  ……离主线还多远」，且「5 个 change 的触发……小 change 做完就到 5 个了……中间突然起一次，反而效果很差
  ……review 出来觉得要新开 change……只是在钻牛角尖解决一些支线的小问题」。
- **实测度量**：backlog.md——new_review_create 340KB / 2,326 行，zd-tool 185KB / 2,398 行，
  finance_tool 12.7KB / 38 行（单行最长 2.9KB）。retro——new_review_create 6 份 6→37KB，
  zd-tool 6 份 12→41KB，finance_tool 3 份 5→10KB；计数触发最短间隔 1 天。
- **结构化审读**（10 个 fresh-context reader，4 份 backlog + 14 份 retro + 1 份回顾输入；摘要见 v5.1 spec §2.7）：
  backlog 从未删除任何内容、交接叠 12–16 层、≥12 类内容无家；retro 逐 change 三分类 40+ 个 change
  零次判出 self-indulgence、North Star 检查从未失败、全部没有「终点→路径→距离」段、一个窗口 5/5
  archive 全是上轮 retro 提案、两个项目各一个单点兔子洞无人标注。
- **harness 事实 1**（claude-code-guide 查官方文档）：Agent 派发本身不触发权限、无任何系统规则要求先问
  人；只有 Workflow（多 agent 编排）有 opt-in 规则 → 「无批准不许派」是模型把后者错推到前者。
- **harness 事实 2（静默失效，实跑）**：Claude Code 2.1.259，三个探针 hook 挂在一次 `claude -p`：
  PreToolUse exit 0 + stdout 的标记**未出现**在模型回答里；PreToolUse JSON `additionalContext` 与
  PostToolUse exit 2 + stderr 的标记出现。⇒ 附录 G「Tier 2 = exit 0 + stdout」写法模型看不见，
  `warn-route-before-opsx` / `warn-destructive-git`（PreToolUse）自部署起一直静默失效；SessionStart
  类 hook（warn-toolchain-stale、finance_tool 的 warn-due-checkpoints）纯文本 stdout 本就进上下文，
  不受影响。FIELD-LOG 2026-07-07 的「hook 脚本实跑 5 用例」测的是脚本有输出，不是模型收到。
- **harness 事实 3（静默失效，实跑）**：PowerShell 5.1 按 ANSI（cp936）读无 BOM UTF-8——① 脚本含
  中文注释时可能吞掉后续字节：本次整行中文注释 → 本应输出的用例全部变成无输出、exit 0；评审者复现
  行内中文注释 → 吞掉 `}` 报解析错误 exit 1；改纯 ASCII 后通过。② **stdin 同样按 cp936 解**，而
  Claude Code 送的是 UTF-8：含中文的真实 backlog 载荷（奇数个汉字 + `\"`）让 ConvertFrom-Json 失败、
  hook 静默 exit 0——两位 fresh-context reviewer 用 zd-tool / new_review_create 的真实 backlog 内容
  独立复现。修法：读 stdin 前 `[Console]::InputEncoding = UTF8Encoding($false)`，坏 JSON 显式 exit 1。

### 修复（v5.1，契约 `docs/specs/2026-09-08-v5.1-mainline-anchoring-design.md`）

| 报告 | 修复 |
|---|---|
| ① backlog | `templates/backlog.md`（Now/主线/支线/Done，≤8KB，Now 整段覆盖、债务结转）+ GUIDE §6 归属表（含 docs/decisions.md、docs/watchlist.md）+ `warn-backlog-size` hook（PostToolUse，>8KB 报模型）+ bootstrap 瘦身迁移 |
| ② 拒派 / inline 替代 | CLAUDE.md 模板常设授权行（点名 Workflow opt-in 不适用）；change-loop §4 同句；Close 必填 `Gate:` 行，没跑 = DONE-ungated（zd-tool 2026-09-02 R1 推广） |
| ③ spec 自检 | change-loop §2 末 Spec critic（分级）；dispatch-prompt.md「Spec critic 变体」7 条清单（v3 §5.4 Step 4 压缩回装） |
| ④ 回顾 | value-review 重写：route check（终态/主线快照/支线/待做/偏离/距离/下一步）+ project review（North Star/判据/轨迹/死胡同/贬值/建议）；触发 = 主线里程碑 / 支线计数 ≥3（route check 后清零，外部事件阻塞时暂停）/ 4 周 backstop / 板块收官 / 8 周 / 模型换代，检查点在下一个 change 路由前；最多提 1 个主线 change；回顾只读 |
| harness 2/3 | bootstrap Step 3 两条写法法则（可见性 / 编码：ASCII + stdin UTF-8）；内联 `warn-route-before-opsx` 改 JSON additionalContext；`warn-destructive-git` 部署时同法改（附录 G 冻结不动）；`warn-backlog-size` 加 Bash/PowerShell 分支（bypass 模式下模型走 Bash 改文件） |

### 验证（2026-09-08）

- hook echo（PowerShell 执行，`cmd /c "chcp 936 >nul & powershell -NoProfile -File x.ps1 < in.json"`，
  in.json 为无 BOM UTF-8 且含中文）13/13：
  - A 中文目录下 12.9KB backlog.md + 含奇数汉字与 `\"` 的 content → stderr `backlog.md is 12.9KB; budget is 8KB ...` exit 2 ✅
    对照：同载荷、去掉 InputEncoding 行的脚本 → `bad stdin JSON` exit 1（原写法则静默 exit 0）
  - B 小 backlog.md（Edit 载荷含中文）→ 静默 0 ✅；C 其他文件 13KB → 静默 0 ✅；H 目录名为 backlog.md → 静默 0 ✅
  - D Bash heredoc 追加 backlog.md、cwd 下 12.9KB → exit 2 ✅；E 不涉及 backlog 的 Bash → 静默 0 ✅
  - F 8192 B → 静默 0 ✅；8193 B → exit 2 ✅；G 坏 JSON → `bad stdin JSON` exit 1 ✅
  - I `opsx:propose` → `{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"This project requires a change-loop route declaration ..."}}` exit 0 ✅；
    `opsx:proposed` / `change-loop` → 静默 ✅；坏 JSON → exit 1 ✅
- 模型可见性实跑（`claude -p`，haiku，三个探针 hook）：`{"seen": ["HOOKMARK-PRE-JSONCTX-4412", "HOOKMARK-POST-EXIT2-9905"]}`
  （PRE-STDOUT 标记缺席）。
- 存量项目 hook 脚本核查：4 个项目 24 个 `.ps1`，10 个含非 ASCII 字节（注释 / 字符串里的破折号、
  中文），实跑 Tier 1 hook 仍正常——编码陷阱未伤及存量；但 `warn-route-before-opsx` /
  `warn-destructive-git`（及旧项目的 warn-apply-phase）为 PreToolUse exit 0 + stdout 写法，模型看不见，
  需按 bootstrap Step 3 重部署。
- 尺寸（实测，定稿）：见本条目末「自检结果」表。

### 自检结果（8 视角 fresh-context 对抗评审，2026-09-08）

视角：用户意图保真 / 可执行性 / 跨文件一致 / 减法原则 / harness 事实（拉官方文档）/ 知识库约束 /
用 zd-tool 真实内容试穿模板 / hook 脚本实跑。117 条发现（47 blocking），首批 12 条 blocking 各经
3 个反驳者复核后，验证扇出因配额停止（用户叫停），其余由作者逐条核对裁决。采纳并落地的实质修正：

1. hook stdin 编码（两位 reviewer 独立实测）与 Bash 分支；「80 行 ≈ 8KB」假等式 → 统一 8KB 预算；
   8193 B 边界（先取整再比较）修正；坏 JSON 显式 exit 1；正则加尾锚；提醒文案改条件式事实句。
2. 支线计数触发：route check 后清零；检查点移到下一个 change 路由前（不在 Close 打断批次）；
   主线阻塞于外部事件时暂停；偏离判据与触发条件解耦并先写一行量。
3. 路由声明加 `主线:` 行；主线段只经回顾批准增删——堵住「Close 自报主线」让触发失效的口子。
4. R0 免 gate 明写；Gate 行覆盖 critic + reviewer；Loop Contract Exit 槽位同步 DONE-ungated。
5. 人裁定的家三处不一致 → `docs/decisions.md`；长尾 watch / 冰箱 → `docs/watchlist.md`；
   支线完成即删行；Now 覆盖前债务结转；外部事件 / 冻结步 / 前置探针有记号。
6. 首轮锚点（无 project-review 文件、模型换代定义、板块必有）；Session Start 缺段回退到 bootstrap；
   spec critic 与 R2 人批准的顺序；skeptic 定义；R1 critic 只做两条。
7. 迁移：删除项目 CLAUDE.md 的反向规则（finance_tool「主模型 subagent 先确认」）、重跑 Tier 2 hooks；
   瘦身给出判定顺序与人确认粒度。
8. 减法：删 CLAUDE.md 的 backlog 重复行、change-loop 内联触发表、value-review Common mistakes 与论证
   从句、dispatch 里给主循环的指令；WORKFLOW §5.8 指针收窄到 5.8.1–5.8.4。
9. 陈述纠错：SessionStart hook 可见（本条目「harness 事实 2」已改）；存量脚本「全部纯 ASCII」为假（已改）；
   「用户发起不重置锚点」是项目惯例非工具包规则（台账已注明）。

拒绝的主要建议及理由：把 spec critic 改为 R1 可选（用户原话「每次都能自检出不少问题」，改为 R1 只做
两条以控成本）；删 Outcome 三分类（它是写 Loop Contract 时的前瞻过滤，与回顾程序无关，只把箭头改为
「不开工，记支线」）；把 8KB 阈值提到 12KB（zd-tool 试穿 48 行 4.6KB 证明小型项目余量充足，中型项目
的长尾靠 watchlist 分流）。

尺寸（定稿实测）：change-loop 8.5KB / dispatch 3.4KB / value-review 5.6KB / bootstrap 9.7KB（含两段
内联 hook 源码）/ CLAUDE 2.0KB / backlog 1.7KB / GUIDE 8.8KB。change-loop 较 v5 的 6.2KB 增 2.3KB
（路由第三行、spec critic 段、授权句、Close 五行），token ≈2.3k，仍为 v4 的一半。

### Ablation 台账（本次切除 / 替换项）

| 切除项 | 守护的失败模式 | 复发信号 | 回装方式 |
|---|---|---|---|
| 逐 change 三分类（value-review 主体） | 技术自嗨连击 | 主线映射为「推进」但用户可见产物无变化连续 3 个 | 在 route check 第 2 项加三分类列 |
| 5 archive 计数触发 | 长期不回顾 | 4 周 backstop 到期前主线已偏且无人发现 | 恢复计数（只数主线 change） |
| 「用户发起不重置锚点」惯例（new_review_create 项目先例，非工具包规则） | backstop 被人为回顾稀释 | 人发起的回顾之后 4 周内主线漂移 | 恢复惯例 |

### GREEN 观察位（下个项目 / 首个瘦身项目回填）

1. backlog 是否稳定 ≤8KB；Now 段是否真被覆盖而非追加、悬而未决是否结转
2. route check 是否在主线边界自然发生；单份 ≤40 行是否守住
3. spec critic 首轮 [blocking] 数（预期 >0，否则清单失效）
4. 「无批准不许派 subagent」是否再现；Close 报告 `Gate:` 行出现率
5. 软警告 hook 改 JSON / exit 2 后，模型是否真的对提醒有反应（首次 opsx:propose 无路由时观察）；
   是否把 PostToolUse exit 2 误当 Write 失败而重试

## 2026-08-14 — v5 减法重构：RED 证据与 ablation 台账

### RED（改前证据；本次形态 = 使用投票 + 官方指导，非运行时失败）

- **使用投票**（43 环节全量标注，2026-08-14 session）：已死 = 双模型架构（#7/#39）、
  toolchain-refresh 常设化（#35/#36）；走过场 = spec 四件套人审（#16）、recitation（#18）、
  证据包格式（#25）、R-revision 仪式（#28）、NORTH_STAR 独立文件（#38，设计为人独占修改，
  实际已授权 AI 自动更新）；真实人工触点仅两个 = spec 前 brainstorm 问答、收尾真机验收。
- **官方指导**：Anthropic《Prompting Claude Fable 5》："Skills developed for prior models
  are often too prescriptive for Claude Fable 5 and can degrade output quality."
  官方点名仍需外部支撑的四样：文件化持久记忆（实测 3x）、fresh-context 验证 subagent、
  进度声明对照 tool result 审计、意图上下文+短指令范围纪律。OpenAI GPT-5.6 指南：
  保留清单（结果/成功判据/停止条件/硬约束）恰为 Loop Contract 四字段；矛盾规则比缺失更伤；
  删减用 ablation 方法论。
- **主观基线**（改后对照用）：Opus 4.6 → Fable 5 用户无明显「变强」体感（与外界普遍体感相反），
  假设为过度约束吞掉了能力增量。
- 设计契约：`docs/specs/2026-08-14-v5-subtraction-design.md`（五段逐段人工确认 + 两轮自检）。

### Ablation 台账（复发 → 记一行含当时模型 → 只定点回装，不整体回滚）

| 切除项 | 守护的失败模式 | 复发信号 | 回装方式 |
|---|---|---|---|
| 四行声明块→两行 | 跳过路由/模式判断 | 无声明出现 opsx/代码（warn-route-before-opsx 报） | 恢复格式块 |
| Mode B 白名单法条 | 未审视意图直奔 spec | spec 返工 / R-revision 上升 | 恢复谓词清单 |
| recitation | 长会话目标漂移 | 产出偏离 Outcome | 恢复每 task 复述 |
| Rationalization/Red flags 表 | 借口式绕规则 | 借口原话再现 | 定点恢复对应条目 |
| warn-apply-phase hook | apply 中途重跑 propose | 契约失效无法归因 | 重新注册 hook |
| toolchain-refresh 常设 | 工具静默腐烂 | 命令突然失效/文档漂移 | 恢复 skill 或例行 |
| 40% 上下文教条 | 上下文过载质量跳水 | 长会话遵循度衰减 | 恢复阈值纪律 |
| NORTH_STAR 独立文件 | 价值锚稀释 | self-indulgence 未被拦截 | 恢复独立文件 |
| cheap-model 规范块 | 降级派发质量事故 | 降级 subagent 产出胡编 | 恢复规范块 |

### GREEN 观察位（下个真实项目 / 首个迁移项目，结果回填本条目）

1. 无格式强制下 brainstorm 是否仍默认先行（头号观察位）
2. 两行路由声明出现率；spec 返工 / R-revision 频次
3. stuck 判据是否仍截住无效重试
4. token 对比：change-loop 注入量（16KB→~5KB）、CLAUDE.md 常驻量
5. 主观对照：「模型是否变聪明」体感 vs 上面的 RED 基线

## 2026-08-09 — bootstrap 三测（zd-tool，small 项目首次立项）

### RED：`SPEC.md` 文件名在 WORKFLOW.md 与 skills 层之间语义冲突

- **观察**：按 WORKFLOW.md 附录 B 的小工程布局，把项目永久设计文档命名为根 `SPEC.md`。
  随后跑 `toolchain-refresh`，Step 0 mid-change guard 立刻误判「有变更进行中」——它把根
  `SPEC.md` 的存在当作 R1 变更的标志。追查发现三处 skills 层定义一致且与 WORKFLOW.md 相反：
  change-loop §「Where SPEC-lite lives (R1)」规定非 OpenSpec 项目的**单次变更** spec-lite 写入
  根 `SPEC.md` 并在收尾时移入 `docs/changes/`；toolchain-refresh mid-change guard 同义；
  `templates/CLAUDE.md` Session Start Protocol 同义。而 WORKFLOW.md 第 6 部分（整节）、附录 B、
  附录 F 把它当项目永久 spec（含 Tasks / Decisions / Progress Notes 段）。
- **未拦截住的后果（若不改）**：① 每次 toolchain-refresh 永远只做 inventory，不做更新，且
  「被 guard 拦下」看起来是正常行为，不会报错；② 第一次 change-loop 收尾会把项目永久设计文档
  移进 `docs/changes/`。两个都是静默失败。
- **修正（减法式）**：不重写流程，只统一文件名 + 标注冲突。小工程永久设计文档改名 `DESIGN.md`
  （WORKFLOW.md 第 6 部分全节、附录 B、附录 F、Layer 图、小工程核心循环图共 11 处）；
  第 6 部分与附录 F 顶部各加一个 ⚠ 块，写明「已修正=文件名 / 未修正=流程语义」，并声明
  冲突时以 skills 为准（依据 project-bootstrap「phase procedure lives in skills, not in this file」）。
- **遗留待决（未动）**：WORKFLOW.md 第 6 部分的流程本身仍是 v3 语义——无 Route Declaration、
  无 `NORTH_STAR.md`、无 `backlog.md`；附录 F 的小工程 CLAUDE.md 模板已被 `templates/CLAUDE.md`
  完全取代。该节是否保留 / 如何对齐，属产品决策，未替用户定。

### GREEN：project-bootstrap Step 3 的 hook 模板在 Windows 上有两个必须适配的点

- **`-m` 歧义**：heavy-test hook 模板的 `<SAFE_FILTER_REGEX>` 对 pytest 栈填 `\s-k\s` 类正则时，
  若一并放行 `-m`，会被 `python -m pytest` 里属于 **Python 的模块参数** `-m` 命中——该 hook 对
  每一条裸跑命令都放行，静默失效。修法：只检查 `pytest` 之后的参数尾串。
- **matcher 只写 `Bash` 会漏**：本机主 shell 是 PowerShell，测试命令走 PowerShell 工具时
  `"matcher": "Bash"` 不触发。改为 `"matcher": "Bash|PowerShell"`。
- 两点均经 17 条 echo 用例验证（含 `-m "not heavy"` / `-k` / 逃生变量 bash 与 pwsh 两种写法 /
  非测试命令），17/17 通过。
- **已回写进附录 G**（2026-08-09 同日）：settings.json 配置段 matcher 改 `Bash|PowerShell` 并加注；
  `<SAFE_FILTER_REGEX>` 说明改为「只匹配 runner 名之后的尾串」；模板脚本本体加入 runner-name
  split（复用 `<TEST_CMD_REGEX>` 作切分点，保持三个占位符）；验证用例从四个扩到五个，
  Test 5 专测 wrapper 短参数陷阱且要求用「日常真正敲的那条命令」；填充示例补 Python/pytest 一组。
- **回写时新发现的第三个坑**：模板复用 `<TEST_CMD_REGEX>` 做 `-split` 切分点，该正则**必须用
  非捕获组** `(?:...)`——PowerShell 的 `-split` 会把捕获组内容塞进结果数组，导致 `[1]` 拿到的是
  捕获文本而非参数尾串。实测：`'x npm run test --testNamePattern y' -split '\bnpm\s+(test|run\s+test)\b',2`
  的 `[1]` = `'run test'`；换成 `(?:...)` 后 `[1]` = `' --testNamePattern y'`。已写入模板 CAUTION 段。

### 附带发现：Opus 注入 wrapper 静默失效（已随用户决定整体移除）

- 2026-07-20 装的 `$PROFILE` wrapper 正则为 `^opus$|opus-4-8`，用户升级默认模型到
  `claude-opus-5[1m]` 后匹配不上；且三个 `settings.json` 均无 `model` 字段、
  `$assumeOpusDefault = $false`，导致裸跑 `claude` 一直未注入。**从 07-20 到 08-09 期间
  所有「以为注入了」的会话实际都没注入**，且无任何可见症状。
- 用户判定注入机制在 Opus 5 后已不需要，wrapper 整体删除（备份
  `Microsoft.PowerShell_profile.ps1.bak-2026-08-09`）。project-bootstrap Step 4 相应作废。
- **教训**：把版本号硬编码进匹配条件的自动化，失效时是静默的。若将来再引入同类机制，
  必须带一条「注入是否生效」的可观察输出。

## 2026-07-09 — v4.1 二测（finance_tool，第二个 change 归档后）

### 用户澄清设计意图：Verify/Polish 是判断项不是必走项，但「未起」必须归档时主动汇报

- **观察**：add-research-report 归档时未跑 /opsx:verify 与 Polish（5.7.1/5.7.2），归档汇报也未说明
  「未起及原因」；用户追问后才对照出实质覆盖矩阵（5.6.1 被 R2 spec reviewer 的 Requirement 覆盖表
  吸收、5.6.2 被契约端到端实跑覆盖、5.7 部分被 findings 驱动的 remediation 覆盖）。
- **用户原话**：「这个verify和polish的流程，也不是说每个change都死板的必走，我在设计这个change-loop
  的skill时也说是希望ai根据任务和状态等自行判断是否要起verify和polish的流程，需要起就直接起，如果
  没有起，在归档后要告诉我一声并说明不需要起的原因。change-loop的skill我们不能在做加法，也应该根据
  实际和真正的便利性，合理的做减法」
- **修复（减法式）**：不加新块、不加新声明格式——只扩写 Step 4 evidence bundle 既有条目
  「Anything skipped or deferred, stated plainly」，点名 §5.6 Verify / §5.7 Polish 为 judgment call：
  需要则直接起，跳过则归档汇报带「未起 + 原因」。

## 2026-07-08 — v4.1 二测（finance_tool，第二个 change propose 前）

### 用户发现：change-loop skill 丢失了 WORKFLOW.md §5.3 的 pre-spec Explore 声明

- **RED（用户原话）**：「一般在进propose前，不是应该判断是否过一轮explore吗，我看上一个change你也没问，是我的这个工作流skill没有写明这一点，还是你已经默认判断这个change到这里已经不需要走explore了？」
- **根因**：v4.1 重写 change-loop 时，§5.3 的显式 Explore 声明被 Route Declaration 的 `Explored:` 行吸收——但两个检查点时机不同：`Explored:` 在 route 前（brainstorm 之前），§5.3 在 brainstorm 之后、spec 之前。brainstorm 可能冒出新依赖/新代码面，合并后没有形式化触发器强制回头再看。实证：add-data-access 含新外部依赖，按 §5.3 判据应答「需要」，其重型 vendor 调研在功能上覆盖了 explore，但声明形式未走，用户无法看到判断发生过。
- **修复**：change-loop skill 补「Pre-spec explore declaration」轻量一行式（needed / not needed + 理由，三触发判据沿用 §5.3），置于 Mode 段之后；Red flags 增补一条。不恢复独立阶段。

## 2026-07-07 — v4.0 首测（Opus 会话，真实新项目立项）→ v4.1

### 用户报告的 8 条发现 → 修复对照

| # | 首测发现 | 根因 | v4.1 修复 |
|---|---|---|---|
| 1 | 部署全手动（复制 skills、手配 hooks） | 立项/部署无 owner——GUIDE §4 是给人的文档，违反自家约束下沉原则 | 新增 `project-bootstrap` skill：AI 执行、人确认 |
| 2 | NORTH_STAR/CLAUDE.md 立项前人填不出 | 部署顺序颠倒：先填模板后 brainstorm | 顺序反转：brainstorm → AI 回填 → 人逐行确认 |
| 3 | heavy-test hook 立项前无法决策 | 同 #2（stack 未定，模板三个空无解） | hooks 移到 bootstrap Step 3（brainstorm 之后），步骤可重入、可回补 |
| 4 | 立项讨论不主动调 superpowers:brainstorming | 立项时项目 CLAUDE.md 尚不存在，无触发路径 | bootstrap Step 1 显式 REQUIRED SUB-SKILL；description 含中文触发词（立项/新项目） |
| 5 | 立项完成后不主动触发 change-loop | description 只覆盖"starting a change"，漏掉"立项→实现"交接时刻 | change-loop description 增补交接与 backlog 触发；bootstrap Step 5 以"下一个动作是 change-loop"收尾 |
| 6 | 跳步：直接 propose，无 Mode 判断、无 explore | 路由输出是散文，可只说一半（结构缺失型失败，per writing-skills Match-the-Form）；且路由表 Process 列把 R2 写成 "Full propose → loop"，把 propose 误导成路由后的下一步、短路了 Mode 判断（追问 #Q1 确认：R2≠Mode B——新外部依赖型 R2 从定义上过不了谓词 2，多数 R2 应为 Mode A） | Route Declaration 四行必填块 + Process 列显式插入 Mode 步骤 + Mode↔Next 绑定（Mode A + Next: propose = 自相矛盾）+ `warn-route-before-opsx` hook（harness 兜底） |
| 7 | OPUS-SYSTEM.md 全程未注入 | 注入依赖人手动执行命令（记忆型约束）；追问 #Q2：独立 `opus` 别名也会被「直接敲 claude、默认模型已是 Opus」的启动习惯绕过 | 模型感知 `claude` wrapper 写入 `$PROFILE`（解析 --model → env → settings 三级，命中 Opus 才注入），注入自动化且不依赖启动习惯 |
| 8 | toolchain-refresh / value-review 未触发 | value-review：未达触发条件（正常，非缺陷）；toolchain-refresh：bootstrap 触发点无人执行，且不覆盖工具包自身 | bootstrap Step 5 显式调用；toolchain-refresh 增加工具包自更新步骤 |

### 同批排查发现的潜在问题（用户未报，已修）

- **引用不可解析**：项目会话里 `dispatch-prompt` / "WORKFLOW.md 附录 G/§5.8" 无处解析（clone 路径没有任何记录）→ dispatch-prompt.md 移入 change-loop skill 随部署走；CLAUDE.md 模板加 Toolkit 行；clone 路径落 `~/.claude/my-work-skill.toolkit-path`。
- **双权威**：OPUS-SYSTEM.md Working loop 自带一套粗粒度路由，Opus 可能照它走而不调 change-loop → 加 authority 让渡行。
- **skills 部署副本永不自更新**：toolchain-refresh 只更新插件不更新工具包自身 → Update 步骤增补。
- **settings.json 覆盖风险**：AI 配 hooks 时整文件覆盖会杀掉其他工具（如 claude-mem）的 hooks → bootstrap 明确 MERGE 纪律。
- **保鲜兜底 hook 只存在于文档**：`warn-toolchain-stale` 写在 toolchain-refresh 里但从未部署 → bootstrap 默认部署。
- **实测记录无落点**（本文件的由来）：README 要求「先有失败证据再改 skill」但没说证据记在哪；首测记录被权宜塞进 GUIDE §8 → 建本文件，README 修改约定补落点。

### 当日验证证据（GREEN 微测，近似——真实证据待下个项目）

- **触发微测**（subagent，3 场景）：空仓立项 → project-bootstrap ✓；有 NORTH_STAR 项目 backlog 取项 → change-loop ✓；v3 项目迁移 → project-bootstrap ✓。
- **防跳步微测**（subagent 复现首测失败场景「立项刚结束，开始第一个 change」，2 遍）：两遍均先只读探索 → 完整四行声明块 → Mode A 判断（逐条核对三个白名单谓词）→ Next 指向 brainstorm 而非 propose。
- **hook 脚本实跑**（5 用例）：opsx:propose 触发提醒 / change-loop 静默 / 40 天 stale 告警 / 新鲜文件静默 / 缺文件基线提示，全过。
- **`claude` wrapper 实跑**（5 用例，本机真实 settings）：显式 `--model opus` 注入 / 全名 `claude-opus-4-8` 注入 / 无参回落 settings（当时为 fable → 正确不注入）/ 环境变量优先于 settings / 显式 fable 覆盖 opus 环境变量，全过。

### 后续规则

- 若 v4.1 复测中 Route Declaration 块仍被跳过 → 按约束下沉原则升级为硬 hook（block 而非 warn）。
- GREEN 观察清单见 GUIDE §8（含 Mode↔Next 自洽率、路由分布、wrapper 行为学证据等本轮新增项）。

涉及文件：新增 skills/project-bootstrap/、FIELD-LOG.md；改 skills/change-loop/SKILL.md、skills/toolchain-refresh/SKILL.md、templates/CLAUDE.md、templates/NORTH_STAR.md、OPUS-SYSTEM.md、GUIDE.md、README.md、quickstart.html；templates/dispatch-prompt.md → skills/change-loop/dispatch-prompt.md。
