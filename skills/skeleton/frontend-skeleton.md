---
name: frontend-skeleton
description: Folder structure and empty-file conventions per Compforge stack. Used by workflow-skeleton.
tags: [react, skeleton, architecture]
stability: experimental
---

# Frontend Skeleton

Pick the stack via `lang/frontend-stack.md` first.

## `react-vite-feature`

```text
src/
├── app/                 # entry, providers, router
│   ├── App.tsx
│   └── providers.tsx
├── features/
│   └── cart/
│       ├── index.ts     # public API — the only import point for other features
│       ├── components/
│       │   └── CartList.tsx
│       ├── hooks/
│       │   └── useCart.ts
│       ├── api/
│       │   └── cartApi.ts
│       └── types.ts
├── shared/
│   ├── ui/              # design-system-ish primitives (Button, Spinner)
│   ├── api/             # base client, query client setup
│   └── lib/             # pure utilities
└── main.tsx
```

## `react-vite-fsd`

```text
src/
├── app/                 # providers, router, global styles
├── pages/               # route components; compose widgets/features only
├── widgets/             # large composite blocks (Header, CartPanel)
├── features/            # user interactions (add-to-cart, login)
├── entities/            # domain objects and their UI (Product, User)
└── shared/              # ui kit, api client, lib, config
```

Every slice (`features/add-to-cart/`, `entities/product/`) exposes `index.ts`.

## Empty-file conventions

- Component: typed props, body returns a placeholder (`<div>CartList</div>`).
- Hook: typed signature; body returns typed fixtures or throws `new Error("NotImplemented")` — pick one per project and stay consistent.
- `types.ts`: real types from the Design contracts — types are not placeholders.
- `index.ts`: export only what the Design marked public.

## Self-check (run after creating)

- [ ] Print the tree; every Design tree node has exactly one file.
- [ ] No app-wide `components/`, `hooks/`, `utils/` dumping grounds (shared primitives live under `shared/`).
- [ ] Cross-feature imports go through `index.ts` only.
- [ ] `tsc --noEmit` passes.
