import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { renderHook, waitFor } from '@testing-library/react';
import type { ReactNode } from 'react';
import { beforeEach, describe, expect, it } from 'vitest';
import { resetTodosDb, useTodosQuery } from '../../../entities/todo';
import { useAddTodo } from './useAddTodo';

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return function Wrapper({ children }: { children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

describe('useAddTodo', () => {
  beforeEach(() => {
    resetTodosDb();
  });

  it('adds a todo and refreshes the entity query', async () => {
    const wrapper = createWrapper();
    const { result } = renderHook(
      () => ({ addTodo: useAddTodo(), todosQuery: useTodosQuery() }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.todosQuery.isPending).toBe(false));

    result.current.addTodo.add('write tests');

    await waitFor(() =>
      expect(result.current.todosQuery.data).toHaveLength(1),
    );
    expect(result.current.todosQuery.data?.[0]).toMatchObject({
      title: 'write tests',
      completed: false,
    });
  });
});
