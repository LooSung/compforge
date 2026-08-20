# Step 2 — Design

> **No implementation.** Tree, state homes, and contracts only.

Read skill: `{pack}/skills/workflow/design.md`

Save output to: `docs/design.md` (in your project)

---

## Example output

```markdown
# Cart — Design

## Component Tree
- CartPage
  - CartList
    - CartLine (props: line, onQuantityChange, onRemove)
  - CartTotal (props: total)
  - CartEmpty
  - CartStatus (loading / error retry)

## State Placement
| State | Home | Why |
|---|---|---|
| lines | query layer | shop-owned cart |
| total, line count | derived | computable from lines |
| quantity field while typing | local on CartLine | one owner, not the URL |
| empty/loading/error | query status + derived length | not extra flags |

## Contracts
- `GET /cart` → `{ lines: { id, title, unitPrice, quantity }[] }`
- `PATCH /cart/lines/:id` → `{ quantity }` (replace, not increment)
- `DELETE /cart/lines/:id`
- Errors: 409 if quantity exceeds stock (Open Question from Discovery)

## Hooks
- `useCart()` — read lines, change quantity, remove. Wraps the query layer.
- `lineTotal(line)`, `cartTotal(lines)` — pure.

## UI States
- CartList: loading / lines / empty ("Your cart is empty") / error retry
- CartLine: quantity control named; remove named
```

---

## Checkpoint

Ask: *"Are the state homes right — proceed to Delivery Plan?"*

Next: [03-delivery-plan.md](./03-delivery-plan.md)
