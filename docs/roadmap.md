# Compforge Roadmap

Direction, priorities, and non-goals — future-facing only; history lives in [`CHANGELOG.md`](../CHANGELOG.md). Mirrors OOPforge's phase discipline: **prove and enforce one vertical before multiplying it.**

## Identity

Compforge is a **frontend component-architecture methodology pack + agent harness** for TypeScript + React (Vue later). Not a UI library, not a design-token spec, not a general agent framework.

Adjacent projects and why we differ:

- `ui-skills`, `stitch-skills` — UI pattern/design-to-code skills, guidance without enforcement.
- `design.md` (Google Labs) — visual identity spec only; explicitly not architecture.
- `agent-skills` (Osmani) — general engineering lifecycle; frontend is one skill, not a vertical.
- Feature-Sliced Design / bulletproof-react — human conventions + lint, no agent harness.

Compforge's slot: **methodology (skills) + hard rules (lint/CI) + runnable reference examples + agent runtime**, for the frontend vertical specifically.

## Chapter 1 — self-verifying pack ✅ (closed at v0.3.0, 2026-07-23)

Install → use → self-verify loop: pack + Craft + two runnable examples + repo CI + Hard Rules v0.2. Details in `CHANGELOG.md`; decisions in [`research/competitor-skills.md`](research/competitor-skills.md).

## Chapter 2 — enforcement distribution (next)

1. **Target-project lint templates** — per-stack enforcement extracted from the examples: ESLint `import/no-restricted-paths` zones for `react-vite-feature` (must include the `.ts` resolver-extensions fix, or the rule is silently a no-op); steiger for `react-vite-fsd`. Plus a GitHub Actions workflow template that blocks violating PRs.
2. **Antipattern detectors** — mechanical checks for the catalog where possible (derived-state-in-effect, query-data-in-`useState` heuristics). Migrate Hard Rules to MUST/SHOULD/NEVER phrasing here, once, when detectors need machine-checkable wording.

## Chapter 3 — proof

1. **Proof protocol** — port OOPforge's control/treatment comparison to a frontend task; publish reproducible before/after runs before making improvement claims.

## After chapter 3

- **Library-loan-style walkthrough** — one end-to-end tutorial (Discovery → Test) on a realistic feature.
- **`react-next-app` stack** — example + boundary recipe (server/client import rules) before any skill claims it.

## Long term

### Vue expansion prerequisites (finish in this order, then expand)

Expanding to Vue means replicating a **proven, enforced vertical**. Expanding before React is proven multiplies unverified methodology. Gates, in order:

1. **Proof runs public** — reproducible evidence on the React stack (chapter 3). Gate #1.
2. **Repo hygiene + docs link-integrity CI** — expansion = N× docs/examples = N× drift surface.
3. **Lint enforcement mature** — the chapter 2 templates (`no-restricted-paths` / steiger) enforced in CI for both React stacks, so Vue arrives with enforcement, not just examples.
4. **SKILL.md frontmatter standardization** — portability across harnesses.

### Expansion targets

- **Vue 3 + Nuxt** (Composition API maps closely to the hooks discipline; `vue-nuxt-feature`, `vue-nuxt-fsd`), each with runnable examples — only after the gates above.
- **Packaging**: Phase 1 symlink pack (current) → Phase 2 plugin marketplaces + MCP server mode → Phase 3 standalone CLI on Claude Agent SDK.

## Non-goals

- Visual design / design tokens (design.md's territory).
- Component generation from designs (stitch's territory).
- Backend rules (OOPforge's territory).
- Supporting every framework — depth over breadth, permanently.
