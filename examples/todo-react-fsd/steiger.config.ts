import fsd from '@feature-sliced/steiger-plugin';
import { defineConfig } from 'steiger';

export default defineConfig([
  ...fsd.configs.recommended,
  {
    // Test files and the vitest setup are not architecture surface.
    ignores: ['**/*.test.*', '**/testing/**'],
  },
  {
    rules: {
      // A one-page demo has exactly one consumer for every slice, which this
      // rule flags on the whole tree (features and entities alike). The demo
      // intentionally keeps all layers visible. Keep the rule ON in real
      // multi-page apps — single-consumer slices there are a genuine smell.
      'fsd/insignificant-slice': 'off',
    },
  },
]);
