// Compforge enforcement config — FSD stack.
// Architecture (layers, public API, forbidden imports) is steiger.
// This file only blocks `any`. Managed by `compforge init`.
import tseslint from 'typescript-eslint';

export default [
  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: { '@typescript-eslint': tseslint.plugin },
    languageOptions: { parser: tseslint.parser },
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
    },
  },
];
