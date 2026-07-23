import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it } from 'vitest';
import { AppProviders } from '../../../app/providers';
import { resetTodosDb } from '../../../entities/todo';
import { TodosPage } from './TodosPage';

function renderPage() {
  return render(
    <AppProviders>
      <TodosPage />
    </AppProviders>,
  );
}

describe('TodosPage', () => {
  beforeEach(() => {
    resetTodosDb();
  });

  it('shows the empty state after loading', async () => {
    renderPage();
    expect(await screen.findByText(/no todos yet/i)).toBeInTheDocument();
  });

  it('adds a todo through the add-todo feature', async () => {
    const user = userEvent.setup();
    renderPage();
    await screen.findByText(/no todos yet/i);

    await user.type(
      screen.getByRole('textbox', { name: /new todo title/i }),
      'ship fsd example',
    );
    await user.click(screen.getByRole('button', { name: /^add$/i }));

    expect(await screen.findByText('ship fsd example')).toBeInTheDocument();
    expect(screen.getByText(/1 active/i)).toBeInTheDocument();
  });

  it('filters via the URL-backed filter feature', async () => {
    resetTodosDb([
      { id: '1', title: 'done thing', completed: true },
      { id: '2', title: 'open thing', completed: false },
    ]);
    const user = userEvent.setup();
    renderPage();
    expect(await screen.findByText('done thing')).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: 'active' }));

    expect(screen.queryByText('done thing')).not.toBeInTheDocument();
    expect(screen.getByText('open thing')).toBeInTheDocument();
    expect(window.location.search).toContain('filter=active');
  });
});
