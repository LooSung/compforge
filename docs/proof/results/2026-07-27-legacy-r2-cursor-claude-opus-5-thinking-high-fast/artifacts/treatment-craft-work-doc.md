# feature: Todo title search

## Status
done

## Context
Add title search to the todo list. Matching is case-insensitive on the title and
combines with the existing status filter (all/active/completed). The query lives in
the URL so a filtered view survives reload and can be shared. The screen shows how
many todos match, announces that count to assistive technology, shows a distinct
empty state when the query matches nothing, and offers a "Complete all matches"
action that completes every currently matching todo without un-completing any todo
that is already completed.

## Decisions
- 2026-07-27 query state lives in the URL (`?q=`) via `useSyncExternalStore` over
  `popstate`, not `useState` — requirement is reload-survivable and shareable, and no
  router is installed (state-placement rung 3, ladder rung 2 "use the platform").
- 2026-07-27 `history.replaceState` per keystroke instead of `pushState`, so typing does
  not fill the back stack. Back/forward still resync through the `popstate` subscription.
- 2026-07-27 matching + status combination lives in a pure module (`src/utils/todoFilters.ts`)
  so it is testable without rendering.
- 2026-07-27 visible todos are derived at render instead of the pre-existing
  `useState` + `useEffect` copy. Search is a per-keystroke input, so the effect-copy
  would render (and announce) a stale list/count on every character — component-discipline #11.
- 2026-07-27 "Complete all matches" completes only matching todos that are not yet
  completed, because the API exposes `toggleTodo` (a flip), not `setCompleted`.

## Progress
- [x] assumptions + component contract
- [x] pure matching module + tests (`src/utils/todoFilters.ts`)
- [x] URL query hook + tests (`src/hooks/useUrlParam.ts`)
- [x] search UI, match count, distinct empty state, complete-all-matches
- [x] app-level behavior tests
- [x] `npm run check` green (lint + tsc + 37 vitest tests)
- [x] mutation check: completing all matches over `visibleTodos` instead of the
      incomplete subset makes `App complete all matches` fail as intended

## Known drift (not fixed here)
`activeCount` is still a `useState` + `useEffect` copy of a value derivable from
`todos`. Search does not touch it, so it stayed out of this change (#11).

## Next step
None — feature complete.
