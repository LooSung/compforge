---
name: workflow-discovery
description: The first step when starting a new feature area or screen. Define user flows, screens, and domain terms only, with no code.
tags: [workflow, react]
stability: experimental
---

# Workflow — Discovery

## When to use
When starting a new feature area or a large screen. The **first** stage.
Always do this before Design. Skipping it heads straight to the wrong component tree.

## Checklist
- [ ] Define the domain terms the UI speaks (glossary)
- [ ] List user flows (who does what, in what order)
- [ ] Screen inventory (routes/pages and their purpose, one line each)
- [ ] Identify server data sources (APIs, real-time, auth)
- [ ] Non-functional requirements (performance budget, accessibility, responsive targets), one line each
- [ ] Explicitly write down unknowns (Open Questions)

## Output

Save to `docs/discovery.md` in this format:

```markdown
# <Feature> — Discovery

## Glossary
- **Cart**: items the customer intends to buy. Changeable until checkout.
- ...

## User Flows
1. Browse → add to cart → checkout → confirmation
2. ...

## Screens
- `/products` — product list with filters
- `/cart` — cart review and quantity edit

## Server Data
- `GET /products` (paginated), `POST /orders`
- Auth: session cookie

## Non-Functional
- LCP < 2.5s on 3G; WCAG 2.1 AA
- Mobile-first, breakpoints at 640/1024

## Open Questions
- Guest checkout allowed?
- Optimistic cart updates or server-confirmed?
```

## Prohibited
- **No writing code** — not even component names as code. Words and sentences only.
- **No library mentions** — Zustand/TanStack/Tailwind do not appear yet.
- **No layout thinking** — instead of "a modal with two buttons", say "the user confirms removal".
- **No empty Open Questions** — there can't be nothing unknown. State it.

## Next step
After user approval -> `workflow-design`
