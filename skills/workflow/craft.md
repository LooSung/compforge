---
name: workflow-craft
description: Compforge execution orchestrator that classifies a frontend task and runs it via the smallest appropriate path.
tags: [workflow, react, typescript]
stability: experimental
---

# Workflow — Craft

## Purpose

Run a frontend task via the smallest appropriate execution path.
The goal is not to add code.
Make components own a single responsibility and keep logic in hooks, state in its correct home.

## Startup procedure

0. `skills/workflow/continuity.md` Resume: if a work doc already exists, read it first and continue. If none exists and this is an **execution task (feature/refactor/bugfix)**, create `.craft/<kind>-<slug>.md` **automatically** without asking and announce it in one line. Do not create one for advisory or tiny tasks, or if `AGENTS.md` contains `Compforge continuity: off`.
1. Confirm the **target project**. The Compforge **pack** (`~/.compforge`, skill paths) is not the **repo** the user works on. If `pwd` is the pack root, you are in the wrong place — confirm the agent was started from the target project.
2. When the user points to a file via `@…` or a path, resolve it against the **target project root**. Do not look under `~/.compforge/…`. If missing, confirm the absolute path with the user.
3. Read `skills/principles/component-discipline.md`.
4. Review the user request and the existing code.
5. Select one smallest execution path from the table below.
6. For an advisory request, only recommend a path and do not implement.
7. For an execution request, copy the checklist of the chosen skill or workflow into your task list.
8. If you skip any step, leave a one-line reason.
9. Write the **Assumptions** block (below), then the Component Contract, before implementing UI logic.
10. Implement and test along the chosen path. Keep changes surgical (`component-discipline` #11).
11. Verify the Hard Rules in `AGENTS.md` and the results of the tests you ran.
12. Record design decisions, verification results, **Scope drift**, and remaining risks in the completion report format. **Completion gate**: if a continuity work doc exists, do not report done before updating that doc (Status/Progress/Decisions).

## Execution-path selection

| Request signal | Execution path |
|---|---|
| Design or split a single component | `skills/react/component-boundary.md` |
| Where should this state live; server/client/URL data | `skills/react/state-placement.md` |
| Extract a custom hook; effect cleanup; logic reuse | `skills/react/hooks-discipline.md` |
| God component, moving responsibility, behavior-preserving cleanup | `skills/workflow/refactor.md` |
| Derived state in useEffect, fetch chains in effects | `skills/antipatterns/useeffect-abuse.md` |
| Props passed through 3+ levels | `skills/antipatterns/prop-drilling.md` |
| New feature area or large screen | the full workflow starting at `skills/workflow/discovery.md` |
| Advisory request that wants a recommendation only | recommend the smallest path and do not implement |
| Execution request but a decision is missing ("make a todo app") | fill the decision via **Ambiguity resolution** below, then select a path |

## Ambiguity resolution (before implementation)

When the intent is execution but a decisive input is empty (stack, folder architecture, state approach, styling, supported screens/edge cases), resolve it once before code — do not interrogate; propose defaults.

1. Identify the missing decision dimensions.
2. **Stack and architecture must pass the `skills/lang/frontend-stack.md` scope gate.** If unspecified, steer to TypeScript + React (Vite); for an unsupported stack (Vue for now, Angular, Svelte) state that Compforge does not apply yet (plain build only if insisted).
3. For items you can set safely, **state the default** and proceed (e.g., Vite, feature folders, CSS Modules, no router).
4. Ask only the 1–2 questions that actually change the result (architecture/scope) (e.g., "Multiple pages? -> add routing and URL state").

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

- Complete the checklist of the chosen skill or workflow.
- Verify the Hard Rules in `AGENTS.md` against the changed files.
- Confirm **Scope drift** is `none`, or list every out-of-request change with a reason.
- Spot-check relevant `skills/antipatterns/` symptoms on the diff (god component, useEffect abuse, prop drilling).
- Run the necessary tests and record the commands and results.
- For any failed or skipped verification, leave a reason and the risk.

## Completion report

```markdown
## Design Decisions
-

## Verification
- Tests:
- Hard Rules:
- Scope drift: none | <file/change — why>

## Remaining Risks
-
```

## Stage boundaries

A new feature area or large screen keeps the existing Discovery -> Test stages and human approvals.
Craft does not erase these boundaries. It performs focused work on an existing codebase more strictly.
