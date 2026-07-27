// Compforge enforcement config — feature-folder stack.
// Import this from eslint.config.js and spread it into the exported array,
// or use it directly on a fresh project. Managed by `compforge init`; the
// GENERATED block below is rewritten on re-run.
import importPlugin from 'eslint-plugin-import';
import tseslint from 'typescript-eslint';

export default [
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
            // BEGIN COMPFORGE GENERATED FEATURE ZONES (do not edit; re-run compforge init)
            // END COMPFORGE GENERATED FEATURE ZONES
          ],
        },
      ],
    },
  },
];
