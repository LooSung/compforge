---
name: playbook-feature
description: Execution playbook for adding one behavior to an existing frontend feature under Compforge rules.
tags: [playbook, feature, react]
stability: experimental
---

# Playbook — Feature

## When to use

Use this when adding one new behavior or screen slice to an existing feature.
For a new feature area or large screen, start from Discovery.

Follow `skills/workflow/implement.md` for the detailed implementation order.
Follow `skills/workflow/craft.md` for the Component Contract format and final verification.

## Checklist

- [ ] Read the relevant page, feature folder, hook, and query. → verify: owners and call path named
- [ ] Review the existing state-placement table and tests. → verify: homes and UI states the feature must preserve listed
- [ ] Decide which hook or pure function will own the new behavior. → verify: owner is a hook/pure function, not JSX
- [ ] Minimize the scope of component and query changes. → verify: only the nodes the behavior needs
- [ ] Follow the single-feature procedure in `skills/workflow/implement.md`. → verify: one behavior + tests green
- [ ] Follow the verification and completion report in `skills/workflow/craft.md`. → verify: Scope drift is `none` (or justified)

## Prohibited

- Do not hide the new behavior in a page-level event handler.
- Do not create a generic Manager, Helper, or Util module first.
- Do not implement several features at once.
- Do not mix in unrelated refactoring.
