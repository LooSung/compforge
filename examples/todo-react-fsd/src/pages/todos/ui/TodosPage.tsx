import {
  countActive,
  filterTodos,
  TodoList,
  useRemoveTodo,
  useTodosQuery,
  useToggleTodo,
} from '../../../entities/todo';
import { AddTodoForm } from '../../../features/add-todo';
import { TodoFilterButtons, useTodoFilter } from '../../../features/filter-todos';

// Pages compose features and entities; they hold no business logic
// (AGENTS.md layer layout).
export function TodosPage() {
  const todosQuery = useTodosQuery();
  const { toggle } = useToggleTodo();
  const { remove } = useRemoveTodo();
  const { filter } = useTodoFilter();

  const todos = todosQuery.data ?? [];
  // Derived at render — never stored (state ladder rung 1).
  const visible = filterTodos(todos, filter);
  const activeCount = countActive(todos);

  return (
    <main>
      <h1>Todos</h1>
      <AddTodoForm />
      <TodoFilterButtons />
      <TodoList
        todos={visible}
        isLoading={todosQuery.isPending}
        isError={todosQuery.isError}
        onToggle={toggle}
        onRemove={remove}
      />
      <p>{activeCount} active</p>
    </main>
  );
}
