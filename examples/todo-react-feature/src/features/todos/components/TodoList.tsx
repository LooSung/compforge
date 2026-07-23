import type { Todo } from '../types';
import { TodoItem } from './TodoItem';

interface TodoListProps {
  todos: Todo[];
  isLoading: boolean;
  isError: boolean;
  onToggle: (id: Todo['id']) => void;
  onRemove: (id: Todo['id']) => void;
}

// Loading, error, and empty are named states, not afterthoughts
// (skills/workflow/design.md UI States).
export function TodoList({ todos, isLoading, isError, onToggle, onRemove }: TodoListProps) {
  if (isLoading) {
    return <p role="status">Loading todos…</p>;
  }

  if (isError) {
    return <p role="alert">Could not load todos. Try reloading the page.</p>;
  }

  if (todos.length === 0) {
    return <p role="status">No todos yet. Add your first one above.</p>;
  }

  return (
    <ul className="todo-list">
      {todos.map((todo) => (
        <TodoItem key={todo.id} todo={todo} onToggle={onToggle} onRemove={onRemove} />
      ))}
    </ul>
  );
}
