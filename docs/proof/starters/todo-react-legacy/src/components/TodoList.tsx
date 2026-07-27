import type { Todo } from '../types';
import { TodoItem } from './TodoItem';

interface TodoListProps {
  todos: Todo[];
  loading: boolean;
  failed: boolean;
  onToggle: (id: string) => void;
  onRemove: (id: string) => void;
}

export function TodoList({ todos, loading, failed, onToggle, onRemove }: TodoListProps) {
  if (loading) {
    return <p role="status">Loading todos…</p>;
  }

  if (failed) {
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
