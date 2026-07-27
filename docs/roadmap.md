# Compforge Roadmap

Future-facing only; history lives in [`CHANGELOG.md`](../CHANGELOG.md). This file holds what we **must** do to grow without losing the identity below — not what we would like to do. v0.3.0 closed the install → use → self-verify loop; v0.4.0 made the pack measurable and produced the first evidence.

## Promise

> **AI ships the UI. Compforge keeps the component architecture.**

A frontend component-architecture methodology pack + agent harness for TypeScript + React (Vue later). Not a UI library, not a design-token spec, not a general agent framework. Adjacent projects and how we differ: [`research/competitor-skills.md`](research/competitor-skills.md).

**What we measure:** architecture-violation and rework rates, plus state and accessibility coverage — not lines of code or tokens. Lines may be recorded as context; they are never the goal.

## The ladder

The one thing to remember: **decide what not to write, then where state lives.** Everything else in the pack expands it. Climb from the top; stop at the first rung that holds. Canonical text: [`skills/principles/component-discipline.md`](../skills/principles/component-discipline.md).

```text
Before writing a component
1. Does it need to exist?         -> no: don't build it
2. Platform feature?              -> use it (<dialog>, <form>, CSS, the URL)
3. Framework or installed dep?    -> use it

Before storing a value
4. Derivable from what you have?  -> derive at render; don't store it
5. Comes from the server?         -> query layer, never useState
6. Belongs in the URL?            -> search params / route params
7. Shared across distant nodes?   -> composition first, then context or store
8. Only then                      -> local state, the minimum that works
```

Both halves are the same move: **don't create it; if it must exist, it has exactly one home.** The rungs cut *accidental* complexity only — feature boundaries, typed contracts, and deliberate state placement are structure, not waste.

**Never on the chopping block:** loading, error, and empty states; accessible names and roles; focus management and keyboard paths; input validation. These cost lines and are the first thing a brevity heuristic deletes. Small code is a consequence of building only what the screen needs, never a target.

## Now, in order

1. **Repeat the proof runs** — the harness and two runs are done ([`proof/README.md`](proof/README.md)); what is missing is stochasticity. One pair per starter is an anecdote. Re-run the [antipattern pair](proof/results/2026-07-27-legacy-cursor-claude-opus-5-thinking-high-fast/result.md) twice more on the same model, then once on a weaker model. If the gap does not survive repetition, the claim below comes down.
2. **Enforcement distribution** — per-stack lint templates extracted from the examples: ESLint `import/no-restricted-paths` zones for `react-vite-feature` (must include the `.ts` resolver-extensions fix, or the rule is silently a no-op); steiger for `react-vite-fsd`. Plus a GitHub Actions template that blocks violating PRs.
3. **Antipattern detectors** — mechanical checks where possible (derived-state-in-effect, query-data-in-`useState` heuristics). Start from `scripts/proof/evaluate-run.py`, which already detects several of them and has documented false-positive modes. Migrate Hard Rules to MUST/SHOULD/NEVER phrasing here, once, when detectors need machine-checkable wording.

**What the evidence currently supports**, and nothing wider: *Compforge stops an agent from copying a codebase's bad patterns; it adds nothing to a codebase that already has good ones.* On a [clean starter](proof/results/2026-07-27-cursor-claude-opus-5-thinking-high-fast/result.md) the two arms were indistinguishable; on an [antipattern starter](proof/results/2026-07-27-legacy-cursor-claude-opus-5-thinking-high-fast/result.md) it was 4 violations versus 1, with both arms passing lint, types, and tests.

## Not doing

- **Orchestration** — subagent teams, session or sprint management. Compforge is the discipline each agent follows, not the agent that runs them.
- **Long-term agent memory** beyond the `.craft/` work doc.
- **Wrapping the git / PR / review cycle** — that belongs to the host agent.
- **Visual design and design tokens** (design.md's territory); component generation from designs (stitch's); backend rules (OOPforge's).
- **Mega-skills** — one concept per file, 200 lines.
- **Supporting every framework** — depth over breadth, permanently.

## Gates before Vue

Expanding means replicating a **proven, enforced** vertical. Expanding earlier multiplies unverified methodology. In order:

1. Proof runs public **and repeated** on React — two runs exist; a single pair per starter is not a result to expand on.
2. Repo hygiene + docs link-integrity CI — N× docs and examples is N× drift surface.
3. Lint enforcement live in CI for both React stacks, so Vue arrives with enforcement rather than examples alone.
4. `SKILL.md` frontmatter standardized for portability across harnesses.

Then: **Vue 3 + Nuxt** (`vue-nuxt-feature`, `vue-nuxt-fsd`), each with runnable examples. The Composition API maps closely to the hooks discipline.

## Later

- **Library-loan-style walkthrough** — one end-to-end tutorial (Discovery → Test) on a realistic feature.
- **`react-next-app` stack** — example + boundary recipe (server/client import rules) before any skill claims it.
- **Packaging** — symlink pack (now) → plugin marketplaces → standalone CLI on the Claude Agent SDK.
