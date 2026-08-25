# Step 3 — Delivery Plan

> **No code.** One execution plan: scope, order, tests, risks.

Read skill: `{pack}/skills/workflow/delivery-plan.md`

Save output to: `docs/delivery-plan.md` (in your project)

---

## Example output

```markdown
# Cart — Delivery Plan

## Problem 1-Pager
- Background: the shop has a cart API; the screen is a 600-line page risk.
- Problem: quantity and remove must not become client copies of server lines.
- Goal: one cart screen the customer can review, change, and empty.
- Non-goals: checkout, coupons, tax/shipping, product catalog.
- Constraints: Compforge Hard Rules; TypeScript + React.

## Scope
- In: load lines, change quantity, remove, derived total, named UI states.
- Out: payment, guest-vs-auth decision (stay on current shop session).

## Contract
- Screens / routes: `/cart`
- Queries / mutations: GET/PATCH/DELETE as in Design
- URL state: none
- Errors / empty / loading: named on CartStatus / CartEmpty
- Mutations invalidate or optimistically update the cart query; totals remain derived

## Responsibility Map
| Concern | Page | Feature | Hook | Query |
|---|---|---|---|---|
| compose states | CartPage | | | |
| lines + actions | | cart | useCart | cart query |
| totals | | cart | | pure functions |

## Implementation Order
1. Types / contracts
2. Query layer and `useCart` (with tests)
3. Pure totals (with tests)
4. Presentational CartLine / CartTotal / CartEmpty
5. CartPage composition
6. Accessibility names and keyboard on quantity/remove

## Test Plan
- Unit: `cartTotal`, quantity replace, remove
- Component: empty copy, quantity change, remove
- Connected (manual): load the cart against the shop API; not an E2E suite

## Review / Merge / Release
- Review: 200 lines, one export, no `any`, no derived-in-effect
- Rollback: revert the cart feature folder; API unchanged

## Open Questions
- Stock 409 handling: show the shop's message, or clamp quantity?
```

---

## Checkpoint

Ask: *"Is this the cart you want built — proceed to Skeleton?"*

Next: [04-skeleton.md](./04-skeleton.md)
