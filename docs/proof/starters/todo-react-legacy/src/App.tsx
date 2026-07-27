import { useEffect, useState, type FormEvent } from 'react';
import { createTodo, deleteTodo, fetchTodos, toggleTodo } from './api';
import { TodoPanel } from './components/TodoPanel';
import type { Todo } from './types';
import { formatCount } from './utils/format';

const FILTERS = ['all', 'active', 'completed'] as const;

type Filter = (typeof FILTERS)[number];

export default function App() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [visibleTodos, setVisibleTodos] = useState<Todo[]>([]);
  const [activeCount, setActiveCount] = useState(0);
  const [filter, setFilter] = useState<Filter>('all');
  const [draft, setDraft] = useState('');
  const [loading, setLoading] = useState(true);
  const [failed, setFailed] = useState(false);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    let cancelled = false;
    fetchTodos()
      .then((data) => {
        if (cancelled) return;
        setTodos(data);
        setFailed(false);
      })
      .catch(() => {
        if (!cancelled) setFailed(true);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (filter === 'active') {
      setVisibleTodos(todos.filter((todo) => !todo.completed));
    } else if (filter === 'completed') {
      setVisibleTodos(todos.filter((todo) => todo.completed));
    } else {
      setVisibleTodos(todos);
    }
  }, [todos, filter]);

  useEffect(() => {
    setActiveCount(todos.filter((todo) => !todo.completed).length);
  }, [todos]);

  async function reload() {
    const data = await fetchTodos();
    setTodos(data);
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const title = draft.trim();
    if (!title) return;
    setBusy(true);
    await createTodo(title);
    setDraft('');
    await reload();
    setBusy(false);
  }

  async function handleToggle(id: string) {
    setBusy(true);
    await toggleTodo(id);
    await reload();
    setBusy(false);
  }

  async function handleRemove(id: string) {
    setBusy(true);
    await deleteTodo(id);
    await reload();
    setBusy(false);
  }

  return (
    <main>
      <h1>Todos</h1>

      <form onSubmit={handleSubmit}>
        <label htmlFor="new-todo">New todo</label>
        <input
          id="new-todo"
          value={draft}
          onChange={(event) => setDraft(event.target.value)}
          placeholder="What needs doing?"
        />
        <button type="submit" disabled={busy || draft.trim().length === 0}>
          Add
        </button>
      </form>

      <div className="todo-filters">
        {FILTERS.map((option) => (
          <button
            key={option}
            type="button"
            aria-pressed={option === filter}
            onClick={() => setFilter(option)}
          >
            {option}
          </button>
        ))}
      </div>

      <TodoPanel
        todos={visibleTodos}
        loading={loading}
        failed={failed}
        onToggle={handleToggle}
        onRemove={handleRemove}
      />

      <p>{formatCount(activeCount, 'active item')}</p>
    </main>
  );
}
