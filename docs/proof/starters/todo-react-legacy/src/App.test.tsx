import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it } from 'vitest';
import App from './App';
import { resetTodosDb } from './api';

describe('App', () => {
  beforeEach(() => {
    resetTodosDb([
      { id: '1', title: 'Write the spec', completed: false },
      { id: '2', title: 'Ship the release', completed: true },
    ]);
  });

  it('shows the todos it loads', async () => {
    render(<App />);

    expect(await screen.findByText('Write the spec')).toBeInTheDocument();
    expect(screen.getByText('Ship the release')).toBeInTheDocument();
  });

  it('adds a todo', async () => {
    const user = userEvent.setup();
    render(<App />);
    await screen.findByText('Write the spec');

    await user.type(screen.getByLabelText('New todo'), 'Book the venue');
    await user.click(screen.getByRole('button', { name: 'Add' }));

    expect(await screen.findByText('Book the venue')).toBeInTheDocument();
  });

  it('filters to active todos', async () => {
    const user = userEvent.setup();
    render(<App />);
    await screen.findByText('Ship the release');

    await user.click(screen.getByRole('button', { name: 'active' }));

    await waitFor(() => {
      expect(screen.queryByText('Ship the release')).not.toBeInTheDocument();
    });
    expect(screen.getByText('Write the spec')).toBeInTheDocument();
  });
});
