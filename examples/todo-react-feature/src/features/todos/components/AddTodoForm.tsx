import { useState } from 'react';

interface AddTodoFormProps {
  onAdd: (title: string) => void;
}

export function AddTodoForm({ onAdd }: AddTodoFormProps) {
  // Input draft is interaction state: local by design (state ladder rung 5).
  const [title, setTitle] = useState('');

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    const trimmed = title.trim();
    if (!trimmed) return;
    onAdd(trimmed);
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
