# Compforge templates

Enforcement, delivered. These files are what `compforge init`
(`scripts/setup/init.sh`) copies into a target project so that the
architecture rules the skills teach are also machine-checked there. They are
extracted from the runnable examples, where each one is exercised by CI.

| Template | Stack | Enforces |
|---|---|---|
| [`agents/compforge-block.md`](./agents/compforge-block.md) | all | the constitution pointer written into the target's `AGENTS.md` — where the pack lives, which entry point to use, what this repo is pinned to |
| [`react-vite-feature/eslint.compforge.config.js`](./react-vite-feature/eslint.compforge.config.js) | feature folders | unidirectional imports (shared ← features ← app), no cross-feature imports, no `any` |
| [`react-next-app/eslint.compforge.config.js`](./react-next-app/eslint.compforge.config.js) | Next.js App Router | the same, plus no server-only imports from `features/` or `shared/` |
| [`react-vite-fsd/steiger.config.ts`](./react-vite-fsd/steiger.config.ts) | Feature-Sliced Design | FSD layer rules via `@feature-sliced/steiger-plugin` |
| [`github/compforge-check.yml`](./github/compforge-check.yml) | all | **blocking** — runs the stack's check on every PR (`__COMPFORGE_CHECK_CMD__` is filled in by init) |
| [`github/compforge-architecture-review.yml`](./github/compforge-architecture-review.yml) | all | **non-blocking** — new-only detector findings + correction prompt |

The pointer stays thin on purpose: it names the pack and the pinned version, and
does **not** restate the Hard Rules. A copy of the rules in the target repository
goes stale on the next pack release — the drift this delivery exists to prevent.

Three rules carried over from the examples, learned the hard way:

- **The `.ts` resolver settings are load-bearing.** Without
  `settings['import/resolver'].node.extensions` including `.ts`/`.tsx`,
  `import/no-restricted-paths` resolves nothing and is silently a no-op.
  `compforge init` runs a negative self-test after copying — a deliberate
  violation must fail — so a silent no-op cannot survive an install.
- **Cross-feature zones are enumerated per feature**, generated from the
  directories that exist under `src/features/` at init time. Re-run init after
  adding a feature; the generated block is marked and regenerated idempotently.
- **Next is detected by dependency, not by folder.** A Next App Router project
  also has `src/features`, so a layout-only check reported `react-vite-feature`
  and installed zones with no `src/server` boundary — the self-test still passed,
  because it never tried a server-only import. `scripts/ci/init-smoke.sh` pins
  the detection result for all three examples.

The FSD template keeps `fsd/insignificant-slice` **on** — the example turns it
off only because a one-page demo has a single consumer for every slice.

Init never overwrites a file it did not generate: an existing
`eslint.config.js` stays untouched and init prints the merge snippet instead.
An existing `AGENTS.md` keeps everything outside the Compforge markers.

Re-run `compforge init --verify` at any time: it reads `compforge-lock.json`,
refuses a stack that has drifted from the lock, and re-runs the negative
self-test so a dead guard cannot pass unnoticed.
