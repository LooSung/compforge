---
name: workflow-skeleton
description: Create the folder structure and empty components, hooks, and types from the Design output. No business logic.
tags: [workflow, react]
stability: experimental
---

# Workflow — Skeleton

## When to use
After Design is approved. Before implementing any behavior.

## Checklist
- [ ] Choose/confirm the stack layout via `skills/lang/frontend-stack.md`
- [ ] Create feature folders per `skills/skeleton/frontend-skeleton.md`
- [ ] Empty components: props typed, body renders a placeholder
- [ ] Empty hooks: signature typed, body throws `NotImplemented` or returns fixtures
- [ ] Shared types from the Design contracts (`types.ts` or `model/`)
- [ ] Import boundaries per stack: no cross-feature imports (`react-vite-feature`) or slice public APIs (`react-vite-fsd`) — see `skills/skeleton/frontend-skeleton.md`

## Self-check (mandatory)

After creating the skeleton, print the directory tree and confirm:

- Every feature is its own folder; no app-wide `components/` dumping ground.
- Import boundaries hold for the chosen stack (no cross-feature imports, or FSD public APIs).
- No file contains business logic — placeholders only.
- Type-check passes (`tsc --noEmit`).

## Prohibited
- **No business logic** — not even "just this small calculation".
- **No styling** beyond placeholder markup.
- **No extra files** the Design did not name.

## Next step
After user approval -> `workflow-implement`
