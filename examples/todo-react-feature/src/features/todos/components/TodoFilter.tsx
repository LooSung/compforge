import type { TodoFilter as Filter } from '../types';

interface TodoFilterProps {
  value: Filter;
  options: Filter[];
  onChange: (next: Filter) => void;
}

export function TodoFilter({ value, options, onChange }: TodoFilterProps) {
  return (
    <div role="group" aria-label="Filter todos">
      {options.map((option) => (
        <button
          key={option}
          type="button"
          aria-pressed={option === value}
          onClick={() => onChange(option)}
        >
          {option}
        </button>
      ))}
    </div>
  );
}
