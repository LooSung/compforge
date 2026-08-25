---
name: workflow-test
description: Verify frontend behavior with hook tests and DOM component tests. Do not default to E2E.
tags: [workflow, react, testing]
stability: stable
---

# Workflow — Test

## When to use
During Implement (hooks, then components) and as a standalone pass for
regression coverage or TDD. Not a Playwright / browser-suite stage.

## Default surface

Frontend tests prove **logic** and **that call results land in the DOM**.
They are not backend API contract tests. Real server wiring is confirmed by
connecting the app and using it.

| Level | Target | Tool | What to assert |
|---|---|---|---|
| Unit | pure functions, custom hooks | Vitest (+ `renderHook`) | logic, edge cases, state transitions |
| Component | one screen or component with its hooks | Vitest + Testing Library | loading / empty / error / data in the DOM — roles, text, interactions |

Do not add a third automated layer by default.

## Connected check (manual)

CORS, cookies, auth, and live API shape are verified by running the app
against the real backend. Record that you did it when the change touches
server data. This is not an E2E suite and does not require Playwright.

## Checklist
- [ ] Every hook with branching logic has unit tests
- [ ] Every screen's loading / empty / error states are asserted at component level
- [ ] Component tests assert visible values after the call, not hook internals
- [ ] Component tests query by role/text, not test-id, unless there is no accessible handle
- [ ] Mock at the network boundary (MSW or fetch mock), not inside hooks
- [ ] Record commands and results; failing tests are reported, never hidden

## Prohibited
- **No snapshot-only coverage** — a snapshot asserts nothing about behavior.
- **No testing implementation details** — internal state names, call counts of private functions.
- **No skipped failing tests** without a written reason and risk.
- **No E2E by default** — do not install Playwright, start a browser suite, or
  create E2E infrastructure unless the user explicitly asks for it.
- **Do not change production behavior** to make tests pass without a separate
  Craft or Refactor approval.

## Bug fixes
Write the reproducing failing test first (`component-discipline` #6), then the smallest fix.
