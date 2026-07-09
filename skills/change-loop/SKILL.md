---
name: change-loop
description: Use when starting any development change — feature, bugfix, refactor, or the first change after project bootstrap / 立项 — in a project using this workflow (NORTH_STAR.md present, or CLAUDE.md mandates route declaration). Invoke BEFORE any opsx command (propose/apply), spec writing, solution brainstorming, or code; also when picking an item from backlog.md, and when resuming an in-progress change after a session break or context compaction.
---

# Change Loop

## Overview

Every change runs as a routed, budgeted loop with three explicit exit states. The human reviews evidence at gates; the AI controls everything between gates. The loop body is deliberately simple: **one task per iteration, start green, end green, committed.**

**Violating the letter of a gate is violating its spirit.**

## Step 1 — Route (always, before anything else)

Judge by novelty × reversibility × blast radius. When torn between two routes, take the higher. Upgrading mid-change is normal — state it. Silent downgrading is forbidden.

**Step 1's output is this block — all four lines, posted before any spec, opsx command, or code. A bare route statement without the block is not a route** (a "R2 standard" one-liner is two skipped judgments: blast radius unread, spec mode unexamined):

```
Route: R<0-3> <name> — <one-line justification: novelty × reversibility × blast radius>
Explored: <files/patterns read before declaring> | none — request alone suffices because <reason>
Mode: A | B(predicate 1|2|3) + ≤3-sentence restatement | n/a (R0)
Next: <first process step this route prescribes — brainstorm / SPEC-lite / opsx propose / test>
```

**Look before you route.** Routing judges blast radius, and blast radius lives in the code. If the route isn't obvious from the request alone, run a read-only explore first (search / read, no writes), then declare. Every declared route is provisional until first contact with the code. And before writing any spec (SPEC-lite or propose), explore what you'll touch — files, existing patterns, contracts — and state what you found. Assumptions about existing code are verified by reading it, never recalled.

| Route | Criteria (all must hold) | Process | Gate review |
|---|---|---|---|
| **R0 direct** | Reversible in one commit; no spec/architecture/data-contract impact; ≤ ~1 hour | Test → code → commit | Inline self-check |
| **R1 light** | Intent fits 2–3 sentences; single capability; no new architecture decisions or external deps | Mode judgment → (A: brainstorm) → SPEC-lite (Goal / Non-goals / Scenarios / Verify) → loop | 1 independent reviewer subagent at close |
| **R2 standard** | New capability, crosses modules, or new external dependency | Mode judgment → (A: brainstorm) → full propose (proposal / design / tasks / spec) → loop | 2 subagents (spec-compliance + code-quality) at close + human spec approval up front |
| **R3 architectural** | Touches ARCHITECTURE decisions, data contracts, or NORTH_STAR scope | Brainstorm first (always Mode A) → ARCHITECTURE update → then R2 process | 3 lenses (spec, architecture, skeptic) at close + human decides direction up front |

**Spec-formation mode (R1 and above, after routing).** Default is **Mode A** — exploratory brainstorm (superpowers:brainstorming) before spec. Fluent wording in the request is NOT evidence of examined intent; do not judge clarity from text. Go **Mode B** (checklist review, no brainstorm) only when an observable predicate admits it:

1. **Evidence-born**: the change originates from a concrete artifact in hand — failing verify/dry-run output, bug repro, R-revision follow-up, review finding. The evidence seeds the spec.
2. **Pattern extension**: extends an archived capability along an existing living-spec pattern; no new external deps, no new architecture decisions.
3. **Explicit call**: the user says "Mode B" or hands over a written plan.

Before Mode B proceeds, restate intent / boundary / key decisions in ≤3 sentences and show them — R2+ confirms at the spec gate; R1 proceeds unless corrected. Cannot fill the restatement → that IS the Mode A signal.

**Mode binds the declaration's `Next` line.** Mode A → `Next` is superpowers:brainstorming; the spec artifact (SPEC-lite / propose) is written from its output, never before it. Mode B → `Next` is the spec artifact itself, after the restatement is shown. `Mode: A` with `Next: opsx propose` is self-contradictory — stop and fix the block. Route and Mode are orthogonal judgments: Route picks the spec's form and gates; Mode decides whether brainstorm precedes it. **R2 does not lean Mode B — the opposite**: route criteria are not whitelist predicates, and an R2 born from a new external dependency fails predicate 2 by definition. Most R2s are Mode A.

**Mode B tripwire (mandatory).** During the checklist, ≥2 answers land "no / uncertain" on boundaries, dependencies, or implicit constraints — or any semantic ambiguity surfaces → stop, state the switch, go Mode A. A wrong Mode B costs a rework cycle; a wrong Mode A costs minutes. When torn, Mode A.

**Pre-spec explore declaration (R1 and above — WORKFLOW.md §5.3).** After Mode A's brainstorm (or Mode B's restatement), immediately before writing the spec artifact (SPEC-lite / opsx propose), post one line:

```
Explore: needed — <reason> → opsx explore before the spec | not needed — <reason>
```

Three triggers, any one → needed: existing code must be understood before specifying; more than one viable technical approach is still unresolved; a new external dependency surfaced. The route-time `Explored:` line does not substitute — it recorded what was read *before* routing; this line certifies nothing new needs reading *after* the brainstorm's output landed. Non-OpenSpec projects: an equivalent read-only investigation with findings stated.

**R0 discipline.** R0 has no contract, but it still states — in one line, before starting — its verify command + expected result, and shows that output before committing. An R0 that fails its first attempt, exceeds ~1 hour, or turns out to touch spec/architecture/data contracts is not R0: re-route to whatever the criteria table demands (spec impact → R1/R2; architecture or data contracts → R3) and write the contract (failure notes live there). Half-done work at re-route time: tree green → commit it as the new route's first task; tree red → reset to the anchor first.

## Step 2 — Loop contract (R1 and above)

Before implementation, write into the change's `tasks.md` (or SPEC-lite) header:

```markdown
## Loop Contract
- Outcome: <one sentence in user-visible vocabulary — what does the user get?>
- Verify: <NAMED commands + expected result, e.g. `dotnet test --filter Xyz` → 0 failed,
  `app.exe --demo scenario3` → produces report. "Tests pass" without commands is invalid.>
- Budget: <max days> total; per task max 5 iterations
- Exit states: DONE (all Verify green + Outcome landed)
             | BLOCKED (blockers + attempts appended below; escalate to human)
             | SPLIT (budget exceeded or task found composite → propose split)
```

If Outcome can only be written in implementation vocabulary (refactor / unify / abstract / coverage), this is enabling work: name the user-visible change it unblocks and when that lands (≤2 changes). Cannot name one → take it to `value-review` before proceeding.

**Where SPEC-lite lives (R1).** One file containing Goal / Non-goals / Scenarios / Loop Contract: OpenSpec projects → `openspec/changes/<change-id>/spec-lite.md` (CLI validate applies to R2+ four-artifact changes, not R1); other projects → `SPEC.md` at repo root, moved to `docs/changes/` at close.

## Step 3 — Inner loop (autonomous)

**Iteration invariant: exactly one task per iteration; the tree is green and committed at every task boundary.**

Per task: recite in one line (contract Outcome + current task — keeps the global goal in recent attention) → read scenario → failing test if there is runtime behavior → minimal code → green → self-review the diff (the graded reviewer panel from the route table runs at gates, not per task) → commit → next task. Report progress; do not ask permission to continue between tasks.

**Rollback (green anchor).** Commit only on green; the last green commit is the rollback anchor. In a fresh repo, create the anchor first: commit the scaffold as soon as the test harness runs green. If an iteration ends with a broken tree: `git reset --hard` to the anchor → append a failure note (task id + tried / observed / hypothesis) to the contract → **commit the note immediately** (a docs-only commit is green by construction; this is what keeps failure notes alive across future resets) → retry differently or exit BLOCKED. Fix-forward is allowed *within* an iteration, never *across* task boundaries. Never start a task from a red tree.

**Track attempts in the open.** Every failed attempt appends a failure note (task id + tried / observed / hypothesis) to the contract — not only tree-breaking ones. The task id is what keeps the per-task count recoverable when notes from several tasks interleave. The committed notes ARE the attempt counter: model memory does not survive compaction; notes do.

**Stuck predicates — any one fires → stop re-prompting harder:**
- An iteration produced an empty diff
- The same error signature appeared in 2 consecutive iterations
- A fix-A-breaks-B-breaks-A round trip completed once

Then (also when the 5-iteration cap hits): write the 3-line failure note → superpowers:systematic-debugging. The diagnosis decides the exit: root cause = composite task → split it; anything else unresolved → exit BLOCKED. A task split that stays within the approved spec scope is autonomous — edit `tasks.md` and continue the loop. A split that would change scope, spec, or the change budget is the change-level exit state SPLIT — stop and surface it to the human. If the plan no longer matches reality (post R-revision drift), regenerate the remaining tasks from the spec — don't patch the list line by line.

**Subagents.** Dispatch with the slot template in this skill's `dispatch-prompt.md` — every REQUIRED slot filled. Every subagent prompt MUST restate: project hard rules, test-command constraints, and this change's loop contract. Subagents see none of your context. Route noisy work (full test logs, build output archaeology) through subagents to keep the loop's context clean.

**Model routing per dispatch.** Default = inherit the session model. Downgrade to a cheaper tier only when the output is mechanically verifiable (tests / diff / schema) or purely informational (exploration, inventory, log summaries) — and then paste the cheap-model operating rules block from this skill's `dispatch-prompt.md` verbatim. Never downgrade a judge: gate reviews, spec self-review, and root-cause diagnosis run at session tier or stronger. Cheap producer + strong-or-mechanical verifier is safe; strong producer + cheap verifier is the worst combination.

**Stop the loop only when:** a gate is reached; a stuck predicate or exit state fires; or a **semantic** ambiguity appears (spec meaning, requirement boundary) — implementation ambiguity is yours: pick the reasonable option and note it.

## Step 4 — Close (evidence gate)

Assemble and present the evidence bundle:
- Each Verify command with real output pasted (not summarized, not "should pass")
- Outcome check: did the user-visible outcome land? One line.
- Exit state declared: DONE / BLOCKED / SPLIT. Anything skipped or deferred, stated plainly — including the named WORKFLOW.md phases (§5.6 Verify, §5.7 Polish). Those are judgment calls, not per-change mandates: judge by task and state, run them directly when warranted (no asking), and when skipped the archive report states which and why (e.g. "5.6.1 absorbed by the gate reviewer's requirement-coverage table", "no source code → code-simplifier n/a").

Then archive per project convention (OpenSpec seed/merge steps: WORKFLOW.md §5.8 in the my-work-skill toolkit repo — clone path is on the project CLAUDE.md `Toolkit` line; the toolkit is not copied into projects). After archiving, check NORTH_STAR.md's Review Log: ≥5 archives or ≥4 weeks since the last value review → trigger `value-review` now. This check IS the cadence enforcement — don't rely on remembering.

## Session boundaries (land the plane)

Land the plane at task-group ends, at any gate, and immediately when the harness warns about context or compaction: update `tasks.md` checkboxes + contract state, then write a 2–3 line next-session brief (current task, next action, open question) into the change's `CLAUDE.md`. Prefer a fresh session per task group over marathon sessions — effective context degrades well before the window fills (~40% working set); files carry the state, not the conversation.

Resuming: `git status` first — uncommitted changes mean an interrupted iteration: finish that single iteration if the trail (failure notes + tasks.md) makes the state clear, otherwise reset to the anchor. Then read Loop Contract + `tasks.md` + change `CLAUDE.md`. Report state in ≤2 lines. Continue the loop — do not ask "what should I do next" unless at a gate or blocked.

## Rationalizations

| Excuse | Reality |
|---|---|
| "This is tiny, skip routing" | Routing IS the 10-second step that decides what to skip. State R0 and go. |
| "Brainstorm/立项 just finished — propose is obviously next" | Bootstrap ends OUTSIDE the loop. The first change opens with the Route Declaration block like every other; propose is a possible `Next:`, never the starting point. |
| "I stated R2, routing is done" | The declaration is four lines. A route without Explored and Mode is two skipped judgments, and skipped judgments are exactly what this step exists to force. |
| "The request is well-written, so intent is clear — Mode B" | Fluent wording ≠ examined intent. Mode B needs a named whitelist predicate, not a vibe. |
| "R2's process is full propose, so run propose now" | The Process column starts at Mode judgment. Route picks the artifact; Mode decides whether brainstorm comes first — and most R2s are Mode A. |
| "Tests pass, so it's done" | The contract names the Verify commands. Run those, paste output. |
| "I'll fix the broken tree in the next task" | Red tree at a boundary = reset to anchor. Fix-forward across tasks is how drift compounds. |
| "One more retry with a better prompt" | A stuck predicate fired. Harder re-prompting is the same approach; the contract says debug or BLOCKED. |
| "Two small tasks in one go is efficient" | One task per iteration is the invariant. Batching is how oscillation starts. |
| "The subagent will know the rules from context" | It won't. Restate constraints in the prompt, every time. |
| "I'll upgrade the route later if needed" | Later = after an un-gated architecture change already happened. Doubt → higher route now. |

## Red flags — STOP

- Writing code before stating a route
- Running an opsx command (propose/apply) with no Route Declaration block earlier in the session
- A `Route:` line not followed by `Explored:` / `Mode:` / `Next:` lines
- A declaration whose Mode and Next lines contradict (`Mode: A` + `Next: propose/SPEC-lite`)
- Entering Mode B without naming which whitelist predicate admitted it
- A spec artifact (SPEC-lite / propose) written with no `Explore:` declaration since the brainstorm/restatement
- A completion claim with no command output behind it
- A red tree at a task boundary, or starting a task from a red tree
- The same error message twice in a row and you're still tweaking the same idea
- An Outcome written only in implementation vocabulary
- Changing spec or architecture on route R0/R1 without upgrading the route
