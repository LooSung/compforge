# Cart — Compforge Walkthrough

> End-to-end **cart screen** in TypeScript + React.  
> Follow Discovery → Design → Delivery Plan → Skeleton → Implement → Test.

[English](./README.md) · [한국어](./README.ko.md)

This guide shows **how to use Compforge end to end** on one real screen. It is
not a third todo app. For the minimal runnable proof, see
[`examples/todo-react-feature`](../../../examples/todo-react-feature/).

A runnable Next example lives at
[`examples/todo-react-next`](../../../examples/todo-react-next/). It is not
this walkthrough.

---

## Scenario

A customer **reviews the cart**, changes quantities, and removes a line.
Totals update as they type. An empty cart is a distinct named state, not a
blank page. Checkout is out of scope.

---

## Craft Prompts

Claude Code:

```text
/compforge:craft Start Discovery for the cart screen. No code yet.
/compforge:craft Design the cart from docs/discovery.md. No code yet.
/compforge:craft Write a Delivery Plan for the cart. No code yet.
/compforge:craft Skeleton the cart for react-vite-feature. No business logic.
/compforge:craft Implement quantity change and remove on the cart.
/compforge:craft Test the cart hooks and the empty state.
```

Codex / Cursor — same words, `Use Compforge craft: …` (no leading `/`).

Pick **one** stack at Skeleton: `react-vite-feature` (this guide) or
`react-vite-fsd` (same Discovery/Design/Delivery Plan; folders change).

---

## Steps

| Step | File |
|---|---|
| 1. Discovery | [01-discovery.md](./01-discovery.md) |
| 2. Design | [02-design.md](./02-design.md) |
| 3. Delivery Plan | [03-delivery-plan.md](./03-delivery-plan.md) |
| 4. Skeleton | [04-skeleton.md](./04-skeleton.md) |
| 5. Implement | [05-implement.md](./05-implement.md) |
| 6. Test | [06-test.md](./06-test.md) |

---

## After each step

Compforge expects a **human checkpoint**. Do not skip to the next stage until
you approve the output. Ask in the customer's words: what changes, for whom,
what breaks.

After Implement, ask Craft to review against
[`skills/principles/hard-rules.md`](../../../skills/principles/hard-rules.md)
if you want a rule-violation pass.
