# Compforge Roadmap

Direction, priorities, and non-goals. Mirrors OOPforge's phase discipline: **prove and enforce one vertical before multiplying it.**

## Identity

Compforge is a **frontend component-architecture methodology pack + agent harness** for TypeScript + React (Vue later). Not a UI library, not a design-token spec, not a general agent framework.

Adjacent projects and why we differ:

- `ui-skills`, `stitch-skills` — UI pattern/design-to-code skills, guidance without enforcement.
- `design.md` (Google Labs) — visual identity spec only; explicitly not architecture.
- `agent-skills` (Osmani) — general engineering lifecycle; frontend is one skill, not a vertical.
- Feature-Sliced Design / bulletproof-react — human conventions + lint, no agent harness.

Compforge's slot: **methodology (skills) + hard rules (lint/CI) + runnable reference examples + agent runtime**, for the frontend vertical specifically.

## Short term (v0.1 → v0.3)

1. ~~**Competitor skill deep-dive**~~ — **done 2026-07-23**; findings and adopted changes in [docs/research/competitor-skills.md](research/competitor-skills.md) (Rationalizations table adopted; barrel-file rule corrected; steiger identified as the FSD archlint).
2. ~~**Reference examples**~~ — **done 2026-07-23**; `examples/todo-react-feature` (ESLint zones, 12 tests) and `examples/todo-react-fsd` (steiger, 9 tests), both passing `npm run check`. Dogfooding findings: the ESLint node resolver silently skips `.ts` imports without extension settings (boundary rule was a no-op until fixed — CI template must include this); steiger's `insignificant-slice` needs a documented exception for single-page apps.
3. ~~**Hard Rules v0.2**~~ — **done 2026-07-23**; all open items decided and recorded in the research doc (prop depth stays 2; MUST/NEVER phrasing deferred to chapter 2's detectors; numbers kept — both examples satisfied every rule as written).

**Chapter 1 closed at v0.3.0** — install → use → self-verify loop complete (pack + Craft + examples + repo CI). Chapter 2 starts at item 4.

## Medium term

4. **Architecture lint for target projects** — per-stack enforcement templates (`archlint` equivalent): ESLint `import/no-restricted-paths` zones for `react-vite-feature`; steiger (`@feature-sliced/steiger-plugin`) for `react-vite-fsd`. CI workflow template that blocks violating PRs.
5. **Detector rules** — mechanical checks for the antipattern catalog where possible (derived-state-in-effect, query-data-in-useState heuristics).
6. **Proof protocol** — port OOPforge's control/treatment comparison to a frontend task; publish reproducible before/after runs before making improvement claims.
7. **Library-loan-style walkthrough** — one end-to-end tutorial (Discovery → Test) on a realistic feature.

## Long term

### Vue expansion prerequisites (finish in this order, then expand)

Expanding to Vue means replicating a **proven, enforced vertical**. Expanding before React is proven multiplies unverified methodology. Gates, in order:

1. **Proof runs public** — reproducible evidence on the React stack. Gate #1.
2. **Repo hygiene + docs link-integrity CI** — expansion = N× docs/examples = N× drift surface.
3. **Lint enforcement mature** — boundaries/dependency-cruiser templates enforced in CI for both React stacks, so Vue arrives with enforcement, not just examples.
4. **SKILL.md frontmatter standardization** — portability across harnesses.

### Expansion targets

- **Vue 3 + Nuxt** (Composition API maps closely to the hooks discipline; `vue-nuxt-feature`, `vue-nuxt-fsd`), each with runnable examples — only after the gates above.
- **Packaging**: Phase 1 symlink pack (current) → Phase 2 plugin marketplaces + MCP server mode → Phase 3 standalone CLI on Claude Agent SDK.

## Non-goals

- Visual design / design tokens (design.md's territory).
- Component generation from designs (stitch's territory).
- Backend rules (OOPforge's territory).
- Supporting every framework — depth over breadth, permanently.
