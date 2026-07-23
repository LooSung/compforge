import { useTodoFilter } from '../model/useTodoFilter';

// Self-contained: reads and writes the URL-backed filter state itself.
// The page reads the same state through useTodoFilter — the URL is the
// single source of truth, so there is nothing to keep in sync.
export function TodoFilterButtons() {
  const { filter, setFilter, filters } = useTodoFilter();

  return (
    <div role="group" aria-label="Filter todos">
      {filters.map((option) => (
        <button
          key={option}
          type="button"
          aria-pressed={option === filter}
          onClick={() => setFilter(option)}
        >
          {option}
        </button>
      ))}
    </div>
  );
}
