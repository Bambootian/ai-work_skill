---
name: project-bootstrap
description: Use when starting a new project with this workflow (立项 / 新项目 / kick off a project), deploying or updating the toolkit's skills and hooks on a machine or in a project (部署工作流), migrating a v3/v4 project, or when the Session Start Protocol finds the project CLAUDE.md missing its North Star section (or a medium project missing backlog.md).
---

# Project Bootstrap

AI 执行、人确认：人只回答 brainstorm 问题、逐行确认回填文档。**顺序承重：先 brainstorm，
文档从其结果回填**——先填模板必然是空的或编的。各步幂等，可单独重跑（如 heavy-test
hook 的日后回补）。

## Step 0 — 装机（机器级）

1. toolkit 路径：读 `~/.claude/my-work-skill.toolkit-path`；没有 → 问人 clone 在哪
   （或现场 clone），把路径写入该文件——之后所有引用（附录 G、§5.8、本 skill 更新）
   由它解析。
2. clone 干净则 `git -C <toolkit> pull`；复制 `skills/*` → `~/.claude/skills/`（覆盖——
   部署的是副本，不会自更新）；**同时删除 `~/.claude/skills/` 下工具包已移除的 skill
   目录（如 toolchain-refresh）**——覆盖复制不清理死副本，死 skill 的触发词仍会命中。
3. 前置：superpowers 插件在（brainstorming / systematic-debugging 是循环依赖）；
   中型项目 `npx openspec --version` 可用。缺 → WORKFLOW.md 第 1 部分。

机器已是最新（路径文件在、skills 一致、无死目录）→ 一行说明，继续。

## Step 1 — 立项 brainstorm

**REQUIRED SUB-SKILL: superpowers:brainstorming。** 宣布并调用，不自由采访。已有文档/
代码先读，不问它们已回答的。必须产出（= Step 2 的槽位）：

- North Star 段四要素：谁通过这个项目得到什么（一句话）+ 可观察成功判据 + anti-scope +
  当前阶段重点
- 规模：小型（R0/R1 为主，无 OpenSpec）vs 中型（OpenSpec）
- Stack、build/test 命令、test filter flags
- heavy tests？（单测 >200MB 内存 / 外部依赖 / e2e）→ 喂 Step 3

## Step 2 — 回填（AI 起草 → 人逐行确认 → commit）

1. `CLAUDE.md` 从 toolkit 的 `templates/CLAUDE.md` 起草，North Star 段填 brainstorm 结果。
2. 中型：`npx @fission-ai/openspec@latest init` → ARCHITECTURE.md + backlog.md
   （结构：WORKFLOW.md 第 3 部分）。

无 `<placeholder>` 存活——填不出 = Step 1 没做完，回去。

**v3/v4 项目迁移**（幂等）：NORTH_STAR.md 内容并入 CLAUDE.md North Star 段后删除该文件；
`openspec/` 与既有 hooks 保留；移除 `$PROFILE` 中的 `function claude` wrapper；
删 PROTOCOL.md 与项目内 WORKFLOW.md 副本；注销 warn-apply-phase、warn-toolchain-stale
两个 hook，删 `.claude/last-toolchain-refresh`。

## Step 3 — Hooks（此时 stack 已知）

源码：toolkit 的 WORKFLOW.md 附录 G。部署到 `.claude/scripts/` + 注册进
`.claude/settings.json`。**MERGE 不覆盖**——别的工具也在里面注册 hooks：先读、再加、
再验 JSON。

部署清单（5 个）：

- `block-unsafe-test-commands`（heavy-test）：走附录 G 的 Day-1 三问填三个空位；
  「暂无重测试」是合法答案，出现时重跑本步。
- `block-replaced-skills`、`block-superpowers-specs-dir`、`warn-destructive-git`：照附录 G。
- `warn-route-before-opsx`（Tier 2，matcher Skill；先核对已装 OpenSpec 版本的命令名）：

```powershell
# warn-route-before-opsx.ps1 — Tier 2 soft warning (PreToolUse, matcher: Skill)
$json = [Console]::In.ReadToEnd() | ConvertFrom-Json
if ($json.tool_input.skill -match '^opsx:(propose|new)') {
  Write-Output "REMINDER: $($json.tool_input.skill) requires a route declaration earlier this session (change-loop: 'Route: R<n> - reason' + 'Next: ...'). None exists -> stop, invoke change-loop first."
}
exit 0
```

每个部署的脚本跑附录 G 的 echo 用例并粘贴输出——**没 echo 测过的 hook 不算部署**
（静默死掉的 hook 比没有更坏，你以为强制层存在）。

## Step 4 — 收尾

1. 装机级 break-check 一次：`npx openspec --version` + 最便宜的真实命令（如
   `npx openspec list`），确认命令面与工具包文档一致；不一致先改文档再依赖新行为。
   日后工具异常的排查要点见 GUIDE §4。
2. Commit 文档与配置（英文 message，不 push）。
3. 收尾声明：**bootstrap 到此为止——第一个 change 从 change-loop 的路由声明开始，
   不是从 propose 开始。** 然后停下；选第一个 backlog 条目是下一轮的事。

## Common mistakes

- brainstorm 之前手填模板（槽位只能空着或编造——顺序是承重的）。
- 覆盖 settings.json（静默杀掉其他工具的 hooks——必须 merge）。
- 跳过 echo 测试（hook 静默死掉 = 你相信一个不存在的强制层）。
- 把 bootstrap 完成当 propose 许可（第一个 change 与所有 change 一样从路由开始）。
