---
name: useeffect-abuse
description: Detect and remove effects that compute derived state, transform data, chain fetches, or sync duplicated state.
tags: [react, antipattern, hooks]
stability: experimental
---

# Anti-pattern — useEffect Abuse

## Symptoms

- `useEffect` that only calls `setX` computed from other state/props (derived state stored).
- `useEffect` + `useState` + manual `fetch` where a query layer exists or should.
- Effect chains: effect A sets state that triggers effect B that sets state…
- `eslint-disable-next-line react-hooks/exhaustive-deps` — the lint is telling you the design is wrong.
- Loading/race bugs "fixed" with `isMounted` flags.

## Why it is a defect, not style

Each stored copy of derivable data is a sync obligation. Effects run after render,
so every copy is stale for at least one frame — the bug window agents then patch
with more effects.

## Fixes by case

| Case | Fix |
|---|---|
| Derived value stored | Delete the state; compute at render (`useMemo` only if measured-expensive) |
| Data transformation of query results | Transform in the query layer (`select`) or at render |
| Fetch in effect | Move to query layer; delete loading/error handstitching |
| Reset-on-prop-change | `key` prop on the component |
| Two states kept in sync | Single source of truth; derive the other |
| Genuine external sync (subscription, timer, DOM) | Keep the effect; honest deps + cleanup |

## Review heuristic

For every `useEffect` in a diff, ask: **"which external system does this synchronize with?"**
No answer → it should not be an effect.

## Reference

React docs: "You Might Not Need an Effect" — this skill is its enforcement form.
