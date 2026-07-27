# feature: Todo title search

## Status
done

## Context
Add title search to the todo list. Matching is case-insensitive on the title and
combines with the existing status filter (all/active/completed). The query lives in
the URL so a filtered view survives reload and can be shared. The UI shows how many
todos match, shows a distinct empty state when the query matches nothing, and offers a
"complete all matches" action that completes every currently matching todo while
leaving already-completed todos completed.

## Decisions
- 2026-07-27 query lives in the URL search param `q`, not `useState` — ladder rung 6
  (bookmarkable/shareable/survives reload). The status filter stays in local state
  because the request only named the query; moving it would change unrelated behavior.
- 2026-07-27 no router is installed, so a small `useUrlSearchParam` hook over the
  History API instead of adding `react-router`/`nuqs` for one parameter.
- 2026-07-27 `history.replaceState`, not `pushState`, so typing does not push a history
  entry per keystroke; the URL is still reloadable and copyable.
- 2026-07-27 matches, match count and pending-match count are derived at render from
  the already filtered list — no new state, no new effect.
- 2026-07-27 "complete all matches" reuses the existing `toggleTodo` endpoint but only
  for matches that are not completed yet, since `toggleTodo` inverts and would
  un-complete an already completed todo.
- 2026-07-27 the pre-existing `visibleTodos`/`activeCount` derived-state effects in
  `App.tsx` are left alone (component-discipline #11: do not mix unrelated refactoring
  into a feature). Noted as a risk, not fixed here.
- 2026-07-27 the count reads "N matching todos" rather than "N matches" so the existing
  `formatCount` util needs no signature change (it appends a plain "s").
- 2026-07-27 the distinct empty state is an optional `emptyMessage` prop threaded
  `App -> TodoPanel -> TodoList`; the list keeps its own default, so search vocabulary
  does not leak into it.

## Files
- `src/utils/search.ts` + test — the matching rule (single home)
- `src/hooks/useUrlSearchParam.ts` + test — `q` in the URL via History API
- `src/components/TodoSearch.tsx` — labeled input, live match count, complete-all
- `src/App.tsx` — wiring; `src/components/{TodoPanel,TodoList}.tsx` — `emptyMessage`
- `src/App.test.tsx` — 10 new behavior tests

## Progress
- [x] assumptions and component contract
- [x] `searchTodos` pure matcher + tests
- [x] `useUrlSearchParam` hook + tests
- [x] `TodoSearch` component (labeled input, live match count, complete-all)
- [x] wire `App`, thread distinct empty state through `TodoPanel` -> `TodoList`
- [x] App behavior tests
- [x] verification — `npm run check` green (lint, tsc, 27 tests)
- [x] mutation-checked the completed-preservation test (swapping `pendingMatches` for
      `matchingTodos` fails it, so the guard is genuinely covered)

## Next step
None — feature complete. If search grows (token matching, description matching,
debounce), extend `src/utils/search.ts`; it is the single home for the matching rule.
