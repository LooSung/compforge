import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { deleteTodo, fetchTodos, toggleTodo } from '../api/todosApi';
import type { Todo } from './types';

export const TODOS_KEY = ['todos'] as const;

export function useTodosQuery() {
  return useQuery({ queryKey: TODOS_KEY, queryFn: fetchTodos });
}

export function useToggleTodo() {
  const queryClient = useQueryClient();
  const mutation = useMutation({
    mutationFn: toggleTodo,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: TODOS_KEY }),
  });
  return { toggle: (id: Todo['id']) => mutation.mutate(id) };
}

export function useRemoveTodo() {
  const queryClient = useQueryClient();
  const mutation = useMutation({
    mutationFn: deleteTodo,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: TODOS_KEY }),
  });
  return { remove: (id: Todo['id']) => mutation.mutate(id) };
}
