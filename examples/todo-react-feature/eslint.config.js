import importPlugin from 'eslint-plugin-import';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['dist'] },
  ...tseslint.configs.recommended,
  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: { import: importPlugin },
    settings: {
      // The default node resolver does not resolve .ts/.tsx imports, which
      // silently disables no-restricted-paths. Verified with a negative test.
      'import/resolver': {
        node: { extensions: ['.js', '.jsx', '.ts', '.tsx'] },
      },
    },
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      // Compforge Hard Rule: unidirectional imports (shared <- features <- app)
      // and no cross-feature imports. Pattern from bulletproof-react.
      'import/no-restricted-paths': [
        'error',
        {
          zones: [
            {
              target: './src/features',
              from: './src/app',
              message: 'Features must not import from app (unidirectional: shared <- features <- app).',
            },
            {
              target: './src/shared',
              from: './src/features',
              message: 'Shared must not import from features.',
            },
            {
              target: './src/shared',
              from: './src/app',
              message: 'Shared must not import from app.',
            },
            {
              target: './src/features/todos',
              from: './src/features',
              except: ['./todos'],
              message: 'No cross-feature imports; compose features at the app level.',
            },
          ],
        },
      ],
    },
  },
);
