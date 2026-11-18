---
name: workflow-test
description: Verify frontend behavior with hook tests and DOM component tests. Do not default to E2E.
tags: [workflow, react, testing]
stability: stable
---

# Workflow — Test

Contents: When to use · Authorization · Level selection · Scope block · Default surface · Connected check · Checklist · Reporting · Prohibited · Bug fixes

## When to use
During Implement (hooks, then components) and as a standalone pass for
regression coverage or TDD. Not a Playwright / browser-suite stage.
`gates.md` supplies startup, plan input, verification, and the completion report.

## Authorization

| Request | Write permission |
|---|---|
| Run, check, or report existing tests | none |
| Write or strengthen tests | test code and existing test configuration |
| Add test infrastructure (MSW setup, a new runner, E2E) | only after explicit approval |
| Fix production behavior | none; stop and propose a separate Craft job |

## Level selection

1. Inspect existing tests, test configuration, setup files, and naming.
2. If the request names `unit` or `component`, use that level.
3. Otherwise pick the smallest level that proves the behavior: a hook or pure
   function gets a unit test; a named UI state or interaction gets a component
   test.
4. E2E requires explicit user wording; otherwise report it only as a gap.
5. When earlier work in this run already recorded tests, read that record and
   target only what it left uncovered.

## Scope block

Before writing or running tests, report:

```markdown
Test target:
Level: auto | unit | component
Write permission: none | tests | approved test infrastructure
Evidence: <existing test/config paths or missing context>
```

## Default surface

Frontend tests prove **logic** and **that call results land in the DOM**.
They are not backend API contract tests. Real server wiring is confirmed by
connecting the app and using it.

| Level | Target | Tool | What to assert |
|---|---|---|---|
| Unit | pure functions, custom hooks | Vitest (+ `renderHook`) | logic, edge cases, state transitions |
| Component | one screen or component with its hooks | Vitest + Testing Library | loading / empty / error / data in the DOM — roles, text, interactions |

Do not add a third automated layer by default.

## Connected check

CORS, cookies, auth, and live API shape are verified by running the app
against the real backend. Record that you did it when the change touches
server data. This is not an E2E suite and does not require Playwright.

### Live run

Launching the app is the most expensive step in this pack, so it is opt-in.
Run it only when the user asks in this request, or the target `AGENTS.md` has
`Compforge live run: on`. Otherwise do not launch anything: report
`Live run: not run` and name in one line what to check by hand.

When it is on and the harness can launch and drive the app, use it for the connected check and
for any change a person can see. In Claude Code, `/verify` confirms that one
change does what it should; `/run` drives a scenario, which suits the Refactor
before-and-after below. Craft and Refactor call this section; it is the one
place the rules live.

`/verify` may save its launch recipe to `.claude/skills/verify/SKILL.md` in the
target project. That is a project file: report it under Scope drift and leave
committing it to the user.

- Start the app with the project's existing command. Never install a browser
  driver, Playwright, or any dependency, and never create E2E files.
- Drive only what changed: its named states (loading, empty, error, data) and
  the interaction the change adds.
- Record the command, what you observed (screenshot or visible text), and the
  result. "It started" is not evidence.
- A run never replaces the unit and component tests above. It shows the wiring
  they cannot.
- For Refactor, drive the same scenario before the first move and after the
  last. The observed result must be identical.
- Stop every process you started.
- No such skill, or the app cannot start (missing env, backend down): check by
  hand, or report it as not checked with the reason.

## Checklist
- [ ] Every hook with branching logic has unit tests
- [ ] Every screen's loading / empty / error states are asserted at component level
- [ ] Component tests assert visible values after the call, not hook internals
- [ ] Component tests query by role/text, not test-id, unless there is no accessible handle
- [ ] Mock at the network boundary (MSW or fetch mock), not inside hooks
- [ ] Record commands and results; failing tests are reported, never hidden

## Reporting

Report scope, commands, pass/fail counts, skipped checks, and remaining risks in
the `gates.md` completion report. When a test fails, decide whether the cause is
the test, the setup, or production behavior. Fix only within the authorized
write permission; otherwise report the evidence and stop.

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
