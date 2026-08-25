# Compforge Examples

Runnable proof: the **same todo app** implemented once per supported stack. The examples exist to validate the canonical [Hard Rules](../skills/principles/hard-rules.md) — a rule the examples cannot satisfy gets fixed or dropped, not ignored.

| Stack | Folder | Architecture | Enforcement |
|---|---|---|---|
| `react-vite-feature` | [todo-react-feature](./todo-react-feature/) | Feature folders, app-level composition, no barrels | ESLint `import/no-restricted-paths` zones |
| `react-vite-fsd` | [todo-react-fsd](./todo-react-fsd/) | Feature-Sliced Design layers + slice public APIs | steiger + ESLint `no-explicit-any` |
| `react-next-app` | [todo-react-next](./todo-react-next/) | Next.js App Router + feature folders | ESLint zones, including no import of `src/server` |

Walkthrough (not a third todo): [docs/guides/cart](../docs/guides/cart/README.md) — Discovery → Test on a cart screen.

Each example runs the same gate:

```bash
npm install
npm run check   # lint/arch + tsc --noEmit + vitest (+ next build on Next)
```

## What stays identical across examples

- The app: add / toggle / delete / filter todos, active count.
- State placement: server data in TanStack Query, filter in the URL (`useSearchParamState` via `useSyncExternalStore`), input draft local, counts derived at render. **Zero `useEffect` in application code.**
- Named loading / empty / error states.
- Tests at three levels: pure function, hook (`renderHook`), page/app (Testing Library + user-event).

## What differs on purpose

- **Granularity**: one `features/todos/` folder vs three FSD slices (`entities/todo`, `features/add-todo`, `features/filter-todos`) — the honest cost/benefit of each architecture on an app this size.
- **Import discipline**: direct file imports and no cross-feature imports vs slice public APIs (`index.ts`).
- **Enforcement tool**: ESLint zones vs steiger plus `no-explicit-any`.
- **Server/client boundary** (Next only): Server Components compose; interactive UI is a `'use client'` island; `src/server/` is never imported by features.

Read all three example `README.md` files side by side to see the trade-off the stack table in `skills/lang/frontend-stack.md` describes.
