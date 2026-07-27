# feature: todo title search

## Status
done

## Context
Add title search to the todo list: case-insensitive substring match on the title,
combined with the existing status filter. The query lives in the URL so a filtered
view survives reload and can be shared. The screen shows how many todos match,
shows a distinct empty state when the query matches nothing, and offers a
"complete all matches" action that is idempotent for already-completed todos.

## Assumptions
Assumptions:
- Search matches the title only (as requested), case-insensitive substring, query trimmed;
  a blank/whitespace-only query means "no search" and shows the status-filtered list.
- URL key is `q`, mirroring the existing `filter` key; empty query removes the param.
- "Matching" = status filter AND query, i.e. exactly the list rendered on screen.
- "Complete all matches" completes only the currently matching todos; matching todos
  that are already completed are skipped (no toggle), so they stay completed.
- Match count is always visible (not only while searching), as a `role="status"` live region.

Alternatives considered:
- Change `filterTodos(todos, filter)` into one `filterTodos(todos, {filter, query})`:
  rejected, it rewrites a tested signature and its call site for no behavior gain.
  Composing two pure functions keeps the existing knowledge intact.
- Add an idempotent `completeTodo(id)` endpoint to `todosApi`: rejected as extra
  backend surface. Guarding at the hook (skip todos already completed before calling
  the existing toggle mutation) gives the same guarantee with no API change.
- Boolean `isSearching` prop on `TodoList` to pick the empty text: rejected in favour of
  an `emptyState` slot (composition before configuration).

Why this path:
Smallest coherent change: one new pure matcher next to the existing filter, one thin
URL hook mirroring `useTodoFilter`, one presentational input, one new intent method on
the existing `useTodos` door to server state. No existing behavior changes.

## Component Contract
Feature: todo title search + bulk complete of matches
Component Tree (new/changed nodes):
- `App` (changed, wiring): composes filter + search, derives `visible`, renders match
  count and the complete-all action.
- `TodoSearch` (new, presentational): labeled search input.
- `TodoList` (changed, presentational): optional `emptyState` slot; default text unchanged.
State Placement (each piece → home):
- query string → URL (`?q=`) via `useSearchParamState` (bookmarkable/shareable) — rung 6.
- status filter → URL (unchanged).
- visible todos, match count → derived at render from todos + filter + query — rung 4.
- todos / completion → server, query layer via `useTodos` — rung 5.
- no new `useState`.
Props Crossing Boundaries:
- `TodoSearch`: `value: string`, `onChange: (next: string) => void`.
- `TodoList`: existing props + `emptyState?: ReactNode`.
Server Data (queries/mutations): unchanged `['todos']` query; new `completeAll(ids)`
intent reusing the existing toggle mutation, skipping already-completed todos.
Test Targets (hooks/components):
- `searchTodos` pure matcher (case-insensitivity, trimming, no match, composition with filter).
- `useTodos.completeAll` (completes matches, leaves already-completed completed, ignores non-matches).
- App: URL round-trip of `q`, combined filter+search, match count + live region, distinct
  no-match empty state, complete-all button behavior.

## Decisions
- 2026-07-27 query lives in the URL (`q`), not `useState` — required to survive reload and be shareable.
- 2026-07-27 kept `filterTodos` untouched; added `searchTodos` and composed the two at the call site.
- 2026-07-27 `completeAll` filters out already-completed todos in `useTodos` instead of adding a
  `completeTodo` endpoint; the toggle mutation is only called for todos that are still open.
- 2026-07-27 deferred: `useSearchParamState` uses `pushState`, so each keystroke adds a history
  entry. Upgrade path is a `replace` option on that shared hook; not taken to avoid changing
  behavior of the existing filter state.

## Progress
- [x] assumptions + contract written
- [x] searchTodos + tests
- [x] useTodoSearch
- [x] useTodos.completeAll + tests
- [x] TodoSearch, match count, empty state, complete-all wiring
- [x] App tests
- [x] npm run check green (lint + tsc + 29 vitest tests)

## Verification
- `npm run check`: eslint clean, `tsc --noEmit` clean, 29/29 tests pass.
- Mutation check: dropping the `!todo.completed` guard in `completeAll` fails
  2 tests (`useTodos > leaves an already completed todo completed` and the App
  complete-all test), so the idempotency guarantee is actually covered.
- Antipatterns: no new effect, no new component over 60 lines, props cross at most
  one boundary.
- Scope drift: `.gitignore` gained `.craft/` (continuity work dir, per the skill).
  No other out-of-request change.

## Remaining Risks
- Each keystroke pushes a history entry (existing `useSearchParamState` behavior);
  the browser Back button walks the query character by character.
- Search is substring only: no diacritic folding, no fuzzy match, no highlight.
- `completeAll` fires one mutation per open match; a very large match set means many
  round trips and many cache invalidations.
