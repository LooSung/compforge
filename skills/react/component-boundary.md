---
name: component-boundary
description: How to decide what one component owns - responsibility, split signals, and container/presentational wiring.
tags: [react, components]
stability: experimental
---

# Component Boundary

## One component, one responsibility

A component owns exactly one of:

- **Wiring** (container): connects hooks, queries, stores; passes data down; renders children.
- **Rendering** (presentational): receives props, returns markup; no data fetching, no store access.

A file doing both is the first split candidate.

## Split signals (any one is enough)

- File over **200 lines** (Hard Rule) or JSX over ~80 lines.
- Three or more boolean `is*`/`show*` props steering variants.
- Two unrelated pieces of state in one component.
- A section of JSX you scroll past to find the part you're editing.
- You can name a chunk with a noun the domain uses (`CartSummary`, `PriceTag`).

## How to split

1. Name the child by domain vocabulary, not layout (`OrderStatus`, not `RightPanel`).
2. Type the props first; keep them minimal — pass data, not setters, where possible.
3. Prefer `children`/slot props over config flags for variation (`component-discipline` #5).
4. The parent keeps wiring; the child renders.

## Props contract

- Props are the component's public API — type them explicitly; no `any`.
- Pass the narrowest data (`item`, not the whole store slice).
- Callbacks are named by intent: `onQuantityChange`, not `setState`.
- More than ~7 props → group into an object or split the component.

## Checklist
- [ ] Component named by domain vocabulary
- [ ] Wiring and rendering not mixed in one file
- [ ] Props typed, minimal, intent-named
- [ ] Variation via composition before flags
- [ ] File within Hard Rule limits
