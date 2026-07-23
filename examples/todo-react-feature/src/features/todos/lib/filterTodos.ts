import type { Todo, TodoFilter } from '../types';

export function filterTodos(todos: Todo[], filter: TodoFilter): Todo[] {
  switch (filter) {
    case 'active':
      return todos.filter((todo) => !todo.completed);
    case 'completed':
      return todos.filter((todo) => todo.completed);
    case 'all':
      return todos;
  }
}

export function countActive(todos: Todo[]): number {
  return todos.filter((todo) => !todo.completed).length;
}
