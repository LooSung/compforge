import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { renderHook, waitFor } from '@testing-library/react';
import type { ReactNode } from 'react';
import { beforeEach, describe, expect, it } from 'vitest';
import { resetTodosDb } from '../api/todosApi';
import { useTodos } from './useTodos';

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

describe('useTodos', () => {
  beforeEach(() => {
    resetTodosDb();
  });

  it('starts empty after loading', async () => {
    const { result } = renderHook(() => useTodos(), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.todos).toEqual([]);
  });

  it('adds a todo', async () => {
    const { result } = renderHook(() => useTodos(), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isLoading).toBe(false));

    result.current.add('write tests');

    await waitFor(() => expect(result.current.todos).toHaveLength(1));
    expect(result.current.todos[0]).toMatchObject({
      title: 'write tests',
      completed: false,
    });
  });

  it('toggles a todo', async () => {
    resetTodosDb([{ id: 't1', title: 'open thing', completed: false }]);
    const { result } = renderHook(() => useTodos(), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.todos).toHaveLength(1));

    result.current.toggle('t1');

    await waitFor(() => expect(result.current.todos[0]?.completed).toBe(true));
  });

  it('removes a todo', async () => {
    resetTodosDb([{ id: 't1', title: 'open thing', completed: false }]);
    const { result } = renderHook(() => useTodos(), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.todos).toHaveLength(1));

    result.current.remove('t1');

    await waitFor(() => expect(result.current.todos).toHaveLength(0));
  });
});
