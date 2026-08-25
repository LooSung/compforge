# Step 7 — Import Rules

Implementation is complete only when the selected stack's dependency direction
still holds.

## Feature-folder stack

```text
app/pages → features/* → shared/*
features/cart ↛ features/*
shared ↛ features or app
```

`CartPage` composes the cart feature. `useCart`, cart components, and totals
stay in `features/cart`; generic UI or query-client setup may live in `shared`.

## FSD stack

Use FSD public APIs and the layer order defined by steiger. Do not reproduce
the feature-folder tree under an FSD label.

## Next.js addition

```text
features/* and shared/* ↛ src/server/*
```

Server Components may compose the client feature, but client-facing layers
must not import server-only modules.

## Verify

Run `npm run check`. If `compforge init` installed the guard, also run
`{pack}/scripts/setup/init.sh --verify` from the target project.

Canonical enforcement details:
[`lint-enforcement.md`](../../../skills/skeleton/lint-enforcement.md).
