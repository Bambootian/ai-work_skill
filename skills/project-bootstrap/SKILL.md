---
name: project-bootstrap
description: Use when starting a new project with this workflow (立项 / 新项目 / kick off a project), deploying or updating the toolkit's skills and hooks on a machine or in a project (部署工作流), migrating a v3 project, or when the Session Start Protocol finds NORTH_STAR.md or backlog.md missing.
---

# Project Bootstrap

## Overview

Bootstrap is AI-executed, human-approved: the human answers brainstorm questions and reviews drafts; the AI does all installing, drafting, and config. **Order is load-bearing: brainstorm first, artifacts backfilled from its results.** Templates cannot be filled by hand before the project is understood — a pre-brainstorm template is either empty or invented.

Steps are idempotent — re-run any step later (e.g. hooks 回补 when heavy tests appear).

## Step 0 — Toolkit + skills (machine-level)

1. Toolkit clone path: read `~/.claude/my-work-skill.toolkit-path`. Missing → ask the human where the clone is (or clone it), then write the path into that file — every later reference (WORKFLOW.md 附录 G / §5.8, this skill's updates) resolves through it.
2. `git -C <toolkit> pull` if the clone is clean; copy `skills/*` → `~/.claude/skills/` (overwrite — deployed skills are copies and never self-update).
3. Prerequisites: superpowers plugin present (`brainstorming` / `systematic-debugging` are loop dependencies); for medium projects `npx openspec --version` works. Missing → WORKFLOW.md 第 1 部分 in the toolkit.

Machine already current (path file exists, skills identical) → say so in one line, continue.

## Step 1 — 立项 brainstorm

**REQUIRED SUB-SKILL: superpowers:brainstorming.** Announce it, then invoke it — do not free-form the interview. Existing docs/code: read them first, don't ask what they already answer.

Must come out of the brainstorm (they are the template slots of Step 2):

- 谁通过这个项目得到什么（one sentence）+ observable success criteria + anti-scope + current-phase focus
- Project scale: small (R0/R1 only, no OpenSpec) vs medium (OpenSpec)
- Stack, build/test commands, test filter flags
- Heavy tests? (single test > 200MB RAM / external deps / e2e) — feeds Step 3

## Step 2 — Backfill artifacts (AI drafts → human confirms line by line → commit)

Draft each from the toolkit template + brainstorm results; present for human check **before** commit:

1. `NORTH_STAR.md` — Review Log seed row dated today (it anchors value-review cadence).
2. `CLAUDE.md` — Stack & Conventions, Toolkit line (clone path), test filter flags.
3. Medium projects: `npx @fission-ai/openspec@latest init` → then ARCHITECTURE.md + backlog.md from the brainstorm (structure: WORKFLOW.md 第 3 部分).

No `<placeholder>` survives this step — an unfillable slot means Step 1 isn't done; go back.

v3 migration: keep existing `openspec/` and hooks untouched; draft NORTH_STAR.md from existing ARCHITECTURE/backlog/README; replace project CLAUDE.md from template (carry the Stack section); delete PROTOCOL.md and any in-project WORKFLOW.md copy.

## Step 3 — Hooks (only now — the stack is known)

Sources: WORKFLOW.md 附录 G 完整脚本源码 in the toolkit clone. Deploy to `.claude/scripts/` + register in `.claude/settings.json`.

- **MERGE into existing settings.json — never overwrite.** Other tools (plugins, user config) register hooks there too; read it first, add entries, re-validate JSON.
- Base set (stack-independent): `block-replaced-skills`, `block-superpowers-specs-dir`, `warn-apply-phase`, `warn-destructive-git`.
- `warn-route-before-opsx.ps1` (Tier 2, matcher Skill) — source below. Verify the installed OpenSpec version's command names first and adjust the regex.
- `warn-toolchain-stale.ps1` (SessionStart) — source below.
- Heavy-test hook: run 附录 G's Day-1 decision path (3 questions — answerable now because Step 1 named the test commands). Strategy D → fill the template's three blanks and deploy. "No heavy tests yet" is a valid answer; re-run this step when that changes.
- Verify every deployed script with 附录 G's echo test cases; paste the outputs. A hook that was never echo-tested is not deployed.

```powershell
# warn-route-before-opsx.ps1 — Tier 2 soft warning (PreToolUse, matcher: Skill)
$json = [Console]::In.ReadToEnd() | ConvertFrom-Json
if ($json.tool_input.skill -match '^opsx:(propose|new)') {
  Write-Output "REMINDER: $($json.tool_input.skill) requires a Route Declaration block posted earlier this session (change-loop Step 1: Route/Explored/Mode/Next). None exists -> stop, invoke change-loop first."
}
exit 0
```

```powershell
# warn-toolchain-stale.ps1 — SessionStart, always exit 0
$f = ".claude/last-toolchain-refresh"
if (-not (Test-Path $f)) { Write-Output "No $f - run toolchain-refresh once to baseline."; exit 0 }
$days = ((Get-Date) - (Get-Item $f).LastWriteTime).Days
if ($days -gt 30) { Write-Output "toolchain-refresh is $days days stale - run it between changes." }
exit 0
```

## Step 4 — Opus injection (only if Opus sessions are planned)

A model-aware wrapper shadows `claude` itself — a separate alias would be bypassed the moment the user launches plain `claude` with a settings-default Opus model (2026-07-07 首测追问 #Q2). It resolves the session model by precedence `--model` arg → `ANTHROPIC_MODEL` env → `settings.local.json` → project → global `settings.json`, and injects only on an Opus match.

Ask the human one question first: **"解析不到模型时，默认按 Opus 处理吗？"**（订阅默认模型不落 settings 文件时 wrapper 读不到）→ fills `$assumeOpusDefault`.

Append to PowerShell `$PROFILE` (skip if `function claude` already present):

```powershell
function claude {
  $exe = Get-Command claude -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $exe) { Write-Error "claude executable not found in PATH"; return }
  $assumeOpusDefault = $true   # bootstrap 按用户回答填
  $model = $null
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ($args[$i] -eq '--model' -and $i + 1 -lt $args.Count) { $model = $args[$i + 1] }
  }
  if (-not $model) { $model = $env:ANTHROPIC_MODEL }
  if (-not $model) {
    foreach ($f in ".claude\settings.local.json", ".claude\settings.json", "$HOME\.claude\settings.json") {
      if (Test-Path $f) {
        try { $m = (Get-Content $f -Raw | ConvertFrom-Json).model } catch { $m = $null }
        if ($m) { $model = $m; break }
      }
    }
  }
  if (($model -match 'opus') -or (-not $model -and $assumeOpusDefault)) {
    $toolkit = (Get-Content "$HOME\.claude\my-work-skill.toolkit-path" -Raw).Trim()
    & $exe.Source --append-system-prompt (Get-Content (Join-Path $toolkit 'OPUS-SYSTEM.md') -Raw) @args
  } else {
    & $exe.Source @args
  }
}
```

Verify after install: dot-source the profile, run once with `--model opus` and once without, confirm the injection decision both ways (the 2026-07-07 test harness: 5 cases in GUIDE §5).

Known gaps, tell the human: a mid-session `/model` switch cannot be caught by any launcher — switching to Opus means starting a fresh session (consistent with short-session discipline anyway); desktop app / IDE launches bypass `$PROFILE` → use the output-style fallback there (GUIDE.md §5). Do not make manual injection the plan; it was field-proven forgotten (首测 #7).

## Step 5 — Close

1. Run `toolchain-refresh` (bootstrap is one of its named triggers; its first job is verifying the OpenSpec command surface).
2. Commit artifacts + config (English message; no push).
3. End by stating: **bootstrap ends here — the first change starts with the change-loop Route Declaration, not with propose.** Then stop; picking the first backlog item is the next turn's work, routed through change-loop.

## Common mistakes

- **Filling NORTH_STAR/CLAUDE.md by hand before the brainstorm.** Backwards — slots stay empty or get invented. Brainstorm produces the answers; AI backfills; human checks.
- **Overwriting settings.json.** Merge. An overwrite silently kills other tools' hooks.
- **Deploying the heavy-test hook before the stack is known** — its three blanks are unanswerable pre-立项; equally wrong: skipping the Day-1 decision path entirely.
- **Skipping the echo tests.** A silently dead hook is worse than no hook — you believe the enforcement layer exists.
- **Treating bootstrap completion as license to propose.** The first change routes through change-loop like every other change.
