import { AddTodoForm } from '../features/todos/components/AddTodoForm';
import { TodoFilter } from '../features/todos/components/TodoFilter';
import { TodoList } from '../features/todos/components/TodoList';
import { useTodoFilter } from '../features/todos/hooks/useTodoFilter';
import { useTodos } from '../features/todos/hooks/useTodos';
import { countActive, filterTodos } from '../features/todos/lib/filterTodos';

// The app layer composes the feature; features never import each other.
export function App() {
  const { todos, isLoading, isError, add, toggle, remove } = useTodos();
  const { filter, setFilter, filters } = useTodoFilter();

  // Derived at render — never stored (state ladder rung 1).
  const visible = filterTodos(todos, filter);
  const activeCount = countActive(todos);

  return (
    <main>
      <h1>Todos</h1>
      <AddTodoForm onAdd={add} />
      <TodoFilter value={filter} options={filters} onChange={setFilter} />
      <TodoList
        todos={visible}
        isLoading={isLoading}
        isError={isError}
        onToggle={toggle}
        onRemove={remove}
      />
      <p>{activeCount} active</p>
    </main>
  );
}
