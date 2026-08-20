# Step 1 — Discovery

[English](./01-discovery.md) · [한국어](./README.ko.md)

> **No code.** Define language, flows, and screens only.

Read skill: `{pack}/skills/workflow/discovery.md`

Save output to: `docs/discovery.md` (in your project)

---

## Example output

```markdown
# Cart — Discovery

## Glossary
- **Cart**: items the customer intends to buy. Changeable until they leave
  for checkout (checkout is out of scope here).
- **Line**: one product in the cart, with a quantity.
- **Quantity**: how many of that product. At least one; zero means the line
  is gone.
- **Total**: what the customer would pay for the current lines. Not stored;
  it follows the lines.

## User Flows
1. Open cart → see lines, quantities, and the total.
2. Change a quantity → that line and the total update.
3. Remove a line → it disappears; if none remain, the empty cart is shown.
4. Arrive with no lines → empty cart, with a way back to shopping.

## Screens
- `/cart` — review lines, change quantity, remove, read the total.

## Server Data
- Cart lines come from the shop's cart API (load, change quantity, remove).
- Auth: whatever the shop already uses; this screen does not invent login.

## Non-Functional
- Named loading, empty, and error states. Quantity controls are keyboard
  usable and have accessible names.
- Mobile-first. Total stays readable while lines scroll.

## Open Questions
- Can quantity go above stock, or does the shop reject it?
- Guest cart, or signed-in only?
- Is the total allowed to include tax/shipping on this screen, or lines only?
```

---

## Checkpoint

Ask: *"Does this match how the cart should work for the customer — proceed
to Design?"*

Next: [02-design.md](./02-design.md)
