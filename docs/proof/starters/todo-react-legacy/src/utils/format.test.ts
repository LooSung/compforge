import { describe, expect, it } from 'vitest';
import { formatCount } from './format';

describe('formatCount', () => {
  it('keeps the noun singular for one', () => {
    expect(formatCount(1, 'active item')).toBe('1 active item');
  });

  it('pluralizes everything else', () => {
    expect(formatCount(0, 'active item')).toBe('0 active items');
    expect(formatCount(3, 'active item')).toBe('3 active items');
  });
});
