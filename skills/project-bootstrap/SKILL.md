---
name: project-bootstrap
description: Use when starting a new project with this workflow (立项 / 新项目 / kick off a project), deploying or updating the toolkit's skills and hooks on a machine or in a project (部署工作流), migrating a v3/v4/v5.0/v5.1/v5.2/v5.3/v5.4 project (including slimming an oversized backlog.md, re-deploying hooks from the toolkit's hooks/ directory, refreshing OpenSpec and its config.yaml), or when Session Start finds the project's Toolkit version differing from ~/.claude/my-work-skill.toolkit-version, the project CLAUDE.md missing its North Star section, or backlog.md missing / lacking Now and 主线 sections.
---

# Project Bootstrap

AI 执行、人确认：人只回答 brainstorm 问题、逐行确认回填文档。**顺序承重：先 brainstorm，
文档从其结果回填**——先填模板必然是空的或编的。各步幂等，可单独重跑（如 heavy-test
hook 的日后回补）。

## Step 0 — 装机（机器级）

1. toolkit 路径：读 `~/.claude/my-work-skill.toolkit-path`；没有 → 问人 clone 在哪
   （或现场 clone），把路径写入该文件——之后所有引用（`hooks/`、`templates/`、GUIDE §6、
   本 skill 更新）由它解析。**这个文件和下面的版本标记文件都要无 BOM 写入**（PowerShell 5.1
   的 `>` / `Out-File` 默认带 BOM，PowerShell 自己读会吞掉，bash / python 读到的是 `﻿`
   开头的路径，比对和拼路径都失败）：`[IO.File]::WriteAllText($p, $v, (New-Object
   System.Text.UTF8Encoding $false))`；已有文件带 BOM → 同法重写。
2. clone 干净则 `git -C <toolkit> pull`；复制 `skills/*` → `~/.claude/skills/`（覆盖——
   部署的是副本，不会自更新）；**同时删除工具包已移除的 skill 目录（如 toolchain-refresh）**
   ——覆盖复制不清理死副本，死 skill 的触发词仍会命中。项目级 `.claude/skills/` 里的工具包
   skill 副本（v4 部署过，含死 skill）**一律删除**，只留用户级一份——两处同名时哪个生效不透明
   （finance_tool 实测两处都被扫描），两份必漂移。复制完把 `<toolkit>/VERSION` 写入 `~/.claude/my-work-skill.toolkit-version`
   ——这是「机器上部署的是哪版」的唯一记录，Session Start 拿它和项目 Toolkit 行比对。**这一步在
   任何项目里跑都会升级机器级 skill，其他项目下次 Session Start 会因版本不等被要求迁移——这是
   设计，不是事故。**
3. 前置：superpowers 插件在（brainstorming / systematic-debugging 是循环依赖）；缺 →
   `/plugin marketplace add obra/superpowers-marketplace` → `/plugin install superpowers@superpowers-marketplace`
   → `/plugin list` 确认 enabled。中型项目：全局 OpenSpec CLI 跟上最新——`openspec --version` 与
   `npx @fission-ai/openspec@latest --version` 不等则 `npm i -g @fission-ai/openspec@latest`
   （Node ≥ 20.19）；生成文件由 CLI 重生成，全局落后会让日常命令与生成文件版本错位。
   profile：`openspec config profile` 只有交互选择器或整套 preset，非交互加单个 workflow 只能
   直接编辑 `openspec config path` 指向的 config.json 的 `workflows`（期望：core 六个
   propose / explore / apply / update / sync / archive + verify，delivery both）——机器级，影响所有
   项目下次 `openspec update` 的命令集，这是期望状态。

机器已是最新（路径文件在、skills 与 toolkit 一致、无死目录、标记文件 = VERSION）→ 一行说明，继续。

## Step 1 — 立项 brainstorm

**REQUIRED SUB-SKILL: superpowers:brainstorming。** 宣布并调用，不自由采访。已有文档/
代码先读，不问它们已回答的。必须产出（= Step 2 的槽位）：

- North Star 段三要素：谁通过这个项目得到什么（一句话）+ 可观察成功判据 + anti-scope
  （当前阶段只写在 backlog Now，不进 North Star——两处必不一致）
- **主线路径**：格式见 `templates/backlog.md` 主线段——从零到成功判据的有序步骤，每步标
  解锁哪条判据；外部事件（专家回信、新版本样本）也是步骤，带到期日或 kill 线
- 规模：小型（R0/R1 为主，无 OpenSpec）vs 中型（OpenSpec）
- Stack、build/test 命令、test filter flags、运行须知
- heavy tests？（单测 >200MB 内存 / 外部依赖 / e2e）→ 喂 Step 3

## Step 2 — 回填（AI 起草 → 人逐行确认 → commit）

1. `CLAUDE.md` 从 toolkit 的 `templates/CLAUDE.md` 起草，North Star 段填 brainstorm 结果，
   Toolkit 行填 clone 路径与 `<toolkit>/VERSION`。
2. `backlog.md` 从 `templates/backlog.md` 起草（所有规模）：主线段填 brainstorm 的路径，
   Now 段指向第 1 步。
3. 中型：`npx @fission-ai/openspec@latest init`（Claude Code，core profile）；`openspec/config.yaml`
   从 `templates/openspec-config.yaml` 起草，context 与 CLAUDE.md Stack 段同步、测试命令纪律填
   Step 3 的答案；ARCHITECTURE.md：架构 + 模块 + 关键决策及 rationale（AI 写人审：是否反映
   brainstorm 真实结论）。

无 `<placeholder>` 存活——填不出 = Step 1 没做完，回去。

**存量项目迁移**（幂等；AI 起草 → 人确认。有人在场：确认后落盘；无人值守会话：可先落盘并
单独提交，backlog Now 悬而未决记一条「迁移 commit 待确认（主题 chore: migrate toolkit …）」——
hash 写不进 commit 自身，不写 hash——人不同意就 revert——迁移只改文档，git 兜底。判定以 harness
说明为准：系统提示说用户不在实时看 = 无人值守；拿不准按无人值守）。触发：Session Start 版本
比对不等，或形态缺失。时机：只在绿树 task 边界做，单独的 docs commit（主题
`chore: migrate toolkit <旧> -> <新>`，可多于一个），不在红迭代里迁；在途 change 的 Loop Contract 与 tasks.md 不动，Close 按新 skill 补 `Gate:` /
`主线:` 行（兼容承诺见 GUIDE §5）。从项目 Toolkit 行的版本起，按下面各段顺序执行到当前版本
（无 `版本:` 行 = v5.3 前立项，按形态推断起点：有 NORTH_STAR.md / PROTOCOL.md / warn-toolchain-stale
→ v4；backlog 无 Now / 主线段 → v5.0；hook 无 stdin UTF-8 行 → v5.1；config.yaml 无 operations 段
→ v5.2；hook 无 OutputEncoding 行 → v5.3；拿不准取更早的）；
**最后把 Toolkit 行版本改成 `<toolkit>/VERSION`——这是迁移完成的定义**，没改下次 session 还会触发。
通用动作（各版本段之外）：① hooks 重部署放在 backlog 瘦身**之后**，否则 warn-backlog-size 对每条
提到 backlog.md 的命令都响；② 引用清扫——grep 项目里对已删事物的引用（toolchain-refresh、
NORTH_STAR.md、PROTOCOL.md、WORKFLOW.md、OPUS-SYSTEM）：CLAUDE.md / backlog / 注释直接改，
living spec 里的记支线走 change-loop；③ 项目自有 hook 按写法法则体检（BOM / 中文 / OutputEncoding /
可见性），不合规的记支线；settings.json 里既有 hook 的 matcher 一并核对——命令类必须
`Bash|PowerShell`，旧部署只挂 `Bash` 的从来没看住 PowerShell 调用（finance_tool、new_review_create
都是）。

- v3/v4：NORTH_STAR.md 只保留终态 + 判据 + anti-scope 并入 CLAUDE.md North Star 段后删除
  该文件（Review Log 与历史注记进 git）；`openspec/` 与既有 hooks 保留；移除 `$PROFILE` 中的
  `function claude` wrapper；删 PROTOCOL.md 与项目内 WORKFLOW.md 副本；注销 warn-apply-phase、
  warn-toolchain-stale 两个 hook，删 `.claude/last-toolchain-refresh`。
- v5.0 → v5.1 **backlog 瘦身**（超 8KB 即做），按此顺序：① 每个历史段先按 GUIDE §6 归属表
  把读数 / 裁定 / 教训 / 协议抄本各抽成一条，搬到 `docs/notes/<date>-<slug>.md`、
  `docs/decisions.md` 或对应 change 归档（backlog 留一句 + 路径）；**逐 change 的开工前记录与
  收工摘要整段追加到该 change 归档末尾**（OpenSpec：proposal.md，R1 归档只有 spec-lite.md 就追加
  在那里；其他：`docs/changes/<id>.md`；段名 `## Migrated notes`），不是只抽结论——用户裁定（zd-tool 迁移，2026-09-11）；② 挂不到
  任何 change 或文件的交接叙事才删（git 有）；③ 最新交接压成 Now 四字段；④ watch 压成支线一行，长尾进 `docs/watchlist.md`；
  done 条目压成 Done 段一行；⑤ 无主线段 → 从 North Star + 现有 roadmap 写出。人确认的
  对象 = 新 backlog 全文 + 新建文件清单（路径 + 一句），不逐行。搬，不删信息。
  **搬迁用脚本，不手抄**（new_review_create 340KB 实测）：超 100KB 先量各段字节（归档区密度可达
  入口区 3 倍，按行切块会撞 Read 上限），按字节切块读；建「源行号区间 → 目标文件」映射，断言
  **每一源行恰好归属一次**（漏 = 丢信息，重 = 重复；off-by-one 就是它抓出来的）；先算完全部
  区间再写文件，写坏一半的风险为零；Bash 里跑 Python 设 `PYTHONUTF8=1`，否则报错行是乱码。
- 项目 CLAUDE.md 对照 `templates/CLAUDE.md` 补齐差异，并 grep 删除与 v5.1 冲突的旧规则：
  subagent「用户确认后再开」类条款、archive 计数触发、四行路由声明、toolchain-refresh 引用。
- v5.1 → v5.2（OpenSpec 项目）：全局 CLI 先按 Step 0 升到最新；`openspec update` 会整体覆盖
  生成文件，先 `git log --oneline -- .claude/commands/opsx .claude/skills/openspec-*` 确认没有
  本地定制（有则先搬到别处——生成文件归 OpenSpec 所有），再 update（补 `/opsx:update`
  `/opsx:sync`；不交互）；`openspec/config.yaml` 对照 `templates/openspec-config.yaml`
  补 context / rules / operations 段（`schema:` 行不动）；`.claude/scripts/` 对照 `hooks/` 重部署
  全部 hook（Tier 1 也改了 stdin UTF-8 + 坏 JSON exit 1；Tier 2 旧写法模型看不见）并重跑 echo 用例。
- v5.2 → v5.3：只有 Toolkit 行补 `版本:`（由上面的收尾动作完成）。
- v5.3 → v5.4：`.claude/scripts/` 对照 `hooks/` 重部署（补 OutputEncoding、Tier 1 提示语栈无关），
  按 hooks/README 新配方重跑 echo 用例（旧配方 exit 永远 0）。
- v5.4 → v5.5：CLAUDE.md North Star 段删「当前阶段重点」行，改为指向 backlog Now（value-review
  观察位 #7 升级为规则）。

## Step 3 — Hooks（此时 stack 已知）

源码：toolkit `hooks/`（6 个脚本 + README：原则、settings.json 注册片段、heavy-test Day-1 三问、
echo 用例表）。复制到 `.claude/scripts/` + 注册进 `.claude/settings.json`。**MERGE 不覆盖**——
别的工具也在里面注册 hooks：先读、再加、再验 JSON。

**两条写法法则**（2026-09-08 实测 Claude Code 2.1.259 + Windows PowerShell 5.1）：

- 可见性：PreToolUse / PostToolUse 等工具事件下，模型看得见的是 JSON
  `hookSpecificOutput.additionalContext`（exit 0）或 exit 2 + stderr；`exit 0 + 纯文本 stdout`
  只进 debug 日志。例外：SessionStart / UserPromptSubmit 的纯文本 stdout 会进上下文，照旧。
- 编码：脚本只含 ASCII（无 BOM UTF-8 里的中文可能被按 GBK 解码吞掉后续字节，静默失效或
  解析错误）；读 stdin 前显式设 UTF-8——Claude Code 送的是 UTF-8，PowerShell 5.1 默认按
  控制台代码页（936）解，真实中文载荷会让 JSON 解析失败、hook 静默退出。

部署清单（6 个，`hooks/` 已按上述法则写成，原样复制）：

- `block-unsafe-test-commands`（heavy-test）：走 hooks/README 的 Day-1 四问填三个占位符，
  去掉 `-TEMPLATE` 后缀；「暂无重测试」与「裸命令已由配置默认安全」都是合法答案——落点
  CLAUDE.md Stack & Conventions 一行「无重型测试 / 裸命令已安全（原因），未部署 heavy-test hook
  （<date>）」+ backlog 支线一行（触发：出现重型测试 / 出现绕过配置的跑法），之后的 session 不重问。测试命令纪律同时写进 CLAUDE.md Stack & Conventions 与
  `openspec/config.yaml` context。
- `block-replaced-skills`、`block-superpowers-specs-dir`（Tier 1，PreToolUse）。
- `warn-destructive-git`、`warn-route-before-opsx`（Tier 2，JSON additionalContext）；后者的
  命令名单先核对已装 OpenSpec 版本。
- `warn-backlog-size`：注册在 `"PostToolUse"` 段，matcher `Write|Edit|Bash|PowerShell`。

每个部署的脚本跑 hooks/README 用例表里的 echo 用例并粘贴输出——**没 echo 测过的 hook 不算
部署**（静默死掉的 hook 比没有更坏，你以为强制层存在）。配方照 hooks/README「Echo 用例」：
`Start-Process cmd ... -WindowStyle Hidden -Wait -PassThru` 在独立控制台里跑，读 `$p.ExitCode`
（`echo exit=%errorlevel%` 永远打 0；在会话控制台里 `chcp` 会把 TUI 画坏）；in.json 为无 BOM
UTF-8 且含中文。挂载后在会话里真跑一次被拦的命令确认 matcher 生效。

## Step 4 — 收尾

1. 装机级 break-check 一次：`openspec --version`（全局 CLI）+ 最便宜的真实命令（如
   `openspec list`），确认命令面与工具包文档一致；不一致先改文档再依赖新行为。
   日后工具异常的排查要点见 GUIDE §4。
2. Commit 文档与配置（英文 message，不 push）。
3. 收尾声明：**bootstrap 到此为止——第一个 change 从 change-loop 的路由声明开始，
   不是从 propose 开始。** 然后停下；选第一个 backlog 条目是下一轮的事。

## Common mistakes

- brainstorm 之前手填模板（槽位只能空着或编造——顺序是承重的）。
- 覆盖 settings.json（静默杀掉其他工具的 hooks——必须 merge）。
- 跳过 echo 测试（hook 静默死掉 = 你相信一个不存在的强制层）。
- 把 bootstrap 完成当 propose 许可（第一个 change 与所有 change 一样从路由开始）。
- 迁移时只加新规则不删旧规则（项目 CLAUDE.md 优先级高于 skill，旧计数触发会压过新触发表）。
- 迁移做了一半没改 Toolkit 行版本（下次 session 重复触发），或改了版本没做迁移（漂移被掩盖）。
