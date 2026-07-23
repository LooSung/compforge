---
name: state-placement
description: Decide the single correct home for each piece of state - derived, server (query layer), URL, store, or local.
tags: [react, state]
stability: experimental
---

# State Placement

Every piece of state has exactly one correct home. Misplaced state is the root of
most React bugs: stale copies, sync effects, phantom re-renders.

## Decision ladder (stop at the first match)

```
1. Derivable from existing state/props?  -> derive at render; do not store
2. Comes from the server?                -> query layer (TanStack Query et al.)
3. Belongs in the URL?                   -> route/search params
4. Shared across distant components?     -> store (Zustand) or context
5. Otherwise                             -> useState in the owning component
```

## Rules per home

**Derived** — compute inline or with `useMemo` if measured-expensive. Never `useState` + `useEffect` to "sync" it (`antipatterns/useeffect-abuse.md`).

**Server** — the query layer owns caching, refetch, loading/error. Components never copy query results into `useState`. Mutations invalidate or optimistically update through the query layer's API.

**URL** — anything the user should be able to bookmark, share, or restore on refresh: active tab, filters, pagination, selected item. If losing it on refresh would annoy the user, it's URL state.

**Store/context** — only when two components far apart in the tree genuinely share it (theme, session, cart badge). A store used by one feature is a smell — keep it local to that feature.

**Local** — the default for interaction state: input drafts, open/closed, hover. Owned by the lowest component that needs it.

## Placement smells

| Symptom | Wrong home | Fix |
|---|---|---|
| `useEffect` copying props/query data into state | stored derived/server | delete state; derive or read query |
| Filter resets on refresh | local | move to URL |
| Global store with 20 unrelated fields | store as dumping ground | split per feature; localize |
| Two components sync via callback chains | local too low | lift to common owner |

## Checklist
- [ ] Every new state named in the Design's placement table
- [ ] No `useState` holding server or derivable data
- [ ] Bookmarkable UI state lives in the URL
- [ ] Store additions justified by two distant consumers
