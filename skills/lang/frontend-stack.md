---
name: frontend-stack
description: Compforge stack scope gate and architecture selection - TypeScript + React (Vite or Next.js), feature folders or feature-sliced design.
tags: [react, typescript, architecture]
stability: experimental
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

## Baseline choices (all stacks)

- TypeScript `strict: true`.
- Server state: TanStack Query (or the framework's loader/server-component equivalent).
- Client shared state: Zustand or context — only when two distant components truly share it.
- Styling: follow the target project's existing approach; for greenfield, CSS Modules unless the user prefers otherwise (state the default).
- Testing: Vitest + Testing Library; Playwright for E2E.

## Import direction (all stacks)

```
shared  ←  entities  ←  features  ←  pages/app
```

Lower layers never import from higher layers. Features never import sibling feature internals — public API (`index.ts`) only.
