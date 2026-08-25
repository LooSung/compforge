# Step 6 — Test

Read skill: `{pack}/skills/workflow/test.md`

---

## What to run

From the app (not the Compforge pack):

```bash
npm run check   # lint/arch + tsc --noEmit + vitest
```

Minimum:

- Pure: `cartTotal` of zero, one, and many lines.
- Hook: quantity replace; remove last line → empty.
- Component: empty copy is distinct; quantity control has an accessible name.

If `compforge init` was run, the blocking ESLint/steiger check is part of
`npm run check`. Architecture review on a PR is **non-blocking**.

---

## Hard Rules pass

Spot-check [`skills/principles/hard-rules.md`](../../../skills/principles/hard-rules.md)
on the diff: 200 lines, one export, no `any`, lines not in `useState`, totals
not in `useEffect`.

---

## Cross-check the references

The runnable feature example uses the same mutation/invalidation boundary in
[`useTodos.ts`](../../../examples/todo-react-feature/src/features/todos/hooks/useTodos.ts).
Run all supported stacks using [`examples/README.md`](../../../examples/README.md).

---

## Done

The walkthrough ends here. Checkout and coupons are **not** this guide.
The Next reference app is [`examples/todo-react-next`](../../../examples/todo-react-next/).
