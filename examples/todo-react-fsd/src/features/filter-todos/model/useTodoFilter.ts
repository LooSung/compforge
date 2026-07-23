import type { TodoFilter } from '../../../entities/todo';
import { useSearchParamState } from '../../../shared/lib/useSearchParamState';

const FILTERS: TodoFilter[] = ['all', 'active', 'completed'];

function isTodoFilter(value: string): value is TodoFilter {
  return (FILTERS as string[]).includes(value);
}

// Filter is bookmarkable UI state, so its home is the URL, not useState
// (skills/react/state-placement.md rung 3).
export function useTodoFilter() {
  const [raw, setRaw] = useSearchParamState('filter', 'all');
  const filter: TodoFilter = isTodoFilter(raw) ? raw : 'all';

  return {
    filter,
    setFilter: (next: TodoFilter) => setRaw(next),
    filters: FILTERS,
  };
}
