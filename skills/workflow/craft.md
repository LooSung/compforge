---
name: workflow-craft
description: Compforge execution orchestrator that classifies a frontend task and runs it via the smallest appropriate path.
tags: [workflow, react, typescript]
stability: stable
---

# Workflow — Craft

## Purpose

Run a frontend task via the smallest appropriate execution path.
The goal is not code volume. Add or change code only when the selected path
requires it. Components render; hooks decide; every piece of state has one home.

## Startup procedure

0. `skills/workflow/continuity.md` Resume: list `.craft/`. If previous work exists, read `next-session-prompt.md` first and **emit the Resume block before any other output** — even if the user did not mention it. Re-scope an inherited prompt to one decision; it is evidence, not a session scope. If none exists and this is an **execution task (feature/refactor/bugfix)**, create `.craft/<kind>-<slug>.md` automatically and announce it in one line. Do not create one for advisory or tiny tasks, or if `AGENTS.md` contains `Compforge continuity: off`.
1. Confirm the **work target**. For ordinary app work, the target project is the frontend repo, not the Compforge **pack** (`~/.compforge`, skill paths). If `pwd` is the pack root during app work, confirm the agent was started from the target project. If the request is to maintain Compforge itself, the pack root is the correct target.
2. When the user points to a file via `@…`, an absolute path, or a relative path, resolve it against the confirmed work target. Do not look under `{pack}/docs/…` or `~/.compforge/…` for app-project files. If missing, confirm the absolute path or project root with the user.
3. Read `skills/principles/component-discipline.md`.
4. Review the user request and the existing code.
5. Select one smallest execution path from the table below.
6. For an advisory request, only recommend a path and do not implement.
7. For an execution request, copy the checklist of the chosen skill, playbook, or workflow into your task list.
8. If you skip any step, leave a one-line reason.
9. Write the **Assumptions** block (below), then the Component Contract, before implementing UI logic.
10. Implement and test along the chosen path. Keep changes surgical (`component-discipline` #11).
11. Verify the project's stated rules (`AGENTS.md` / `skills/principles/hard-rules.md`), naming them in the report, and the results of the tests you ran.
12. Record design decisions, verification results, **Scope drift**, and remaining risks in the completion report format. **Completion gate**: if a continuity work doc exists, do not report done before updating that doc (Status/Progress/Decisions). If the unit is done but work remains, write `.craft/next-session-prompt.md` before reporting done — do not wait to be asked (`continuity` Session cut).

## Execution-path selection

| Request signal | Execution path |
|---|---|
| Design or split a single component | `skills/react/component-boundary.md` |
| Where should this state live; server/client/URL data | `skills/react/state-placement.md` |
| Extract a custom hook; effect cleanup; logic reuse | `skills/react/hooks-discipline.md` |
| Add a behavior or screen slice to an existing feature | `skills/playbooks/feature.md` |
| Fix a UI bug, wrong state, regression, or broken interaction | `skills/playbooks/bug-fix.md` |
| God component, moving responsibility, behavior-preserving cleanup | `skills/workflow/refactor.md` |
| Derived state in useEffect, fetch chains in effects | `skills/antipatterns/useeffect-abuse.md` |
| Props passed through 3+ levels | `skills/antipatterns/prop-drilling.md` |
| New feature area or large screen | the full workflow starting at `skills/workflow/discovery.md` |
| Not a frontend change (environment, tooling, docs, ops, investigation) | say so in one line; skip Assumptions and Component Contract; keep Verification and Scope drift |
| Advisory request that wants a recommendation only | recommend the smallest path and do not implement |
| Execution request but a decision is missing ("make a todo app") | fill the decision via **Ambiguity resolution** below, then select a path |

## Ambiguity resolution (before implementation)

When the intent is execution but a decisive input is empty (stack, folder architecture, state approach, styling, supported screens/edge cases), resolve it once before code — do not interrogate; propose defaults.

1. Identify the missing decision dimensions.
2. **Stack and architecture must pass the `skills/lang/frontend-stack.md` scope gate.** If unspecified, steer to TypeScript + React (Vite); for an unsupported stack (Vue, Angular, Svelte) state that Compforge does not apply (plain build only if insisted).
3. For items you can set safely, **state the default** and proceed (e.g., Vite, feature folders, CSS Modules, no router).
4. Ask only the 1–2 questions that actually change the result (architecture/scope) (e.g., "Multiple pages? -> add routing and URL state").
5. You may offer the `examples/` todo family (feature / FSD / Next) as a reference menu.
6. On resume, the Resume block's `Continue this, or a new request instead?` is that question. Do not invent a default that drops unfinished previous work.

## Assumptions (before Contract)

For any Craft task that requires implementation, fill this once before the Component Contract
(`component-discipline` #10). Keep it short. If nothing is uncertain, write `none` with a reason.

```markdown
## Assumptions

Assumptions:
Alternatives considered:
Why this path:
```

If interpretations diverge and the choice changes architecture or scope, list the
options in one sentence and ask — do not silently pick one.

## Component Contract

For any Craft task that requires implementation, fill in the form below once before writing code.
For items that do not apply, write `none` and leave a reason.

```markdown
## Component Contract

Feature:
Component Tree (new/changed nodes):
State Placement (each piece → home):
Props Crossing Boundaries:
Server Data (queries/mutations):
Test Targets (hooks/components):
```

## Verification

- Complete the checklist of the chosen playbook or workflow (each step should have a `verify:`).
- Verify the project's stated rules (`AGENTS.md` / `skills/principles/hard-rules.md`) against the changed files, and identify them by name in the report.
- Confirm **Scope drift** is `none`, or list every out-of-request change with a reason.
- Spot-check relevant `skills/antipatterns/` symptoms on the diff (god component, useEffect abuse, prop drilling).
- For each structure you added (feature folder, hook, query, context), name the invariant it protects and the user's word for it, or put it back on the ladder (`component-discipline` #7).
- Confirm anything a person was asked to approve was written in their words, not Contract jargon (`component-discipline` #14).
- Check comment discipline: no narration comments; names explain what, comments explain why.
- If broader review is needed, run the per-layer checks in
  `{pack}/docs/reference/reviewer-checklist.md`.
- Run the necessary tests and record reproducible commands, toolchain identity (node/npm path or version, required env vars), and results.
- For any failed or skipped verification, leave a reason and the risk.

## Completion report

```markdown
## Design Decisions
-

## Verification
- Tests:
- Project rules:
- Scope drift: none | <file/change — why>

## Remaining Risks
-
```

## Stage boundaries

A new feature area or large screen keeps the existing Discovery -> Test stages and human approvals.
Craft does not erase these boundaries. It performs focused work on an existing codebase more strictly.
