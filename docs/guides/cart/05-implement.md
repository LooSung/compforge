# Step 5 — Implement

> One behavior at a time. Hooks first, with tests. Components render.

Read skills: `{pack}/skills/workflow/implement.md`,
`{pack}/skills/playbooks/feature.md`,
`{pack}/skills/principles/hard-rules.md`

---

## Order (from the Delivery Plan)

1. Types already in the skeleton.
2. Query layer + `useCart` tests (load, replace quantity, remove).
3. `cartTotal` / `lineTotal` tests, then the functions.
4. `CartLine` quantity and remove (accessible names).
5. `CartPage` composes loading / empty / error / lines.

## Wiring

- `app/providers.tsx` owns the query client.
- `useCart` is the feature's only query/mutation door and invalidates the cart
  query after writes.
- `CartPage` composes query status and the derived empty branch; presentational
  components receive data and callbacks.

Do **not** store totals in `useState`. Do **not** sync lines in `useEffect`.
Quantity while typing stays on `CartLine`. Failed stock updates surface through
the mutation error state, not a second copy of the line.

Craft prompt:

```text
Use Compforge craft: Implement quantity change and remove on the cart.
Keep totals derived. Empty cart is a named state.
```

---

## Checkpoint

Ask: *"Can the customer change a quantity and empty the cart — proceed to Test?"*

Next: [06-test.md](./06-test.md)
