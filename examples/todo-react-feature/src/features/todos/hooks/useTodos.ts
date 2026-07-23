import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { createTodo, deleteTodo, fetchTodos, toggleTodo } from '../api/todosApi';
import type { Todo } from '../types';

const TODOS_KEY = ['todos'] as const;

// Server state lives in the query layer; this hook is the feature's only door
// to it. Components receive values and intent methods, never query internals.
export function useTodos() {
  const queryClient = useQueryClient();
  const invalidate = () =>
    queryClient.invalidateQueries({ queryKey: TODOS_KEY });

  const todosQuery = useQuery({ queryKey: TODOS_KEY, queryFn: fetchTodos });
  const addMutation = useMutation({ mutationFn: createTodo, onSuccess: invalidate });
  const toggleMutation = useMutation({ mutationFn: toggleTodo, onSuccess: invalidate });
  const removeMutation = useMutation({ mutationFn: deleteTodo, onSuccess: invalidate });

  return {
    todos: todosQuery.data ?? [],
    isLoading: todosQuery.isPending,
    isError: todosQuery.isError,
    add: (title: string) => addMutation.mutate(title),
    toggle: (id: Todo['id']) => toggleMutation.mutate(id),
    remove: (id: Todo['id']) => removeMutation.mutate(id),
  };
}
