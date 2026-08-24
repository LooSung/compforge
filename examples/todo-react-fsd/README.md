# todo-react-fsd

The Compforge reference todo app on the **`react-vite-fsd`** stack: Feature-Sliced Design layers, slice public APIs (`index.ts`), architecture enforced by [steiger](https://github.com/feature-sliced/steiger), `any` blocked by ESLint.

Same app, different architecture: [`todo-react-feature`](../todo-react-feature/).
Same app on Next: [`todo-react-next`](../todo-react-next/).

## Run

```bash
npm install
npm run dev     # Vite dev server
npm run check   # lint + tsc + vitest + steiger
```

## What this example demonstrates (beyond the feature-stack version)

| Concern | Where |
|---|---|
| Layer system | `app → pages → features → entities → shared`, imports only point down |
| Slice public APIs | every slice exposes `index.ts`; `useAddTodo` stays private to its slice while `AddTodoForm` is public |
| Entity vs feature split | `entities/todo` owns the domain (types, query layer, presentational UI); `features/add-todo` and `features/filter-todos` own user interactions |
| Self-contained features | `AddTodoForm` and `TodoFilterButtons` wire their own state; the page only places them |
| Single source of truth across slices | page and filter feature both read the URL — nothing to sync |
| Mechanical enforcement | `npm run lint` (`no-explicit-any`) and `npm run arch` (steiger) |

## Structure

```text
src/
├── app/                    # providers + App (renders the page)
├── pages/todos/            # composition only — no business logic
├── features/add-todo/      # ui/ + model/ (mutation hook, slice-private)
├── features/filter-todos/  # ui/ + model/ (URL-backed filter)
├── entities/todo/          # api/ + model/ (types, queries, filters) + ui/
└── shared/                 # lib/ (useSearchParamState) + testing/
```

## When to prefer this over `react-vite-feature`

More than ~5 feature areas, multiple teams, or long-lived codebases — the layer
contract keeps growth predictable at the cost of more files per change
(this same app needs 3 slices here vs 1 feature folder there).
