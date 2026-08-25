---
name: workflow-refactor
description: Behavior-preserving cleanup of existing frontend code. Never mixed with feature changes.
tags: [workflow, react, refactoring]
stability: stable
---

# Workflow — Refactor

## When to use
Existing or imported code needs structural cleanup **without behavior changes**:
god components, logic buried in JSX, misplaced state, type-only folder structure.

Never combine with a feature or bug fix. If a feature is also needed, do two passes.
Not a required step of the default delivery flow — a **supporting workflow**.
An explicit Refactor command must not be reclassified as feature work.

## Job contract (before code)

Fill once. If a functional change is required, stop and split it into a Craft job.

```markdown
In scope:
Out of scope:
Behavior to preserve:
One decision:
```

## Core principles
- Do not mix functional changes with refactoring.
- First pin the current behavior with tests or reproduction scenarios.
- Change in small steps and verify often.
- Preserve public behavior, routes, and named UI states.
- If something must change, it is the subject of a new delivery plan.

## Brownfield order

A new screen is designed state-first. An **existing** UI is refactored
**surface-first**, because every caller already points at the hooks — moving
them first breaks everything at once, and you can no longer tell a mistake
from a ripple.

1. **Surface** — pages, routes, presentational components. Callers are explicit
   here, and the contract you must preserve becomes visible before you move anything.
2. **Feature / hooks** — extract logic and split components, following the surface you fixed.
3. **Shared and query layer** — last, once the callers above are stable.

**Move first, merge later.** When two implementations look alike, relocate them
side by side **unchanged**. Consolidating during a move mixes two decisions.
Merging is a separate plan.

## One branch, one decision

A refactor branch carries exactly one boundary decision. Do not widen scope
without an explicit instruction.

- A second architecture change inside one branch is how these efforts collapse:
  the diff outgrows review and no commit is left as a safe base.
- Finish a decision before the next: verify -> commit -> merge up -> branch again.
- If a policy question is still open (who owns this state, do these two merge),
  **stop and ask**. Code stacked on an undecided policy is discarded with it.

## Abandoning a branch

Resetting a branch does not remove what it left behind. After the reset, clean
the residue — otherwise the next session inherits a half-real repository.

- **Orphan files** — on meeting an unexplained file, run `git log --all -- <path>`
  before deciding whether it belongs.
- **Ignored paths** — work docs and generated artifacts survive any reset.
  Reconcile or archive them.
- **Dead links** — fix or remove anchors pointing into the discarded work.
- Write down **why** the attempt was abandoned before deleting it.

## Checklist
- [ ] Name the target smell (use `skills/antipatterns/` vocabulary)
- [ ] Name the one decision this branch carries
- [ ] Confirm test coverage exists; add characterization tests if not
- [ ] Work surface -> feature/hooks -> shared/query (existing code)
- [ ] Plan the smallest sequence of safe moves (one smell per pass)
- [ ] Execute move by move; type-check and tests green after each
- [ ] Diff review: behavior identical, structure improved, nothing else touched

## Common moves

| Smell | Move |
|---|---|
| Logic in JSX / event handlers | Extract custom hook or pure function |
| God component | Split by responsibility; container keeps wiring, children render |
| Server data in `useState`+`useEffect` | Move to query layer |
| Derived state stored | Delete the state; compute at render |
| Props drilled 3+ levels | Recompose with `children`, or context if truly shared |
| App-wide type folders | Regroup by feature; restore import boundaries per stack |

## Prohibited
- **No second decision in one branch** — widen only on an explicit instruction
- **No merging two implementations during a move** — relocate, then merge separately
- **No building on an undecided policy** — stop and ask
- **No behavior changes** — visible output and interactions stay identical
- **No new features** smuggled in
- **No "while I'm here" edits** outside the named smell (`component-discipline` #11)

## Verification
- Tests green before and after; no assertions weakened.
- Hard Rules in `skills/principles/hard-rules.md` improved or unchanged — never regressed.

## Next step
After verification -> review, commit, push. If a functional change is needed, split it into a separate Craft job.
