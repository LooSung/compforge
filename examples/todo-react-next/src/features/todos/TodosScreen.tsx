'use client';

import { AddTodoForm } from './components/AddTodoForm';
import { TodoFilter } from './components/TodoFilter';
import { TodoList } from './components/TodoList';
import { useTodoFilter } from './hooks/useTodoFilter';
import { useTodos } from './hooks/useTodos';
import { countActive, filterTodos } from './lib/filterTodos';

// Client composition for the todos feature. The Server Component page
// imports this file and nothing else from the feature.
export function TodosScreen({ initialFilter }: { initialFilter?: string }) {
  const { todos, isLoading, isError, add, toggle, remove } = useTodos();
  const { filter, setFilter, filters } = useTodoFilter(initialFilter);

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
