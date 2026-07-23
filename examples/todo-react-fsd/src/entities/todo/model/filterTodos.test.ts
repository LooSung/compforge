import { describe, expect, it } from 'vitest';
import { countActive, filterTodos } from './filterTodos';
import type { Todo } from './types';

const todos: Todo[] = [
  { id: '1', title: 'open thing', completed: false },
  { id: '2', title: 'done thing', completed: true },
];

describe('filterTodos', () => {
  it('returns everything for all', () => {
    expect(filterTodos(todos, 'all')).toHaveLength(2);
  });

  it('returns only unfinished todos for active', () => {
    expect(filterTodos(todos, 'active').map((todo) => todo.id)).toEqual(['1']);
  });

  it('returns only finished todos for completed', () => {
    expect(filterTodos(todos, 'completed').map((todo) => todo.id)).toEqual(['2']);
  });
});

describe('countActive', () => {
  it('counts unfinished todos', () => {
    expect(countActive(todos)).toBe(1);
  });

  it('is zero for an empty list', () => {
    expect(countActive([])).toBe(0);
  });
});
