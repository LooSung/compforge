# Compforge templates

Enforcement, delivered. These files are what `compforge init`
(`scripts/setup/init.sh`) copies into a target project so that the
architecture rules the skills teach are also machine-checked there. They are
extracted from the runnable examples, where each one is exercised by CI.

| Template | Stack | Enforces |
|---|---|---|
| [`react-vite-feature/eslint.compforge.config.js`](./react-vite-feature/eslint.compforge.config.js) | feature folders | unidirectional imports (shared ← features ← app), no cross-feature imports, no `any` |
| [`react-vite-fsd/steiger.config.ts`](./react-vite-fsd/steiger.config.ts) | Feature-Sliced Design | FSD layer rules via `@feature-sliced/steiger-plugin` |
| [`github/compforge-check.yml`](./github/compforge-check.yml) | both | runs the stack's check on every PR (`__COMPFORGE_CHECK_CMD__` is filled in by init) |

Two rules carried over from the examples, learned the hard way:

- **The `.ts` resolver settings are load-bearing.** Without
  `settings['import/resolver'].node.extensions` including `.ts`/`.tsx`,
  `import/no-restricted-paths` resolves nothing and is silently a no-op.
  `compforge init` runs a negative self-test after copying — a deliberate
  violation must fail — so a silent no-op cannot survive an install.
- **Cross-feature zones are enumerated per feature**, generated from the
  directories that exist under `src/features/` at init time. Re-run init after
  adding a feature; the generated block is marked and regenerated idempotently.

The FSD template keeps `fsd/insignificant-slice` **on** — the example turns it
off only because a one-page demo has a single consumer for every slice.

Init never overwrites a file it did not generate: an existing
`eslint.config.js` stays untouched and init prints the merge snippet instead.
