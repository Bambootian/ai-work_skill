---
name: project-bootstrap
description: Use when starting a new project with this workflow (立项 / 新项目 / kick off a project), deploying or updating the toolkit's skills and hooks on a machine or in a project (部署工作流), migrating a v3/v4/v5.x project to the current version (including slimming an oversized backlog.md, re-deploying hooks from the toolkit's hooks/ directory, refreshing OpenSpec and its config.yaml), or when Session Start finds the project's Toolkit version differing from ~/.claude/my-work-skill.toolkit-version, the project CLAUDE.md missing its North Star section, or backlog.md missing / lacking Now and 主线 sections.
---

# Project Bootstrap

AI 执行、人定方向：人只回答属于人的 brainstorm 问题（谁 / 得到什么 / 判据 / anti-scope / 钱与
时间线 / 找谁）并确认 North Star 段与主线段；Stack、命令、测试纪律、项目参数由你从仓库与 brainstorm
读出填好，人不逐行看——填错在第一个 change 的 Verify 就暴露。**顺序承重：先 brainstorm，文档从
其结果回填**——先填模板必然是空的或编的。各步幂等，可单独重跑。

## Step 0 — 装机（机器级）

1. toolkit 路径：读 `~/.claude/my-work-skill.toolkit-path`；没有 → 问人 clone 在哪（或现场 clone），
   写入该文件——之后所有引用由它解析。**路径文件与版本标记文件都要无 BOM 写入**（PowerShell 5.1 的
   `>` / `Out-File` 默认带 BOM，bash / python 读到 `﻿` 开头的路径）：`[IO.File]::WriteAllText($p, $v,
   (New-Object System.Text.UTF8Encoding $false))`；已有文件带 BOM → 同法重写。
2. clone 干净则 `git -C <toolkit> pull`；复制 `skills/*` → `~/.claude/skills/`（覆盖——部署的是副本），
   **同时删除工具包已移除的 skill 目录**（死 skill 的触发词仍会命中）；项目级 `.claude/skills/` 里的工具包
   skill 副本一律删除，只留用户级一份。复制完把 `<toolkit>/VERSION` 写入
   `~/.claude/my-work-skill.toolkit-version`——机器上部署的是哪版的唯一记录。**这一步在任何项目里跑都会
   升级机器级 skill，其他项目下次 Session Start 会因版本不等被要求迁移——这是设计，不是事故。**
3. 前置：superpowers 插件在（立项 brainstorm 依赖它）；缺 → `/plugin marketplace add
   obra/superpowers-marketplace` → `/plugin install superpowers@superpowers-marketplace` → `/plugin list`
   确认。中型项目：全局 OpenSpec CLI 跟上最新（`openspec --version` 与 `npx @fission-ai/openspec@latest
   --version` 不等则 `npm i -g @fission-ai/openspec@latest`，Node ≥ 20.19）；profile 非交互只能直接编辑
   `openspec config path` 指向的 config.json 的 `workflows`（期望 core 六个 + verify）——机器级。

机器已是最新（路径文件在、skills 与 toolkit 一致、无死目录、标记文件 = VERSION）→ 一行说明，继续。

## Step 1 — 立项 brainstorm

**REQUIRED SUB-SKILL: superpowers:brainstorming。** 宣布并调用，不自由采访。已有文档 / 代码先读，
不问它们已回答的；stack 与命令自己读仓库，不问人。必须产出（= Step 2 的槽位）：

- North Star 段三要素：谁通过这个项目得到什么（一句话）+ 可观察成功判据 + anti-scope
  （当前阶段只写在 backlog Now，不进 North Star——两处必不一致）
- **主线路径**：格式见 `templates/backlog.md` 主线段——从零到成功判据的有序步骤，每步标解锁哪条
  判据；外部事件（专家回信、新版本样本）也是步骤，带到期日或 kill 线
- **项目参数**（常设偏好，定一次）：资源停止线、花钱上限、大投入门槛、第二反方；拿不到写「无」或
  「待定 <date>」进 Now 悬而未决，不编
- 规模：小型（R0 / R1 为主，无 OpenSpec）vs 中型（OpenSpec）
- Stack、build/test 命令、test filter flags、运行须知；heavy tests？（单测 >200MB 内存 / 外部依赖 /
  e2e）→ 喂 Step 3

## Step 2 — 回填（AI 起草 → 人确认 North Star 与主线 → commit）

1. `CLAUDE.md` 从 toolkit 的 `templates/CLAUDE.md` 起草：North Star 段填 brainstorm 结果，Stack 段填
   命令与项目参数，Toolkit 行填 clone 路径与 `<toolkit>/VERSION`。
2. `backlog.md` 从 `templates/backlog.md` 起草（所有规模）：主线段填 brainstorm 的路径，Now 指向第 1 步。
3. 中型：`npx @fission-ai/openspec@latest init`（Claude Code，core profile）；`openspec schema init lite
   --artifacts "specs,tasks" --no-default`（R1 用的项目本地 schema，幂等，产物 `openspec/schemas/lite/` 入库——
   `lite` 不是 OpenSpec 内建）；`openspec/config.yaml` 从
   `templates/openspec-config.yaml` 起草（rules / operations 原样，context 与 CLAUDE.md Stack 同步、
   测试命令纪律填 Step 3 的答案）；ARCHITECTURE.md：架构 + 模块 + 关键决策及 rationale。

无 `<placeholder>` 存活——填不出 = Step 1 没做完，回去。人确认的对象 = North Star 段 + 主线段全文。

**存量项目迁移**（幂等；AI 起草 → 有人在场确认后落盘；无人值守先落盘并单独提交，backlog Now 悬而
未决记「迁移 commit 待确认（主题 chore: migrate toolkit …）」，不写 hash——迁移只改文档，git 兜底；
判定以 harness 说明为准，拿不准按无人值守）。触发：Session Start 版本比对不等，或形态缺失。时机：
绿树 task 边界，单独的 docs commit（主题 `chore: migrate toolkit <旧> -> <新>`，可多于一个）；在途
change 的契约与路由按旧格式收尾（新格式是旧格式的子集，不补行）。从项目 Toolkit 行的版本起按段执行
到当前版本；**最后把 Toolkit 行版本改成 `<toolkit>/VERSION`——这是迁移完成的定义**。
通用动作：① hooks 重部署放在 backlog 瘦身**之后**；② 引用清扫——grep 项目里对已删事物的引用，
CLAUDE.md / backlog / 注释直接改，living spec 里的记支线；③ 项目自有 hook 按 hooks/README 写法法则
体检；settings.json 里命令类 matcher 必须 `Bash|PowerShell`，路径必须走 `$CLAUDE_PROJECT_DIR`。

- **版本 < v5.5**：按 GUIDE §5「历史迁移步骤（v3 → v5.5）」逐段先迁到 v5.5。
- **v5.5 → v6.0**。分批裁定（2026-10-15，到期 = new_review_create 的首份 v6 里程碑汇总）：
  new_review_create 先迁；其余项目在此之前 Session Start 比对不等时只报一行「v6.0 待迁（分批裁定）」
  并照常继续，不迁（过渡期以 v6 skill + 旧 CLAUDE.md 运行，旧 Hard Rules 仍生效；到期后由工具包删本条并
  重部署，或人在该项目里说「迁」即迁）。步骤：
  ① CLAUDE.md：Hard Rules 对照 `templates/CLAUDE.md` 替换（删「语义模糊停下问」「外部库 / API 先
  验证」「测试是承重墙」旧句，subagent 两条合一，加「问人四类」）；North Star 段删「Outcome 三分类」
  行；Stack 加项目参数行（new_review_create 初值问人；其余项目写「无」——用户 2026-10-14：其他项目无此
  限制，日后首次出现真实费用再问一次并写回）；Session Start 段删「只在 gate 或阻塞时问」；项目自加的
  **过程类**规则（must / 禁止 / 先…再…）逐条问「防哪种失败、近 4 周在当前模型上出现过吗」，答不出
  即删——红线、数据契约、anti-scope 式 Domain Rules、运行须知不动；删除清单写进迁移 commit 与首份
  里程碑汇总 ②，人可否决，复发只回装那一条并注当时模型。
  ② backlog.md：Now 删「支线计数」字段，头部句对照模板；支线行不补字段（到期按行出生日算）。
  ③ `docs/decisions.md` 头部加一行「<date> 起只收方向 / 钱 / 时间 / 找谁的人裁定；AI 决定在各 change
  归档的 Decided: 行」，历史不搬；`docs/watchlist.md` 不清理，首次到期审在下一个里程碑汇总；两个文件
  不存在则不建。
  ④ OpenSpec 项目：`openspec/config.yaml` 的 rules 与 operations 段对照 `templates/openspec-config.yaml`
  替换；context 只删与被删 Hard Rules 同义的句子，其余不动；`openspec schema init lite --artifacts
  "specs,tasks" --no-default`（已有 `openspec/schemas/lite/` 则跳过）。
  ⑤ hooks：重部署 `warn-route-before-opsx.ps1` 并跑 echo 用例（其余脚本不变）。
  ⑥ finance_tool 特例：先了结 Now 里「v5.5 迁移 commit 待确认」。
  ⑦ Toolkit 行改 v6.0。

## Step 3 — Hooks（此时 stack 已知）

源码：toolkit `hooks/`（6 个脚本 + README：原则、settings.json 注册片段、heavy-test Day-1 四问、echo
用例表）。复制到 `.claude/scripts/` + 注册进 `.claude/settings.json`，**MERGE 不覆盖**（别的工具也在
里面注册 hooks：先读、再加、再验 JSON）。写法法则（可见性：JSON `additionalContext` 或 exit 2 + stderr；
编码：脚本 ASCII、stdin / stdout / stderr 都 UTF-8、坏 JSON exit 1）`hooks/` 已满足，原样复制。

部署清单（6 个）：`block-unsafe-test-commands`（heavy-test）走 hooks/README 的 Day-1 四问填三个占位符
并去掉 `-TEMPLATE`——「暂无重测试」与「裸命令已由配置默认安全」都是合法答案，落点 CLAUDE.md Stack
一行 + backlog 支线一行，之后不重问；`block-replaced-skills`、`block-superpowers-specs-dir`（Tier 1）；
`warn-destructive-git`、`warn-route-before-opsx`（Tier 2）；`warn-backlog-size`（`PostToolUse`，matcher
`Write|Edit|Bash|PowerShell`）。测试命令纪律同时写进 CLAUDE.md Stack 与 `openspec/config.yaml` context。

每个部署的脚本跑 hooks/README 用例表里的 echo 用例并粘贴输出——**没 echo 测过的 hook 不算部署**。
配方照 hooks/README「Echo 用例」：在独立隐藏控制台里跑、读 `$p.ExitCode`、in.json 无 BOM UTF-8 含中文。
挂载后在会话里真跑一次被拦的命令确认 matcher 生效。

## Step 4 — 收尾

1. 装机级 break-check 一次：`openspec --version` + 最便宜的真实命令（如 `openspec list`），确认命令面与
   工具包文档一致；不一致先改文档再依赖新行为（排查要点 GUIDE §4）。
2. Commit 文档与配置（英文 message，不 push）。
3. 收尾声明：**bootstrap 到此为止——第一个 change 从 change-loop 的路由声明开始，不是从 propose 开始。**

## Common mistakes

- brainstorm 之前手填模板（槽位只能空着或编造——顺序是承重的）。
- 向人问技术栈、命令、阈值这类自己读仓库或实测就能定的题（人只定方向、钱、时间、找谁）。
- 覆盖 settings.json（静默杀掉其他工具的 hooks——必须 merge）。
- 跳过 echo 测试（hook 静默死掉 = 你相信一个不存在的强制层）。
- 把 bootstrap 完成当 propose 许可（第一个 change 与所有 change 一样从路由开始）。
- 迁移时只加新规则不删旧规则（项目 CLAUDE.md 优先级高于 skill，旧规则会压过新 skill）。
- 迁移做了一半没改 Toolkit 行版本（下次 session 重复触发），或改了版本没做迁移（漂移被掩盖）。
