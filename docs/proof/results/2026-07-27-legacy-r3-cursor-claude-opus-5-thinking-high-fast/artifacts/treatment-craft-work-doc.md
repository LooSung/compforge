# feature: todo title search

## Status
done

## Context
Add title search to the existing todo list. The query is case-insensitive, combines
with the existing status filter (all/active/completed), and lives in the URL so a
filtered view survives reload and can be shared. The screen shows how many todos
match, shows a distinct empty state when the query matches nothing, and offers a
"complete all matches" action that completes every currently matching todo while
leaving already-completed todos completed.

## Decisions
- 2026-07-27 query lives in the URL (`?q=`) via `useSyncExternalStore` + `history.replaceState`, not `useState` — ladder rung 6 (bookmark/share/reload) and no router is installed.
- 2026-07-27 `replaceState` over `pushState` so typing does not push one history entry per keystroke.
- 2026-07-27 status filter stays local `useState` — the request scoped URL persistence to the query only; moving it is a visible follow-up, not a silent change.
- 2026-07-27 "matches" = the currently visible set (status filter AND query), so the count and the bulk action agree with the list on screen.
- 2026-07-27 complete-all uses the existing `toggleTodo` API on matching todos that are *not* completed, so already-completed todos are never flipped back and no API change is needed.
- 2026-07-27 replaced the `visibleTodos` / `activeCount` `useState` + `useEffect` pairs with render-time derivation. Search feeds this pipeline per keystroke, which turns a one-frame stale-copy bug into a per-keystroke one (`component-discipline` #11, `antipatterns/useeffect-abuse.md`).
- 2026-07-27 the match count renders only after load so the `role="status"` region stays mounted across query changes and announces updates instead of its initial value.

## Progress
- [x] assumptions + component contract
- [x] pure matching logic `src/utils/todoFilter.ts` + tests
- [x] URL state hook `src/hooks/useTodoSearchQuery.ts` + tests
- [x] `TodoSearch`, `TodoMatchSummary`, distinct no-match empty state in `TodoList`
- [x] wire `App` (derived list, match count, complete all matches)
- [x] verification gates — `npm run check` (eslint + tsc + vitest) green, 32 tests

## Next step
None — feature complete. Open follow-ups, both pre-existing and deliberately out of
this change: move the status filter into the URL alongside `q`, and move the initial
fetch off `useState` + `useEffect` onto the installed-but-unused TanStack Query layer.
