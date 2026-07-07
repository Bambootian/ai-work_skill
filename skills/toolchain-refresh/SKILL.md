---
name: toolchain-refresh
description: Use on a schedule, at project bootstrap, or when tooling misbehaves — plugin commands that used to work now fail, expected skills missing from the skill list, workflow docs referencing commands that no longer exist, or upstream tools announcing breaking changes.
---

# Toolchain Refresh

## Overview

Plugins, skills, and CLIs evolve monthly; a workflow pinned to stale tools rots silently — e.g. OpenSpec's 2026-06 v1.x rework changed its action model underneath the same slash commands. Refresh = inventory → update → break-check → reconcile docs → report.

## Procedure

0. **Mid-change guard.** Check for in-progress work first: `openspec list`; any `tasks.md` with unchecked boxes; any `spec-lite.md` or root `SPEC.md` present (R1 changes have no tasks.md); a dirty working tree (`git status --porcelain`). If found: run inventory + report only (steps 1 and 5) and defer all updates — updating tools mid-loop invalidates the loop contract. Scheduled runs hit this guard too; that is by design, not a failure.
1. **Inventory.** `/plugin list`; project CLI versions (e.g. `npx openspec --version`); list `.claude/skills/` and hooks registered in `.claude/settings.json`. Record versions.
2. **Update.** `/plugin update <name>` per plugin (or marketplace update); `npx @fission-ai/openspec@latest update` for OpenSpec projects. **The toolkit's own skills too**: `git -C <toolkit clone> pull` (path: `~/.claude/my-work-skill.toolkit-path`), then re-copy changed `skills/*` into `~/.claude/skills/` — deployed skills are copies and never self-update. Record versions after.
3. **Break-check.** For each updated tool:
   - run its cheapest real command (`npx openspec validate`, a skill invocation) and confirm it behaves;
   - re-run the hook verification cases (WORKFLOW.md 附录 G in the my-work-skill toolkit repo, the 4-case echo test) — hooks silently dying is the worst failure mode because they are the enforcement layer;
   - scan changelog / release notes for behavior changes affecting the workflow.
4. **Reconcile docs first（约束先行）.** If behavior changed, update workflow docs and skills BEFORE relying on the new behavior. Docs and practice must not diverge; templates that embed commands must be re-verified.
5. **Report.** Versions changed, breaks found, doc edits made, items needing a human decision. Nothing changed → say so in one line and stop. Update the timestamp in `.claude/last-toolchain-refresh`.

## Automation (prefer harness over memory)

- Register a scheduled routine that runs this skill weekly (`/schedule` cloud routine, or OS scheduler invoking `claude -p "/toolchain-refresh"`).
- Fallback: a SessionStart hook that warns when `.claude/last-toolchain-refresh` is older than 30 days — deployed by default at bootstrap (`project-bootstrap` Step 3, `warn-toolchain-stale.ps1`).
- Headless limitation: a scheduled `claude -p` run cannot drive interactive `/plugin` commands — it does inventory + break-check + report only, and flags pending updates for the next interactive session.

Calendar reminders and "季度手动更新" notes in docs are memory-based constraints — they are exactly what this skill exists to replace.

## Common mistakes

- **Updating mid-change.** Refresh between changes, never during apply — a mid-loop tool change invalidates the loop contract and makes failures unattributable.
- **Trusting release notes without running commands.** Behavior drift is often undocumented; only the break-check counts as verification.
- **Updating tools but not templates.** Command tables in docs (e.g. WORKFLOW.md 附录 A) must be re-verified against the new versions, or they become hallucination seeds.
