// Compforge enforcement config — Feature-Sliced Design stack.
// Run with: npx steiger src
import fsd from '@feature-sliced/steiger-plugin';
import { defineConfig } from 'steiger';

export default defineConfig([
  ...fsd.configs.recommended,
  {
    // Test files and the vitest setup are not architecture surface.
    ignores: ['**/*.test.*', '**/testing/**'],
  },
  // Unlike the one-page example, this template keeps fsd/insignificant-slice
  // ON: in a real multi-page app a single-consumer slice is a genuine smell.
]);
