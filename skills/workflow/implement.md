---
name: workflow-implement
description: Implement one feature at a time into the approved skeleton, with tests. Logic in hooks, rendering in components.
tags: [workflow, react]
stability: experimental
---

# Workflow — Implement

## When to use
After Skeleton is approved. One feature (or one screen slice) at a time.

## Checklist
- [ ] Re-read the Design's state placement table for this feature
- [ ] Implement hooks first (logic), with tests (`skills/react/hooks-discipline.md`)
- [ ] Implement components second (rendering), against the working hooks
- [ ] Wire server data through the query layer only (`skills/react/state-placement.md`)
- [ ] Cover the named UI states: loading / empty / error
- [ ] Type-check, lint, and tests pass locally

## Rules

- **One feature per implement cycle.** Finishing two features in one pass skips a checkpoint.
- Logic that grows past ~15 lines inside a component moves to a hook or pure function.
- No new state homes are invented here — a state not in the Design table goes back to Design (or gets a one-line amendment approved by the user).
- Match the file layout the Skeleton created; do not restructure while implementing.

## Verification

- Run the test suite and record commands + results.
- Verify the Hard Rules in `AGENTS.md` against changed files (file length, one export, no `any`, effects discipline).
- Spot-check `skills/antipatterns/` symptoms on the diff.

## Next step
After user approval -> next feature, or `workflow-test` for cross-feature verification
