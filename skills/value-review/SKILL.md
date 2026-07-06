---
name: value-review
description: Use when a long-running project shows drift — consecutive changes with no user-visible value, repeated R-revisions on the same decision, backlog priorities overturned, the main spec reads as confusing — or on cadence (every 5 archived changes or 4 weeks), or when the user asks for a mid-project review / 中期回顾.
---

# Value Review

## Overview

Re-anchor the project against its North Star and re-judge architecture and backlog against accumulated reality. The output is decisions **for the human to make** — never auto-applied changes.

## Triggers (any one)

| Signal | Threshold |
|---|---|
| Self-indulgence streak | 3 consecutive archived changes with no observable behavior change — judged retrospectively, regardless of what their Outcome claimed |
| Decision churn | Same decision hit by ≥2 R-revisions, or 2 changes conflict on one capability |
| Backlog overturned | Phase ordering or priorities reshuffled since last review |
| Cadence fallback | 5 archives or 4 weeks since last review — checked automatically at every change-loop close (Step 4), not from memory |
| Human intuition | "看不懂主 spec" / uneasy about direction |

## Procedure

1. **Check last review's promises first.** Open the previous review (NORTH_STAR.md Review Log → retro file). Every enabling change that promised to unblock user value: did that value land? Unfulfilled promises lead the findings. First-ever review (only the project-start seed row exists) → skip this step.
2. **North Star check.** Read NORTH_STAR.md. Still true? If not → stop; re-anchoring is a human decision and nothing else matters until it's made.
3. **Value audit.** For each change since last review, one line: *what did the user get?* Classify per NORTH_STAR.md taxonomy: user-value / enabling / self-indulgence.
4. **Decision audit.** For each Decision in ARCHITECTURE.md and the living spec's `Architectural Decisions`: does its 失效前提 (invalidation condition) now hold? List Superseded candidates with the evidence that triggered them.
5. **Backlog re-scoring.** Re-rank remaining items against North Star success criteria. Propose kills, merges, additions. Killed items are struck through with a reason — never deleted.
6. **Write and stop.** Produce `openspec/retros/<date>-value-review.md` (or `retros/` for non-OpenSpec projects): findings + concrete proposals, each labeled `[keep]` / `[change]` / `[kill]` / `[decide]`. Append one row to NORTH_STAR.md Review Log. Present to the human. Approved changes flow through R-revision / ARCHITECTURE update / backlog edit — after approval, not before.

## Classification rule (anti-自嗨)

A change is **self-indulgent** when its outcome is expressible only in implementation vocabulary (refactor, unify, abstraction, coverage, elegance) AND it names no user-visible change it unblocks within ~2 changes. Tech-debt work is legitimate *enabling* work when the unblocked thing is named, scheduled, and later verified to have landed (step 1).

## Common mistakes

- **Auto-applying conclusions.** Architecture and value direction are semantic-level decisions — human gate, always.
- **Reviewing throughput instead of outcomes.** "12 changes archived" is not a finding. What did the user get?
- **Waving every enabling change through.** The test is not "does it enable something in theory" but "did the promised value land" — that's why step 1 runs first.
- **Treating cadence as the only trigger.** The signal table exists because drift usually announces itself before the calendar does.
