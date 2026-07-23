import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it } from 'vitest';
import { resetTodosDb } from '../features/todos/api/todosApi';
import { App } from './App';
import { AppProviders } from './providers';

function renderApp() {
  return render(
    <AppProviders>
      <App />
    </AppProviders>,
  );
}

describe('App', () => {
  beforeEach(() => {
    resetTodosDb();
  });

  it('shows the empty state after loading', async () => {
    renderApp();
    expect(await screen.findByText(/no todos yet/i)).toBeInTheDocument();
  });

  it('adds a todo through the form', async () => {
    const user = userEvent.setup();
    renderApp();
    await screen.findByText(/no todos yet/i);

    await user.type(
      screen.getByRole('textbox', { name: /new todo title/i }),
      'ship example',
    );
    await user.click(screen.getByRole('button', { name: /^add$/i }));

    expect(await screen.findByText('ship example')).toBeInTheDocument();
    expect(screen.getByText(/1 active/i)).toBeInTheDocument();
  });

  it('filters via the URL-backed filter state', async () => {
    resetTodosDb([
      { id: '1', title: 'done thing', completed: true },
      { id: '2', title: 'open thing', completed: false },
    ]);
    const user = userEvent.setup();
    renderApp();
    expect(await screen.findByText('done thing')).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: 'active' }));

    expect(screen.queryByText('done thing')).not.toBeInTheDocument();
    expect(screen.getByText('open thing')).toBeInTheDocument();
    expect(window.location.search).toContain('filter=active');
  });
});
