// Compforge enforcement config — Next.js App Router stack.
// Import this from eslint.config.js and spread it into the exported array,
// or use it directly on a fresh project. Managed by `compforge init`; the
// GENERATED block below is rewritten on re-run.
import importPlugin from 'eslint-plugin-import';
import tseslint from 'typescript-eslint';

export default [
  { ignores: ['.next'] },
  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: { import: importPlugin, '@typescript-eslint': tseslint.plugin },
    languageOptions: { parser: tseslint.parser },
    settings: {
      // The default node resolver does not resolve .ts/.tsx imports, which
      // silently disables no-restricted-paths. Verified with a negative test;
      // `compforge init` re-verifies on every install.
      'import/resolver': {
        node: { extensions: ['.js', '.jsx', '.ts', '.tsx'] },
      },
    },
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      // Compforge Hard Rule: unidirectional imports (shared <- features <- app),
      // no cross-feature imports, and no server-only code in client modules.
      // src/app holds the App Router; src/server holds server-only modules.
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
            // BEGIN COMPFORGE GENERATED FEATURE ZONES (do not edit; re-run compforge init)
            // END COMPFORGE GENERATED FEATURE ZONES
          ],
        },
      ],
    },
  },
];
