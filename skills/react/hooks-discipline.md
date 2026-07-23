---
name: hooks-discipline
description: Custom hook extraction rules and useEffect discipline - when to extract, how to test, what effects are for.
tags: [react, hooks]
stability: experimental
---

# Hooks Discipline

## When to extract a custom hook

Extract when logic exists independent of any particular UI:

- The same stateful logic appears in a second component (Rule of Three applies to a third).
- A component's non-JSX logic passes ~15 lines.
- The logic is testable as behavior ("adding an item updates the total") without rendering markup.

Name by capability: `useCart`, `useDebounce`, `usePagination` — not `useCartPageLogic`.

## Hook contract

- Input: plain values/config. Output: a typed object with named fields.
- A hook owns its state; callers never receive setters to internal state — expose intent methods (`addItem`, `reset`).
- Hooks call hooks unconditionally at the top (React's rules of hooks are load-bearing, not style).

## useEffect is a last resort

An effect exists to **synchronize with a system React does not own**: subscriptions,
timers, DOM APIs, analytics, imperative widgets. Everything else has a better tool:

| You want to… | Not an effect — use |
|---|---|
| Compute from state/props | derive at render / `useMemo` |
| Respond to a user action | the event handler |
| Fetch server data | query layer |
| Reset state when a prop changes | `key` on the component |
| Sync two pieces of state | one source of truth; delete one |

Every effect must have: a dependency array that is honest (no lint suppressions),
and a cleanup function when it subscribes to anything.

## Testing hooks

- Test with `renderHook` (Testing Library); assert returned values and intent methods.
- Mock at the boundary the hook touches (network via MSW, timers via fake timers) — not the hook's internals.
- Hard Rule: logic hooks do not ship without tests.

## Checklist
- [ ] Hook named by capability; typed input/output
- [ ] No setters leaked; intent methods only
- [ ] Every effect justified as external-system sync
- [ ] Dependency arrays honest; cleanups present
- [ ] Tests cover branching behavior
