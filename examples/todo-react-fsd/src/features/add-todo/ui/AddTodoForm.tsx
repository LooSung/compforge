import { useState } from 'react';
import { useAddTodo } from '../model/useAddTodo';

// The feature is self-contained: the form wires its own mutation. The page
// only places it. useAddTodo stays internal to the slice (not in index.ts).
export function AddTodoForm() {
  const { add } = useAddTodo();
  // Input draft is interaction state: local by design (state ladder rung 5).
  const [title, setTitle] = useState('');

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    const trimmed = title.trim();
    if (!trimmed) return;
    add(trimmed);
    setTitle('');
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        aria-label="New todo title"
        value={title}
        onChange={(event) => setTitle(event.target.value)}
        placeholder="What needs doing?"
      />
      <button type="submit">Add</button>
    </form>
  );
}
