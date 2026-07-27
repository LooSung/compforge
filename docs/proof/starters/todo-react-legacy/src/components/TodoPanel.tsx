import type { Todo } from '../types';
import { TodoList } from './TodoList';

interface TodoPanelProps {
  todos: Todo[];
  loading: boolean;
  failed: boolean;
  onToggle: (id: string) => void;
  onRemove: (id: string) => void;
}

export function TodoPanel({ todos, loading, failed, onToggle, onRemove }: TodoPanelProps) {
  return (
    <section className="todo-panel">
      <h2>Your list</h2>
      <TodoList
        todos={todos}
        loading={loading}
        failed={failed}
        onToggle={onToggle}
        onRemove={onRemove}
      />
    </section>
  );
}
