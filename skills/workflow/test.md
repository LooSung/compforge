---
name: workflow-test
description: Verify frontend behavior at the right level - pure functions and hooks first, then components, then E2E flows.
tags: [workflow, react, testing]
stability: experimental
---

# Workflow — Test

## When to use
During Implement (hooks/components) and after features integrate (E2E). Also standalone for regression coverage or TDD.

## Test pyramid (frontend)

| Level | Target | Tool | What to assert |
|---|---|---|---|
| Unit | pure functions, custom hooks | Vitest (+ `renderHook`) | logic, edge cases, state transitions |
| Component | one component with its hooks | Vitest + Testing Library | what the user sees and does — roles, text, interactions |
| E2E | one user flow across screens | Playwright | the flow completes; server data round-trips |

## Checklist
- [ ] Every hook with branching logic has unit tests
- [ ] Every screen's loading / empty / error states are asserted at component level
- [ ] Component tests query by role/text, not test-id, unless there is no accessible handle
- [ ] Mock at the network boundary (MSW or fetch mock), not inside hooks
- [ ] One E2E per primary user flow — not per component
- [ ] Record commands and results; failing tests are reported, never hidden

## Prohibited
- **No snapshot-only coverage** — a snapshot asserts nothing about behavior.
- **No testing implementation details** — internal state names, call counts of private functions.
- **No skipped failing tests** without a written reason and risk.

## Bug fixes
Write the reproducing failing test first (`component-discipline` #6), then the smallest fix.
