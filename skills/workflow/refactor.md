---
name: workflow-refactor
description: Behavior-preserving cleanup of existing frontend code. Never mixed with feature changes.
tags: [workflow, react, refactoring]
stability: experimental
---

# Workflow — Refactor

## When to use
Existing or imported code needs structural cleanup **without behavior changes**:
god components, logic buried in JSX, misplaced state, type-only folder structure.

Never combine with a feature or bug fix. If a feature is also needed, do two passes.

## Checklist
- [ ] Name the target smell (use `skills/antipatterns/` vocabulary)
- [ ] Confirm test coverage exists for current behavior; add characterization tests if not
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
- **No behavior changes** — visible output and interactions stay identical.
- **No new features** smuggled in.
- **No "while I'm here" edits** outside the named smell (`component-discipline` #11).

## Verification
- Tests green before and after; no assertions weakened.
- Hard Rules in `AGENTS.md` improved or unchanged — never regressed.
