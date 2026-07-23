# Compforge Examples

Runnable proof: the **same todo app** implemented once per supported stack. The examples exist to validate the Hard Rules in [`AGENTS.md`](../AGENTS.md) — a rule the examples cannot satisfy gets fixed or dropped, not ignored.

| Stack | Folder | Architecture | Enforcement |
|---|---|---|---|
| `react-vite-feature` | [todo-react-feature](./todo-react-feature/) | Feature folders, app-level composition, no barrels | ESLint `import/no-restricted-paths` zones |
| `react-vite-fsd` | [todo-react-fsd](./todo-react-fsd/) | Feature-Sliced Design layers + slice public APIs | steiger (`@feature-sliced/steiger-plugin`) |
| `react-next-app` | *planned* | Next.js App Router + feature folders | *planned* |

Each example runs the same gate:

```bash
npm install
npm run check   # lint/arch + tsc --noEmit + vitest
```

## What stays identical across examples

- The app: add / toggle / delete / filter todos, active count.
- State placement: server data in TanStack Query, filter in the URL (`useSearchParamState` via `useSyncExternalStore`), input draft local, counts derived at render. **Zero `useEffect` in application code.**
- Named loading / empty / error states.
- Tests at three levels: pure function, hook (`renderHook`), page/app (Testing Library + user-event).

## What differs on purpose

- **Granularity**: one `features/todos/` folder vs three FSD slices (`entities/todo`, `features/add-todo`, `features/filter-todos`) — the honest cost/benefit of each architecture on an app this size.
- **Import discipline**: direct file imports and no cross-feature imports vs slice public APIs (`index.ts`).
- **Enforcement tool**: ESLint zones vs steiger.

Read both `README.md`s side by side to see the trade-off the stack table in `skills/lang/frontend-stack.md` describes.
