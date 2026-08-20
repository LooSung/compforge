# Compforge Reviewer Checklist

Use this checklist after an agent generates or refactors code with Compforge.
Mechanical MUST / SHOULD / NEVER: [`skills/principles/hard-rules.md`](../skills/principles/hard-rules.md).
The architecture review comments only **new** findings on the diff.

## Components

- [ ] One exported component per file.
- [ ] Component file is 200 lines or less.
- [ ] JSX renders; handlers and decisions live in hooks or pure functions.
- [ ] No god component: unrelated capabilities are not forced into one file (`skills/antipatterns/god-component.md`).
- [ ] Loading, empty, and error states are named, not omitted.

## State

- [ ] Server data lives in the query layer, not `useState` + fetch `useEffect`.
- [ ] Derived values are computed at render, not stored and synced.
- [ ] Bookmarkable UI state lives in the URL.
- [ ] Shared state uses composition first, context second — no prop drilling past 2 levels (`skills/antipatterns/prop-drilling.md`).
- [ ] Updates are immutable.

## Effects and hooks

- [ ] `useEffect` only synchronizes with an external system (`skills/antipatterns/useeffect-abuse.md`).
- [ ] Logic hooks and pure domain functions have tests.
- [ ] Custom hooks own the behavior; pages compose them.

## Architecture

- [ ] Each feature is its own folder (no app-wide type dumping ground).
- [ ] Pages/routes contain no business logic.
- [ ] Import direction holds: feature folders never import siblings; FSD goes through public APIs.
- [ ] Comments explain why; names explain what. No narration comments.
- [ ] The generated design can be explained using Discovery → Design → Delivery Plan → Skeleton → Implement → Test.

## Accessibility

- [ ] Interactive controls have accessible names.
- [ ] Keyboard and focus paths exist for the new interaction.
- [ ] New empty/error states are distinguishable from "nothing loaded yet".
