# todo-react-next

The Compforge reference todo app on the **`react-next-app`** stack: Next.js
App Router, feature folders, and a **server/client import recipe**.

Same app, Vite stacks: [`todo-react-feature`](../todo-react-feature/),
[`todo-react-fsd`](../todo-react-fsd/).

## Run

```bash
npm install
npm run dev     # Next dev server
npm run check   # eslint zones + tsc + vitest + next build
```

## Server / client import recipe

| Layer | Directive | May import | Must not import |
|---|---|---|---|
| `src/app/page.tsx`, `layout.tsx` | none (Server Component) | features, `src/server/` | nothing client-only except as a child component |
| `src/server/` | `import 'server-only'` | Next server APIs | never imported by `features/` or `shared/` |
| `src/features/**` interactive files | `'use client'` | `shared/`, same feature, isomorphic `lib/` / `api/` | `src/server/`, `src/app/` |
| `src/shared/` | none, or `'use client'` if it uses hooks | nothing above itself | `src/server/`, `src/features/` |

Rules this example encodes:

1. **The page is a Server Component.** It composes `TodosScreen`. It may call
   `getRequestId()` from `src/server/`. It does not pass that value into client
   props. It **does** pass the serializable `filter` search param so the client
   URL hook can supply `getServerSnapshot` and SSR matches the bookmark.
2. **Interactive UI is a client island.** Hooks, forms, and TanStack Query live
   behind `'use client'`.
3. **Isomorphic modules have no directive.** `todosApi.ts` and `filterTodos.ts`
   are safe from both sides because they do not touch `next/headers` or `fs`.
4. **ESLint zones block the illegal arrows.** A feature file that imports
   `src/server/` fails `npm run lint`. `server-only` fails the Next build if
   the zone is bypassed.

```text
src/
├── app/                 # Server Components compose; providers.tsx is client
├── server/              # server-only — request/auth/fs. Not for features
├── features/todos/      # client island + isomorphic api/lib
├── shared/lib/          # URL subscription hook (client)
└── testing/
```

No barrel `index.ts` files — import files directly, same as `react-vite-feature`.

## What this example demonstrates

| Hard Rule | Where |
|---|---|
| Server state in the query layer | `useTodos.ts` (client) wraps TanStack Query |
| URL filter | `useTodoFilter.ts` → `useSearchParamState` |
| Derived totals at render | `TodosScreen.tsx` — zero sync effects |
| Server/client boundary | `page.tsx` vs `'use client'` + `src/server/` zone |
| Loading / empty / error | `TodoList.tsx` |
