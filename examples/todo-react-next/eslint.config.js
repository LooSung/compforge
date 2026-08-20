import importPlugin from 'eslint-plugin-import';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['.next', 'vitest.config.ts'] },
  ...tseslint.configs.recommended,
  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: { import: importPlugin },
    settings: {
      'import/resolver': {
        node: { extensions: ['.js', '.jsx', '.ts', '.tsx'] },
      },
    },
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      'import/no-restricted-paths': [
        'error',
        {
          zones: [
            {
              target: './src/features',
              from: './src/app',
              message:
                'Features must not import from app (unidirectional: shared <- features <- app).',
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
            {
              target: './src/features',
              from: './src/server',
              message:
                'Client features must not import server-only modules. Pass serializable props from a Server Component instead.',
            },
            {
              target: './src/shared',
              from: './src/server',
              message: 'Shared isomorphic modules must not import server-only code.',
            },
          ],
        },
      ],
    },
  },
);
