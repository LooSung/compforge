---
name: component-discipline
description: Core Compforge principles to read before frontend work. Fixes component responsibility, state placement, boundaries, and tests.
tags: [react, typescript, principles]
stability: experimental
---

# Component Discipline

Read this before starting frontend work.
In the completion report, mention only the principles that actually changed a design decision.

## The ladder

Decide what not to write, then where state lives. Climb from the top; stop at the first rung that holds.

```text
Before writing a component
1. Does it need to exist?         -> no: don't build it
2. Platform feature?              -> use it (<dialog>, <form>, CSS, the URL)
3. Framework or installed dep?    -> use it

Before storing a value
4. Derivable from what you have?  -> derive at render; don't store it
5. Comes from the server?         -> query layer, never useState
6. Belongs in the URL?            -> search params / route params
7. Shared across distant nodes?   -> composition first, then context or store
8. Only then                      -> local state, the minimum that works
```

Both halves are the same move: **don't create it; if it must exist, it has exactly one home.**

**Never on the chopping block:** loading, error, and empty states; accessible names
and roles; focus management and keyboard paths; input validation. These cost lines
and are the first thing a brevity heuristic deletes. Small code is a consequence of
building only what the screen needs, never a target.

The rungs are expanded by principles #3 and #7 below.

## 1. Components render; hooks decide

Business logic belongs in custom hooks or pure functions,
not in JSX bodies, event-handler lambdas, or render-time expressions.

Example: prefer `const { canSubmit, submit } = useCheckout(cart)` over 50 lines of logic inside the component.

## 2. Define boundaries before code

Before writing code, first write down the component tree, the state each node owns,
where server data enters, and which props cross which boundaries.

## 3. Name the state's home before creating it

Every piece of state has exactly one correct home — walk rungs 4–8 of the ladder
before creating any of it.

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

## 7. Subtract before abstracting

Writing code is the last resort — walk rungs 1–3 of the ladder before adding any.

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
- **A defect your feature makes newly reachable or materially worse is inside
  the request.** That is not adjacent code you would like to improve — it is
  your feature's behavior. Make the smallest fix that serves the feature and
  name it in the summary. Do not ship a comment deferring a bug you amplified.

## Rationalizations (do not accept these from yourself)

| Excuse | Reality |
|---|---|
| "I'll just add this state here for now" | Misplaced state is the bug you will debug later. Use the ladder (#3). |
| "A useEffect is the quickest way to sync this" | Sync effects are the defect, not the fix (`antipatterns/useeffect-abuse.md`). |
| "This component is already long, a bit more won't hurt" | 200 lines is the line. Split before adding (`react/component-boundary.md`). |
| "Tests after the UI is done" | Untested logic hooks do not ship (Hard Rule). Hooks first, with tests. |
| "It's just a prototype" | Prototypes become production. Structure is cheapest now. |
| "That bug was already there, it's out of scope" | Not once your feature makes it worse. A per-keystroke version of a per-click bug is yours (#11). |
| "The skeleton stage is overhead for this" | Skipping boundaries is how god components start. Small task? Use Craft's small paths instead. |
