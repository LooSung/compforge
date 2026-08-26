---
name: frontend-skeleton
description: Folder structure and empty-file conventions per Compforge stack. Used by workflow-skeleton.
tags: [react, skeleton, architecture]
stability: stable
---

# Frontend Skeleton

Pick the stack via `lang/frontend-stack.md` first, and respect its complexity
ladder: scaffold the thin rung (`react-vite-feature`, or `react-next-app` when
SSR is required) unless that skill's second question is yes. Do not create
`pages/`, `widgets/`, or `entities/` to reserve room for growth.

## `react-vite-feature`

```text
src/
├── app/                 # entry, providers, router
│   ├── App.tsx
│   └── providers.tsx
├── features/
│   └── cart/
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

Import rules for this stack: **no cross-feature imports** — compose features at the
`app/` level. **No barrel `index.ts` files** — they hurt Vite tree-shaking; import
files directly. Enforce with ESLint `import/no-restricted-paths` zones.

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

Every slice (`features/add-to-cart/`, `entities/product/`) exposes `index.ts` —
this is FSD's public-api rule, enforceable with steiger (`@feature-sliced/steiger-plugin`).

## `react-next-app`

```text
src/
├── app/                 # Server Components compose; providers.tsx is client
│   ├── layout.tsx
│   ├── page.tsx
│   └── providers.tsx
├── server/              # import 'server-only' — request/auth/fs
├── features/
│   └── cart/
│       ├── components/
│       ├── hooks/
│       ├── api/         # isomorphic — no next/headers or fs
│       └── types.ts
└── shared/
    └── lib/
```

Same as `react-vite-feature` (no cross-feature imports, no barrels), plus
**features and shared must not import `src/server` or `src/app`**. Pass
serializable props from a Server Component. Interactive files use `'use client'`.
URL subscriptions must supply `getServerSnapshot`. Enforce with ESLint
`import/no-restricted-paths`. Reference: `examples/todo-react-next/`.

## Empty-file conventions

- Component: typed props, body returns a placeholder (`<div>CartList</div>`).
- Hook: typed signature; body returns typed fixtures or throws `new Error("NotImplemented")` — pick one per project and stay consistent.
- `types.ts`: real types from the Design contracts — types are not placeholders.
- `index.ts` (FSD only): export only what the Design marked public.

## Self-check (run after creating)

- [ ] Print the tree; every Design tree node has exactly one file.
- [ ] Layers match the chosen rung; a feature stack has no `pages/`, `widgets/`,
      or `entities/` directory.
- [ ] No app-wide `components/`, `hooks/`, `utils/` dumping grounds (shared primitives live under `shared/`).
- [ ] No cross-feature imports (`react-vite-feature`, `react-next-app`); cross-slice via `index.ts` only (`react-vite-fsd`).
- [ ] `react-next-app`: features/shared do not import `src/server` or `src/app`.
- [ ] `tsc --noEmit` passes.
