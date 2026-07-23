import type { Todo } from '../model/types';

// In-memory stand-in for a real backend. The query layer treats it as remote:
// async, latent, and owning the data. UI code never imports this module.
const LATENCY_MS = 30;

let db: Todo[] = [];

const delay = () => new Promise((resolve) => setTimeout(resolve, LATENCY_MS));

export async function fetchTodos(): Promise<Todo[]> {
  await delay();
  return db.map((todo) => ({ ...todo }));
}

export async function createTodo(title: string): Promise<Todo> {
  await delay();
  const todo: Todo = { id: crypto.randomUUID(), title, completed: false };
  db = [...db, todo];
  return { ...todo };
}

export async function toggleTodo(id: string): Promise<Todo> {
  await delay();
  db = db.map((todo) =>
    todo.id === id ? { ...todo, completed: !todo.completed } : todo,
  );
  const updated = db.find((todo) => todo.id === id);
  if (!updated) throw new Error(`Todo not found: ${id}`);
  return { ...updated };
}

export async function deleteTodo(id: string): Promise<void> {
  await delay();
  db = db.filter((todo) => todo.id !== id);
}

export function resetTodosDb(seed: Todo[] = []): void {
  db = seed.map((todo) => ({ ...todo }));
}
