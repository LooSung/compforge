---
name: lint-enforcement
description: How to enforce feature/FSD boundary rules in CI with ESLint zones or steiger. Add machine enforcement so guidance alone does not collapse.
tags: [lint, ci, react, eslint, steiger]
stability: stable
---

# Lint Enforcement

## When to use

When you want to enforce feature or FSD boundary rules **via the build, not docs**.
Self-checks and reviews can be missed, so block the core project rules automatically.

Stack it in two layers:

1. **Delivered gate** — `compforge init` (`scripts/setup/init.sh`) copies the
   stack template and a GitHub Actions check, then runs a **negative self-test**:
   a deliberate cross-feature import must fail, or init refuses to succeed.
   It also refuses a tsconfig that does not set `compilerOptions.strict` to
   true, and every stack self-tests `no-explicit-any`.
2. **Standard tools** — ESLint `import/no-restricted-paths` for feature folders,
   steiger (`@feature-sliced/steiger-plugin`) for FSD. Analyze the actual import
   graph to prove the same rules once more.

Do not invent a new tool; copy the files in `templates/` as the **canonical
template**. Details: `templates/README.md`.

Init also writes the constitution pointer (`AGENTS.md`) and `compforge-lock.json`
so an agent that clones only the target repo learns to read the pack. See
`skills/workflow/craft.md` for what it then reads.

## Feature folders — ESLint zones

Template: `templates/react-vite-feature/eslint.compforge.config.js`

- Unidirectional imports: `shared ← features ← app`.
- No cross-feature imports. Zones are enumerated from `src/features/` at init
  time; re-run init after adding a feature.
- No `any`. The `.ts` resolver settings are load-bearing — without
  `.ts`/`.tsx` extensions the zone rule is silently a no-op.

Run:

```bash
npm run lint
```

## Next.js App Router — ESLint zones

Template: `templates/react-next-app/eslint.compforge.config.js`

Everything the feature template enforces, plus the boundary that only exists on
this stack: `features/` and `shared/` must not import `src/server/`. Pass
serializable props down from a Server Component instead.

Detection is by the `next` dependency, not by folder layout — a Next project also
has `src/features`, so a layout-only check installs the vite zones and silently
drops the server boundary.

## Feature-Sliced Design — steiger + `any`

Templates: `templates/react-vite-fsd/steiger.config.ts` and
`templates/react-vite-fsd/eslint.compforge.config.js`

Steiger owns layers and forbidden imports. The ESLint file only blocks `any` —
FSD does not get import zones. The template keeps `fsd/insignificant-slice`
**on**. The example turns it off only because a one-page demo has a single
consumer for every slice.

Run:

```bash
npx steiger ./src
npx eslint --config eslint.compforge.config.js src
```

## TypeScript `strict` and `tsc`

`compilerOptions.strict` must be `true` in the project's `tsconfig.json`. Init
does not rewrite that file, and it does not follow `extends`. `tsc --noEmit` is
the project's job — init prints a snippet if no script runs it. Examples include
it in `npm run check`.

## Staying alive

A delivered guard is only worth the last time it was proven to fail:

```bash
{pack}/scripts/setup/init.sh --verify
```

Reads `compforge-lock.json`, refuses a stack that drifted from the lock, warns on
a pack-version mismatch, refuses a tsconfig without `strict: true`, and re-runs
the negative self-test.

## CI wiring

- Target projects: `templates/github/compforge-check.yml` (filled in by init).
- This pack: `.github/workflows/examples.yml` runs `npm run check` on the three
  examples (lint/arch + `tsc --noEmit` + vitest; Next also runs `next build`),
  then `scripts/ci/init-smoke.sh` — stack detection, delivery, self-test,
  idempotent re-run, drift refusal, a pack with the server zones removed,
  a tsconfig with `strict: false`, and an FSD template that lost
  `no-explicit-any`, all of which **must** be rejected.

## Blocking policy

Say which gate fails the build. Do not leave it implied.

| Gate | Blocking? | What it checks |
|---|---|---|
| `compforge init` ESLint zones / `no-explicit-any` | **yes** | import direction, no `any`, no server-only imports on Next |
| `compforge init` FSD steiger + `no-explicit-any` | **yes** | FSD public API, forbidden imports, no `any` |
| `compforge init` `strict: true` | **yes** | `tsconfig.json` must set it; init does not rewrite tsconfig |
| `tsc --noEmit` | project's job | init prints a snippet; examples run it in `npm run check` |
| Target `compforge-check.yml` | **yes** | the stack command above |
| Pack skill lint, doctor, smoke, init smoke, examples `npm run check` | **yes** | pack integrity, delivery, and reference apps |
| Architecture review (detector) | **no** | new-only 200-line files, extra exports, `any`, server data in `useState`, derived state in `useEffect` |
| Accessibility review (detector) | **no** | new-only unnamed controls, unlabelled form controls, click targets with no keyboard path |

`compforge init` also copies `templates/github/compforge-architecture-review.yml`.
That workflow comments on the PR and always exits 0. Do not turn those
heuristic findings into a required check without a published proof that the
false-positive rate is acceptable.

The accessibility rules are a **text scan of JSX**, so they prove those three
rules and nothing more. A clean run is not an accessibility audit, and ambiguous
markup (a child expression, an id the scan cannot resolve) stays silent on
purpose. Names, roles, focus, and keyboard paths remain Craft requirements
beyond what this catches.

Canonical MUST / SHOULD / NEVER: `skills/principles/hard-rules.md`.

## Prohibited

- Do not leave a boundary rule as a README sentence only and drop build enforcement.
- Do not ship zones without the `.ts` resolver — a delivered-but-dead guard is worse than none.
- Do not claim `strict: true` or no `any` on a stack whose init self-test does not prove it.
- Do not overwrite an `eslint.config.js` init did not generate; print a merge snippet instead.
- Do not overwrite a hand-written `AGENTS.md`; only the marked block is rewritten.
- Do not copy the Hard Rules into the target repository — pin the pack and link.
- Do not detect Next by folder layout; a missing `src/server` zone still self-tests green.
- Do not silently promote detector findings to a blocking required check.
