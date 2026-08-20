---
name: workflow-delivery-plan
description: Consolidate screens, state homes, implementation order, tests, review, and release risks into one execution plan.
tags: [workflow, planning, delivery]
stability: stable
---

# Workflow — Delivery Plan

## When to use
After Discovery/Design, or when requirements have arrived but the scope and
contract are too unclear to implement directly.
Merge the existing design notes into **one execution plan**.

## Purpose
- Make clear what to build.
- Make clear what not to build.
- Agree on the order to implement and verify.
- Surface the risks to check before review, commit, merge, and release.

## Checklist
- [ ] Write a Problem 1-Pager: Background, Problem, Goal, Non-goals, Constraints
- [ ] Define screens/flows and success criteria
- [ ] If there is an external contract (API/route/URL), define inputs/outputs/errors
- [ ] Separate page composition, feature folders, hooks, and the query layer
- [ ] Break the implementation order into small steps
- [ ] Test strategy: unit (hooks/pure), component, E2E checkpoints
- [ ] Review checklist: file size, one export, state homes, accessibility
- [ ] Draft commit/push/MR/release notes
- [ ] Rollback or revert strategy

## Output

Save to `docs/delivery-plan.md` or `docs/<feature>/delivery-plan.md`:

```markdown
# <Feature> — Delivery Plan

## Problem 1-Pager
- Background:
- Problem:
- Goal:
- Non-goals:
- Constraints:

## Scope
- In:
- Out:

## Contract
- Screens / routes:
- Queries / mutations:
- URL state:
- Errors / empty / loading:

## Responsibility Map
| Concern | Page | Feature | Hook | Query |
|---|---|---|---|---|
|  |  |  |  |  |

## Implementation Order
1. Types / contracts
2. Query layer and hooks (with tests)
3. Presentational components
4. Page composition
5. Accessibility and named UI states
6. Component / E2E checks

## Test Plan
- Unit:
- Component:
- E2E:

## Review / Merge / Release
- Review checklist:
- Commit summary:
- MR notes:
- Deploy risks:
- Rollback:

## Open Questions
-
```

## Prohibited
- **Do not write it like an implementation result report** — organize what is to be done.
- **Do not write an unconfirmed contract as if confirmed** — if unknown, leave it in Open Questions.
- **Do not force company/framework-specific rules** — follow only the rules in the project `AGENTS.md`.
- **Do not list long file paths** — responsibility boundaries and order matter more.

## Next step
After user approval -> `workflow-skeleton`, or a small `workflow-implement` directly.
