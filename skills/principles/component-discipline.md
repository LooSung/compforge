---
name: component-discipline
description: Core Compforge principles to read before frontend work. Fixes component responsibility, state placement, boundaries, and tests.
tags: [react, typescript, principles]
stability: experimental
---

# Component Discipline

Read this before starting frontend work.
In the completion report, mention only the principles that actually changed a design decision.

## 1. Components render; hooks decide

Business logic belongs in custom hooks or pure functions,
not in JSX bodies, event-handler lambdas, or render-time expressions.

Example: prefer `const { canSubmit, submit } = useCheckout(cart)` over 50 lines of logic inside the component.

## 2. Define boundaries before code

Before writing code, first write down the component tree, the state each node owns,
where server data enters, and which props cross which boundaries.

## 3. Name the state's home before creating it

Every piece of state has exactly one correct home. Ask in order:

```
1. Can it be derived from existing state/props? -> derive it; do not store it
2. Does it come from the server?                -> query layer (TanStack Query or equivalent)
3. Does it belong in the URL?                   -> route params / search params
4. Is it shared across distant components?      -> store (Zustand or equivalent) or context
5. Otherwise                                    -> local useState in the owning component
```

Storing derived or server data in `useState` is the root of most React bugs.

## 4. Immutability is non-negotiable

Never mutate state, props, or store objects. Produce new values.
If an update looks awkward immutably, the state shape is wrong — fix the shape.

## 5. Composition before configuration

When a component grows variants, reach for `children` and slot props before
boolean flags. Three `is*` props on one component is a split signal.

## 6. Failing test before bug fix

Fix a bug by first writing a reproducible failing test (hook test or component test).
Then resolve it with the smallest change.

## 7. Subtract before abstracting — the pre-write ladder

Writing code is the last resort. Climb from the top; stop at the first rung that holds.

```
1. Does this need to exist?          -> no: don't build it (YAGNI)
2. Platform / language feature?      -> use it (CSS, <form>, <dialog>, URL)
3. Framework default?                -> use it (React/Vite/Next built-ins)
4. Already-installed dependency?     -> use it
5. One line / one hook?              -> finish it there
6. Only then                         -> write the minimum that works
```

**Essential vs accidental.** The ladder cuts only *accidental complexity*
(needless abstraction, wrapper components, unused flexibility). *Essential
complexity* (feature boundaries, state placement, typed contracts) is
deliberate structure and is not subject to the ladder.

**Leave a marker for what you defer.** If you intentionally do the minimum,
mark the spot with what you deferred and the upgrade path.

## 8. Encode lessons in structure

When you find yourself explaining the same mistake twice, do not write more docs.
Capture it as a test, an eslint rule, or an example.

## 9. Duplicate before the wrong abstraction

DRY removes duplication of **knowledge (rules)**, not every JSX block that looks alike.

- Tolerate the second duplication. **Abstract only on the third (Rule of Three).**
- Do not share one "flexible" component across features that merely look similar —
  they evolve differently; duplication is correct there.
- What you should consolidate is scattered *business rules* — pull them into one
  hook or pure function.

## 10. Surface assumptions before coding

Do not silently pick one interpretation when several are plausible.
Before writing UI logic, state what you are assuming, what you considered,
and why this path — then proceed or ask.

- Defaults are fine when safe, but the default must be **visible**, not silent.

## 11. Surgical changes only

Touch only what the request requires. Match existing style; do not "improve"
adjacent code, comments, formatting, or naming while delivering the task.

- Clean up orphans **your change** created (unused imports, dead props).
- Pre-existing dead code: mention it; do not delete it in the same change.
- Do not mix unrelated refactoring with a feature or bug fix.
