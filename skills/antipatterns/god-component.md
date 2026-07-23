---
name: god-component
description: Detect and dismantle a component that fetches, decides, and renders everything at once.
tags: [react, antipattern]
stability: experimental
---

# Anti-pattern — God Component

## Symptoms

- One file fetches data, holds five `useState`s, defines handlers, and renders a whole screen.
- Over 200 lines (Hard Rule violation) or over ~80 lines of JSX.
- Editing any feature on the screen means editing this file.
- Tests are impossible without mocking half the app.

## Why it happens

Agents (and humans) extend the nearest file instead of creating boundaries.
Each addition is individually small; the sum is a screen-sized monolith.

## Dismantling order

1. **Logic out first**: move state + handlers into custom hooks per concern (`useCartItems`, `useCoupon`). The component shrinks without JSX changes — lowest risk.
2. **Server data to the query layer** if it lives in `useState`+`useEffect` (`useeffect-abuse.md`).
3. **JSX into named children**: cut along domain nouns; container keeps wiring (`react/component-boundary.md`).
4. Each step: type-check + tests green before the next.

## Prevention

- Design stage names the component tree before code exists.
- Implement stage's ~15-line logic rule pushes logic to hooks continuously.
- Review flags any file trending toward 200 lines.

## Not a god component

- A long but flat presentational file (e.g. a static marketing section) — length without entangled responsibilities is a lesser concern; split only if editing hurts.
