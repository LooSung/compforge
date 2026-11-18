---
name: workflow-craft
description: Compforge execution orchestrator that classifies a frontend task and runs it via the smallest appropriate path.
tags: [workflow, react, typescript]
stability: stable
---

# Workflow — Craft

Contents: Purpose · Startup procedure · Execution-path selection · Size gate · Ambiguity resolution (before implementation) · Assumptions (before Contract) · Component Contract · Craft checks · Stage boundaries

## Purpose

Run a frontend task via the smallest appropriate execution path.
The goal is not code volume. Add or change code only when the selected path
requires it. Components render; hooks decide; every piece of state has one home.

## Startup procedure

1. Run the **Startup** and, when a plan is named, **Plan input** gates in
   `skills/workflow/gates.md`.
2. Read `skills/principles/component-discipline.md`.
3. Review the user request and the existing code.
4. Select one smallest execution path from the table below.
5. For an advisory request, only recommend a path and do not implement.
6. For an execution request, copy the checklist of the chosen skill, playbook, or workflow into your task list.
7. Write the **Assumptions** block (below), then the Component Contract, before implementing UI logic. On the small path (**Size gate**), each is one line.
8. Implement and test along the chosen path. Keep changes surgical (`component-discipline` #11).
9. Verify and report with the `gates.md` **Verification** and **Completion report** gates, plus the Craft checks below.

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

## Size gate

Decide once, after selecting the path. A task is **small** when all hold:

- it changes at most two existing files and adds no component, hook, state home, query, or context;
- it adds no dependency and changes no public API, route, or schema;
- it is not a workflow stage, and the user did not ask for the full format.

On the small path only the paperwork shrinks. Hard Rules, tests, and Scope drift
still apply, and no continuity work doc is created.

- Assumptions: one line, or `none`.
- Contract: one line — `Contract: n/a — small change (<why>)`.
- Completion report: the three-line form in `gates.md`.

If the work grows past these limits, say so and switch to the standard path.

## Ambiguity resolution (before implementation)

When the intent is execution but a decisive input is empty (stack, folder architecture, state approach, styling, supported screens/edge cases), resolve it once before code — do not interrogate; propose defaults.

1. Identify the missing decision dimensions.
2. **Stack and architecture must pass the `skills/lang/frontend-stack.md` scope gate.** If unspecified, steer to TypeScript + React (Vite); for an unsupported stack (Vue, Angular, Svelte) state that Compforge does not apply (plain build only if insisted).
3. For items you can set safely, **state the default** and proceed (e.g., Vite, feature folders, CSS Modules, no router).
4. Ask only the 1–2 questions that actually change the result (architecture/scope) (e.g., "Multiple pages? -> add routing and URL state").
5. You may offer the `examples/` todo family (feature / FSD / Next) as a reference menu.
6. On resume, the Resume block's `Continue this, or a new request instead?` is that question. Do not invent a default that drops unfinished previous work.

## Assumptions (before Contract)

For any standard-size Craft task that requires implementation, fill this once before the Component Contract
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

For any standard-size Craft task that requires implementation, fill in the form below once before writing code.
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

## Craft checks

In addition to the `gates.md` Verification gate:

- Spot-check relevant `skills/antipatterns/` symptoms on the diff (god component, useEffect abuse, prop drilling).
- For each structure you added (feature folder, hook, query, context), name the invariant it protects and the user's word for it, or put it back on the ladder (`component-discipline` #7).
- Confirm anything a person was asked to approve was written in their words, not Contract jargon (`component-discipline` #14).
- Check comment discipline: no narration comments; names explain what, comments explain why.
- If broader review is needed, run the per-layer checks in
  `{pack}/docs/reference/reviewer-checklist.md`.

## Stage boundaries

A new feature area or large screen keeps the existing Discovery -> Test stages and human approvals.
Craft does not erase these boundaries. It performs focused work on an existing codebase more strictly.
