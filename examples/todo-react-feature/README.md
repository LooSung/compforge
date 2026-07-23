# todo-react-feature

The Compforge reference todo app on the **`react-vite-feature`** stack: feature folders, composed at the app level, no cross-feature imports, no barrel files.

Same app, different architecture: [`todo-react-fsd`](../todo-react-fsd/).

## Run

```bash
npm install
npm run dev     # Vite dev server
npm run check   # eslint (incl. boundary zones) + tsc + vitest
```

## What this example demonstrates

| Hard Rule | Where |
|---|---|
| Server state in the query layer | `features/todos/hooks/useTodos.ts` wraps TanStack Query; components never touch the API module |
| URL state for bookmarkable UI | `features/todos/hooks/useTodoFilter.ts` → `shared/lib/useSearchParamState.ts` (`useSyncExternalStore`, a legitimate external-system sync) |
| Local state only for interaction drafts | `AddTodoForm` input draft |
| Derived state never stored | `App.tsx` computes `visible` and `activeCount` at render — zero sync effects in the whole app |
| Components render; hooks decide | components receive values + intent methods (`add`, `toggle`, `remove`) |
| Unidirectional imports, no cross-feature imports | `eslint.config.js` `import/no-restricted-paths` zones (bulletproof-react pattern) |
| Loading / empty / error as named states | `TodoList.tsx` |
| Logic hooks ship with tests | `useTodos.test.tsx`, `filterTodos.test.ts`, `App.test.tsx` |

## Structure

```text
src/
├── app/            # composition point: providers + App wiring features together
├── features/todos/ # api / hooks / components / lib / types for the one feature
├── shared/lib/     # useSearchParamState — generic, feature-agnostic
└── testing/        # vitest setup
```

Note: no `index.ts` barrels — this stack imports files directly (Vite tree-shaking; see `skills/skeleton/frontend-skeleton.md`).
