# Feature: Todo Search

## Status
Completed

## Request
Add search to the todo list. Match on title (case-insensitive), combine with existing status filter. Keep query in URL for bookmark/share. Show match count, distinct empty state for no matches. Add "complete all matches" action. Ensure accessibility (label, announcements). Add tests. No unrelated changes.

## Progress
- [x] Assumptions
- [x] Component Contract
- [x] Implementation
- [x] Tests
- [x] Verification

## Decisions
- Search query stored in URL (`?q=`) per state-placement ladder (bookmarkable)
- Matching logic extracted to pure function (`matchesTodo`) for testability
- visibleTodos and activeCount computed as derived state at render (removed useEffect anti-pattern)
- Complete all matches only targets currently incomplete items in filtered view
- Match count uses aria-live="polite" for screen reader announcements

## Files Changed
- Added: `src/utils/match.ts`, `src/utils/match.test.ts`
- Modified: `src/App.tsx`, `src/components/TodoPanel.tsx`, `src/components/TodoList.tsx`, `src/App.test.tsx`

## Test Results
All 20 tests pass (3 test files)
- match.test.ts: 5 tests for matching logic
- App.test.tsx: 8 new tests for search behavior
- No linting errors, no type errors

