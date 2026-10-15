---
name: project-bootstrap
description: Use when starting a new project with this workflow (立项 / 新项目 / kick off a project), deploying or updating the toolkit's skills and hooks on a machine or in a project (部署工作流), migrating a v3/v4/v5.x/v6.x project to the current version (including slimming an oversized backlog.md, re-deploying hooks from the toolkit's hooks/ directory, retiring OpenSpec generated files), or when Session Start finds the project's Toolkit version differing from ~/.claude/my-work-skill.toolkit-version, the project CLAUDE.md missing its North Star section, or backlog.md missing / lacking Now and 主线 sections.
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
3. 没有外部前置。superpowers 插件（v6.1）与 OpenSpec CLI（v7.0）都已退役：装着也无妨，但前者的
   SessionStart 法条式注入会压低输出，后者的 `openspec update` 会把 29 处「等用户」的生成 skill 重新塞回项目。

机器已是最新（路径文件在、skills 与 toolkit 一致、无死目录、标记文件 = VERSION）→ 一行说明，继续。

## Step 1 — 立项 brainstorm

立项 brainstorm 是一场对话，不是 skill：已有文档 / 代码先读，不问它们已回答的；stack 与命令自己读
仓库；只问属于人的题（谁 / 得到什么 / 判据 / anti-scope / 钱与时间线 / 找谁），打包一次问完，不一问一答。
必须产出（= Step 2 的槽位）：

- North Star 段三要素：谁通过这个项目得到什么（一句话）+ 可观察成功判据 + anti-scope
  （当前阶段只写在 backlog Now，不进 North Star——两处必不一致）
- **主线路径**：格式见 `templates/backlog.md` 主线段——从零到成功判据的有序步骤，每步标解锁哪条
  判据；外部事件（专家回信、新版本样本）也是步骤，带到期日或 kill 线
- **项目参数**（常设偏好，定一次）：资源停止线、花钱上限、大投入门槛、第二反方；拿不到写「无」或
  「待定 <date>」进 Now 悬而未决，不编
- 规模：小型（R0 / R1 为主，无能力主 spec）vs 中型（有能力主 spec：`docs/specs/<cap>/spec.md`）
- Stack、build/test 命令、test filter flags、运行须知；heavy tests？（单测 >200MB 内存 / 外部依赖 /
  e2e）→ 喂 Step 3

## Step 2 — 回填（AI 起草 → 人确认 North Star 与主线 → commit）

1. `CLAUDE.md` 从 toolkit 的 `templates/CLAUDE.md` 起草：North Star 段填 brainstorm 结果，Stack 段填
   命令与项目参数，Toolkit 行填 clone 路径与 `<toolkit>/VERSION`。
2. `backlog.md` 从 `templates/backlog.md` 起草（所有规模）：主线段填 brainstorm 的路径，Now 指向第 1 步。
3. 中型：建 `docs/specs/`、`docs/changes/archive/`、`docs/retros/`；每个起步能力一份
   `docs/specs/<cap>/spec.md`（四段：`# <cap> Specification` / `## Purpose` 2–3 句不留占位 / `## Requirements`
   `### Requirement:` + `#### Scenario:` WHEN/THEN / `## Architectural Decisions`）；ARCHITECTURE.md：架构 +
   模块 + 关键决策及 rationale。change 用 `templates/change.md`（见 change-loop §1 / §2）。

无 `<placeholder>` 存活——填不出 = Step 1 没做完，回去。人确认的对象 = North Star 段 + 主线段全文。

**存量项目迁移**（幂等；AI 起草 → 有人在场确认后落盘；无人值守先落盘并单独提交，backlog Now 悬而
未决记「迁移 commit 待确认（主题 chore: migrate toolkit …）」，不写 hash——迁移只改文档，git 兜底；
判定以 harness 说明为准，拿不准按无人值守）。触发：Session Start 版本比对不等，或形态缺失。时机：
绿树 task 边界，单独的 docs commit（主题 `chore: migrate toolkit <旧> -> <新>`，可多于一个）；在途
change 的契约与路由按旧格式收尾（新 skill 读旧契约）。从项目 Toolkit 行的版本起按段执行到当前版本，
**最后把 Toolkit 行版本改成 `<toolkit>/VERSION`——这是迁移完成的定义**。
通用动作：① hooks 重部署放在 backlog 瘦身**之后**；② 引用清扫——grep 项目里对已删事物的引用，
CLAUDE.md / backlog / 注释直接改，主 spec 里的记支线；③ 项目自有 hook 按 hooks/README 写法法则体检；
settings.json 里命令类 matcher 必须 `Bash|PowerShell`，路径必须走 `$CLAUDE_PROJECT_DIR`。

- **版本 < v5.5**：按 GUIDE §5「历史迁移步骤（v3 → v5.5）」逐段先迁到 v5.5。
- **v5.5 → v6.0**（2026-10-15 的分批裁定已于同日解除：其余项目一次累计迁到当前版本）：
  ① CLAUDE.md：Hard Rules 对照 `templates/CLAUDE.md` 替换（删「语义模糊停下问」「外部库 / API 先
  验证」「测试是承重墙」旧句，subagent 两条合一，加「问人四类」）；North Star 段删「Outcome 三分类」
  行；Stack 加项目参数行（有资源 / 花钱限制的项目初值问人一次；没有的写「无」，日后首次出现真实费用再问一次
  并写回）；Session Start 段删「只在 gate 或阻塞时问」；项目自加的
  **过程类**规则（must / 禁止 / 先…再…）逐条问「防哪种失败、近 4 周在当前模型上出现过吗」，答不出
  即删——红线、数据契约、anti-scope 式 Domain Rules、运行须知不动；删除清单写进迁移 commit 与首份
  里程碑汇总 ②，人可否决，复发只回装那一条并注当时模型。
  ② backlog.md：Now 删「支线计数」字段，头部句对照模板；支线行不补字段（到期按行出生日算）。
  ③ `docs/decisions.md` 头部加一行「<date> 起只收方向 / 钱 / 时间 / 找谁的人裁定；AI 决定在各 change
  归档的 Decided: 行」，历史不搬；`docs/watchlist.md` 不清理，首次到期审在下一个里程碑汇总；两个文件
  不存在则不建。
  ④（已被 v7.0 吸收，跳过。）
- **v6.0 → v6.1**：settings.json 注销 `block-replaced-skills` 与 `block-superpowers-specs-dir`，删
  `.claude/scripts/` 里的两个脚本（留着也无害，只是指向已卸载的插件）。
- **v6.1 → v7.0**（change 形态脱离 OpenSpec）：
  ① 有 `openspec/` 的项目：CLI 还在就先跑一次 `openspec validate --specs`，输出记进 `docs/notes/` 作基线；然后
  `git rm -r --ignore-unmatch .claude/skills/openspec-* .claude/commands/opsx openspec/schemas openspec/config.yaml
  .claude/scripts/warn-route-before-opsx.ps1`（目录内有未跟踪文件会残留，先 `git status` 看）——主 spec 与归档一字不动；
  settings.json 删 Skill matcher 块。
  ② CLAUDE.md：Session Start「找在途 change」按项目实际目录写（如 `openspec/changes/*/change.md`，或根 SPEC.md）；Stack
  内容归属行里指向 proposal.md / spec-lite 的措辞改为「归档 change.md」（有则改）；Enforcement 行按 settings.json 实际注册写；
  Toolkit 行 v7.0。
  ③ 引用清扫（正则放一行照抄）：
  `grep -rn -E 'opsx|openspec (archive|validate|new|update)|proposal|spec-lite|\.openspec\.yaml|schema: lite|SHALL' CLAUDE.md backlog.md docs .claude/skills .agents/skills`
  ——前瞻性的改，历史的留（`.agents` 不存在时忽略报错）。
  ④ 在途 change 按旧形态收尾（旧四件套的 Loop Contract 在 tasks.md 头部）；新 change 起用 `templates/change.md`。
  ⑤ backlog Now 悬而未决加「v7.0 迁移 commit 待确认」；删除清单进首份里程碑汇总 ②。
  ⑥ 小项目（无主 spec）：做 ① 的 settings.json / route 脚本两句与 ②③⑤。
  机器级：基线记完后 `npm uninstall -g @fission-ai/openspec`（用户 2026-10-15 裁定）；此后不再 `openspec update`。

## Step 3 — Hooks（此时 stack 已知）

源码：toolkit `hooks/`（3 个脚本 + README：原则、settings.json 注册片段、heavy-test Day-1 四问、echo
用例表）。复制到 `.claude/scripts/` + 注册进 `.claude/settings.json`，**MERGE 不覆盖**（别的工具也在
里面注册 hooks：先读、再加、再验 JSON）。写法法则（可见性：JSON `additionalContext` 或 exit 2 + stderr；
编码：脚本 ASCII、stdin / stdout / stderr 都 UTF-8、坏 JSON exit 1）`hooks/` 已满足，原样复制。

部署清单（3 个）：`block-unsafe-test-commands`（heavy-test）走 hooks/README 的 Day-1 四问填三个占位符
并去掉 `-TEMPLATE`——「暂无重测试」与「裸命令已由配置默认安全」都是合法答案，落点 CLAUDE.md Stack
一行 + backlog 支线一行，之后不重问；`warn-destructive-git`（Tier 2）；`warn-backlog-size`（`PostToolUse`，
matcher `Write|Edit|Bash|PowerShell`）。测试命令纪律写进 CLAUDE.md Stack。

每个部署的脚本跑 hooks/README 用例表里的 echo 用例并粘贴输出——**没 echo 测过的 hook 不算部署**。
配方照 hooks/README「Echo 用例」：在独立隐藏控制台里跑、读 `$p.ExitCode`、in.json 无 BOM UTF-8 含中文。
挂载后在会话里真跑一次被拦的命令确认 matcher 生效。

## Step 4 — 收尾

1. break-check 一次：跑一遍 CLAUDE.md Stack 里写的 Verify 命令样例，确认命令面与文档一致；不一致先改
   文档再依赖新行为（排查要点 GUIDE §4）。
2. Commit 文档与配置（英文 message，不 push）。
3. 收尾声明：**bootstrap 到此为止——第一个 change 从 change-loop 的路由声明开始。**

## Common mistakes

- brainstorm 之前手填模板（槽位只能空着或编造——顺序是承重的）。
- 向人问技术栈、命令、阈值这类自己读仓库或实测就能定的题（人只定方向、钱、时间、找谁）。
- 覆盖 settings.json（静默杀掉其他工具的 hooks——必须 merge）。
- 跳过 echo 测试（hook 静默死掉 = 你相信一个不存在的强制层）。
- 迁移时只加新规则不删旧规则（项目 CLAUDE.md 优先级高于 skill，旧规则会压过新 skill）。
- 迁移做了一半没改 Toolkit 行版本（下次 session 重复触发），或改了版本没做迁移（漂移被掩盖）。
- 在有 OpenSpec 遗留的项目里跑 `openspec update`（会把退役的生成 skill 连同停等文本重新生成）。
