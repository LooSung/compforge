import { useMutation, useQueryClient } from '@tanstack/react-query';
import { createTodo, TODOS_KEY } from '../../../entities/todo';

export function useAddTodo() {
  const queryClient = useQueryClient();
  const mutation = useMutation({
    mutationFn: createTodo,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: TODOS_KEY }),
  });

  return { add: (title: string) => mutation.mutate(title) };
}
