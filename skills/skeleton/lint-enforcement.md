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
2. **Standard tools** — ESLint `import/no-restricted-paths` for feature folders,
   steiger (`@feature-sliced/steiger-plugin`) for FSD. Analyze the actual import
   graph to prove the same rules once more.

Do not invent a new tool; copy the files in `templates/` as the **canonical
template**. Details: `templates/README.md`.

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

## Feature-Sliced Design — steiger

Template: `templates/react-vite-fsd/steiger.config.ts`

The template keeps `fsd/insignificant-slice` **on**. The example turns it off
only because a one-page demo has a single consumer for every slice.

Run:

```bash
npx steiger ./src
```

## CI wiring

- Target projects: `templates/github/compforge-check.yml` (filled in by init).
- This pack: `.github/workflows/examples.yml` runs `npm run check` on the three
  examples (lint/arch + `tsc --noEmit` + vitest; Next also runs `next build`).

## Blocking policy

Say which gate fails the build. Do not leave it implied.

| Gate | Blocking? | What it checks |
|---|---|---|
| `compforge init` ESLint zones / `no-explicit-any` | **yes** | import direction, no `any` |
| `compforge init` steiger | **yes** | FSD public API and forbidden imports |
| Target `compforge-check.yml` | **yes** | the stack command above |
| Pack skill lint, doctor, smoke, examples `npm run check` | **yes** | pack integrity and reference apps |
| Architecture review (detector) | **no** | new-only 200-line files, extra exports, `any`, server data in `useState`, derived state in `useEffect` |

`compforge init` also copies `templates/github/compforge-architecture-review.yml`.
That workflow comments on the PR and always exits 0. Do not turn those
heuristic findings into a required check without a published proof that the
false-positive rate is acceptable.

Canonical MUST / SHOULD / NEVER: `skills/principles/hard-rules.md`.

## Prohibited

- Do not leave a boundary rule as a README sentence only and drop build enforcement.
- Do not ship zones without the `.ts` resolver — a delivered-but-dead guard is worse than none.
- Do not overwrite an `eslint.config.js` init did not generate; print a merge snippet instead.
- Do not silently promote detector findings to a blocking required check.
