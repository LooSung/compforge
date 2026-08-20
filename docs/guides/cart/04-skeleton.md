# Step 4 — Skeleton

> **No business logic.** Folders, typed empty components and hooks.

Read skills: `{pack}/skills/workflow/skeleton.md`,
`{pack}/skills/skeleton/frontend-skeleton.md`,
`{pack}/skills/lang/frontend-stack.md`

This guide uses **`react-vite-feature`**. If you chose FSD at the checkpoint,
keep the same names behind slice public APIs.

---

## Example tree

```text
src/
  app/CartPage.tsx
  features/cart/
    CartList.tsx
    CartLine.tsx
    CartTotal.tsx
    CartEmpty.tsx
    CartStatus.tsx
    useCart.ts
    totals.ts
    types.ts
```

Empty components: props typed, body a placeholder. `useCart` signature typed;
body throws or returns a fixture. `tsc --noEmit` passes. No cross-feature
imports. No app-wide `components/` dump.

---

## Self-check

Print the tree. Confirm:

- `cart` is its own feature folder.
- Pages compose; they do not own totals or mutations.
- No file contains quantity math yet.

---

## Checkpoint

Ask: *"Does this folder layout match the cart Design — proceed to Implement?"*

Next: [05-implement.md](./05-implement.md)
