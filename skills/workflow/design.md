---
name: workflow-design
description: Turn Discovery output into a component tree, state placement plan, and API contracts. No implementation.
tags: [workflow, react]
stability: experimental
---

# Workflow — Design

## When to use
After Discovery is approved. Before any folders or files are created.

## Checklist
- [ ] Component tree per screen (container/presentational split visible)
- [ ] State placement table: every piece of state → its home (derived / query / URL / store / local)
- [ ] Props crossing boundaries (name, type, direction)
- [ ] Query/mutation list with request/response types
- [ ] Custom hook candidates (logic that exists independent of UI)
- [ ] Error/loading/empty states named per screen

## Output

Save to `docs/design.md` in this format:

```markdown
# <Feature> — Design

## Component Tree
- CartPage
  - CartList
    - CartItem (props: item, onQuantityChange)
  - CartSummary (props: totals)

## State Placement
| State | Home | Why |
|---|---|---|
| cart items | query layer (`useCartQuery`) | server-owned |
| item count | derived | computable from items |
| coupon input | local (`CartSummary`) | one owner |

## Contracts
- `GET /cart` → `CartResponse { items: CartItem[] }`
- `PATCH /cart/items/:id` → quantity change, optimistic

## Hooks
- `useCart()` — read + mutations, wraps query layer

## UI States
- CartList: loading skeleton / empty ("cart is empty") / error retry
```

## Prohibited
- **No implementation** — types and signatures only, no bodies.
- **No styling decisions** beyond what Discovery's non-functional notes require.
- **No state without a home** — every piece of state appears in the placement table.

## Next step
After user approval -> `workflow-skeleton`
