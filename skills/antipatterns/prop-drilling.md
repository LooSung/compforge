---
name: prop-drilling
description: Detect props passed through components that do not use them, and fix with composition before context.
tags: [react, antipattern]
stability: experimental
---

# Anti-pattern — Prop Drilling

## Symptoms

- A prop passes through 3+ components that never read it (Hard Rule: 2 levels max).
- Adding one field to a leaf means editing every ancestor's props.
- Middle components' prop types are mostly pass-through noise.

## Fix order (composition first, context second)

1. **Recompose with `children`**: let the owner render the leaf and hand it down as JSX.

   ```tsx
   // before: <Layout user={user}/> → <Sidebar user={user}/> → <Avatar user={user}/>
   // after:
   <Layout sidebar={<Sidebar avatar={<Avatar user={user} />} />} />
   ```

   The middle layers stop knowing about `user` entirely.

2. **Context** — only when many leaves at many depths need the same value (session, theme, locale). Scope the provider to the feature that needs it, not automatically at the root.

3. **Store** — only if the value is also written from distant places (see `react/state-placement.md`).

## What drilling is NOT

- Passing a prop one or two levels to a component that uses it — that is just data flow. Do not wrap everything in context to avoid explicit props; explicit props are the more readable default.

## Review heuristic

For each prop in a diff, find its reader. If the reader is 3+ levels below the owner
and no intermediate reads it, restructure before merging.
