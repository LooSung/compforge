---
name: frontend-stack
description: Compforge stack scope gate and architecture selection - TypeScript + React (Vite or Next.js), feature folders or feature-sliced design.
tags: [react, typescript, architecture]
stability: stable
---

# Frontend Stack Selection

## Scope gate (check first)

Supported today: **TypeScript + React**.

| Request | Action |
|---|---|
| TypeScript + React | Proceed; pick a stack below |
| Language/stack unspecified | Steer to TypeScript + React; state the default visibly |
| JavaScript (no TS) React | Recommend TS; proceed plain-JS only if the user insists (note the risk) |
| Vue | **Planned, not yet supported** — say so; do not apply Compforge rules to Vue code |
| Angular, Svelte, mobile-native, backend | Compforge does not apply; plain task only if the user insists |

## Stack identifiers

| Stack | Architecture | When |
|---|---|---|
| `react-vite-feature` | Feature folders (`features/<name>/` with components, hooks, api per feature) | Small/medium apps, MVP, single team |
| `react-vite-fsd` | Feature-Sliced Design layers (`app/pages/widgets/features/entities/shared`) | Complex apps, larger teams, long-lived codebases |
| `react-next-app` | Next.js App Router + feature folders | SSR/SEO needs, server components |

Default when the user has no preference: **`react-vite-feature`** — smallest structure that still has boundaries. State the default; do not pick silently.

## Selection questions (ask at most 2)

1. **SSR/SEO needed?** yes → `react-next-app`; no → Vite.
2. **More than ~5 feature areas or multiple teams?** yes → `-fsd`; no → `-feature`.

## Complexity ladder

Start thin. Step up one rung only when question 2 is yes.

| Rung | Stack | Structure |
|---|---|---|
| Default | `react-vite-feature`, or `react-next-app` when SSR is required | `app/`, `features/<name>/`, `shared/` |
| One step thicker | `react-vite-fsd` | adds `pages/`, `widgets/`, `entities/` |

- Do not start a small screen or MVP on FSD.
- Do not invent a third, thicker layout above `react-vite-fsd`.
- Next.js is the SSR axis, not a rung: there is no `react-next-fsd`. A Next app
  that outgrows feature folders is a separate decision, not this ladder.
- Add `pages/`, `widgets/`, or `entities/` when reuse actually appears, not to
  reserve room for it.

## Baseline choices (all stacks)

- TypeScript `strict: true`.
- Server state: TanStack Query (or the framework's loader/server-component equivalent).
- Client shared state: Zustand or context — only when two distant components truly share it.
- Styling: follow the target project's existing approach; for greenfield, CSS Modules unless the user prefers otherwise (state the default).
- Testing: Vitest + Testing Library (hooks and DOM). Playwright is not the default.

## Import direction

Lower layers never import from higher layers. The layers themselves differ per rung —
feature stacks have no `entities/` or `pages/`.

`react-vite-feature`, `react-next-app`:

```
shared  ←  features  ←  app
```

`react-vite-fsd`:

```
shared  ←  entities  ←  features  ←  widgets  ←  pages  ←  app
```

Cross-feature imports:

- `react-vite-feature`: **forbidden** — compose features at the app level; no barrel `index.ts` (Vite tree-shaking). Enforce with ESLint `import/no-restricted-paths`.
- `react-vite-fsd`: through each slice's public API (`index.ts`) only. Enforce with steiger; `any` with ESLint.
- `react-next-app`: same as feature folders, plus features/shared never import `src/server` or `src/app`. Pass serializable props from a Server Component. Reference: `examples/todo-react-next/`.
