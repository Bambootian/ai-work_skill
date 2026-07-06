# Project: <name>

## North Star

<one sentence: who gets what>. Full version + outcome taxonomy: `NORTH_STAR.md`.

## Stack & Conventions

<fill per project: language, build/test commands, test filter flags, style>

## Session Start Protocol

1. Read `NORTH_STAR.md`, `backlog.md` (missing → project not bootstrapped: brainstorm → ARCHITECTURE.md
   + backlog.md before any change); find any in-progress change (`openspec/changes/` or `SPEC.md`).
2. If one exists, read its Loop Contract + `tasks.md` + change `CLAUDE.md` (if present).
3. Report state in ≤2 lines, then CONTINUE the loop. Ask only when at a gate or blocked.

## Hard Rules (always)

- Route every change via the `change-loop` skill before any code; state the route (R0–R3).
- Every change names a user-visible Outcome; implementation-vocabulary-only outcomes go to `value-review`.
- No completion claims without running the named Verify commands and pasting output. "Should work" is banned.
- Commit only on green; the last green commit is the rollback anchor. A broken tree at a task
  boundary is reset to the anchor, never fixed forward into the next task.
- Tests are load-bearing: never delete or weaken a failing test to get green. Changing expected
  behavior goes through R-revision (stop, fix spec, validate, resume).
- External libraries/APIs verified to exist before use — training memory is not verification.
- No unrequested scope: no extra features, configurability, abstractions, or drive-by refactors.
- Subagent dispatch uses `dispatch-prompt` template slots; constraints restated verbatim, every time.
- Semantic ambiguity (requirement meaning, boundary, design intent) → stop and ask.
  Implementation ambiguity (detail, style) → pick the reasonable option, note it, keep moving.

## Enforcement

Hooks in `.claude/settings.json` enforce test-command discipline and destructive-op warnings
(deploy from the my-work-skill toolkit's WORKFLOW.md 附录 G). Phase procedure lives in skills: `change-loop`,
`value-review`, `toolchain-refresh` — not in this file.
