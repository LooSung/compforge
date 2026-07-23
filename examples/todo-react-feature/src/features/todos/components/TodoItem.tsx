import type { Todo } from '../types';

interface TodoItemProps {
  todo: Todo;
  onToggle: (id: Todo['id']) => void;
  onRemove: (id: Todo['id']) => void;
}

export function TodoItem({ todo, onToggle, onRemove }: TodoItemProps) {
  return (
    <li className="todo-item">
      <label>
        <input
          type="checkbox"
          checked={todo.completed}
          onChange={() => onToggle(todo.id)}
        />
        <span className={todo.completed ? 'todo-done' : undefined}>
          {todo.title}
        </span>
      </label>
      <button
        type="button"
        aria-label={`Delete ${todo.title}`}
        onClick={() => onRemove(todo.id)}
      >
        ✕
      </button>
    </li>
  );
}
