# Compforge — Agent Instructions

If you are an AI coding agent working in this repository, follow Compforge itself.

## Mission

Compforge is a portable component-architecture methodology pack for coding agents — **methodology plus agent harness** for frontend work.

It defines disciplined React/TypeScript as a **dialect agents follow** (skills = grammar, hard rules = lint, `examples/` = reference implementations, install/commands = runtime). Protect the core promise: small components, explicit state placement, clear boundaries, and human checkpoints.

Sister project: [OOPforge](https://github.com/LooSung/oopforge) applies the same harness model to backend OOP/DDD.

## Required Workflow

For new features or large screens, do not jump straight to code.

1. **Discovery** — read `skills/workflow/discovery.md`; produce user flows, screen inventory, domain terms, open questions.
2. **Design** — read `skills/workflow/design.md`; produce component tree, state placement plan, API contracts.
3. **Skeleton** — read `skills/workflow/skeleton.md`; create folder structure and empty components/hooks only.
4. **Implement** — read `skills/workflow/implement.md`; implement one feature with tests.
5. **Test** — read `skills/workflow/test.md`; run unit, component, and E2E checks as needed.

Ask for human approval before moving from one stage to the next.

**For smaller, focused tasks** (one component, extending an existing feature, refactoring, code review) — start with `/compforge:craft` (`commands/craft.md`). It selects the smallest path and does not force the full pipeline.

## Default Entry Point

Use `/compforge:craft` (`commands/craft.md`) as the single Compforge user entry point.

`/compforge:craft` delegates orchestration to `skills/workflow/craft.md`, reads `skills/principles/component-discipline.md`, requires Assumptions then a Component Contract before UI implementation, and verifies Hard Rules (including surgical scope) before completion.

- Use `/compforge:craft` for single components, existing-feature additions, UI bug fixes, and behavior-preserving refactors.
- For ambiguous or advisory requests, Craft recommends the smallest path without implementing.
- For a new feature area or large screen, Craft routes into the Discovery → Test workflow and keeps the human checkpoints.

## Skill Path Convention

Resolve the Compforge pack root in order: `$COMPFORGE_HOME` → `~/.compforge` → repository root (when developing this pack).

Skill files live at `{pack}/skills/...`. Do **not** use legacy `skills/compforge/...` paths.

## Project Configuration (target project `AGENTS.md`)

Optional single-line directives the target project can set to control Compforge behavior:

| Directive | Effect |
|---|---|
| `Compforge work dir: <path>` | Override the continuity work dir (default `.craft/`). |
| `Compforge continuity: off` | Disable automatic `.craft/` work-doc creation. |

By default, continuity work docs are **auto-created (opt-out)** for execution tasks (feature/refactor/bugfix); advisory and tiny tasks never create one. See `skills/workflow/continuity.md`.

## Skill Routing

Use this table to decide **which skill to read first**. Workflow stage always wins over ad-hoc coding.

| Workflow stage | Goal | Read first |
|---|---|---|
| Craft (entrypoint) | Select and execute the smallest frontend path, or recommend only for advisory requests | `skills/workflow/craft.md` + `skills/principles/component-discipline.md` |
| Discovery | User flows, screens, domain terms | `skills/workflow/discovery.md` |
| Design | Component tree, state placement, API contracts | `skills/workflow/design.md` + `skills/react/component-boundary.md` |
| Skeleton | Folders, empty components/hooks | `skills/workflow/skeleton.md` + `skills/skeleton/frontend-skeleton.md` (stack via `skills/lang/frontend-stack.md`) |
| Implement | One feature + tests | `skills/workflow/implement.md` + `skills/react/state-placement.md` |
| Test | Unit / component / E2E | `skills/workflow/test.md` |
| Refactor | Behavior-preserving cleanup | `skills/workflow/refactor.md` |
| Continuity | Resume work across sessions | `skills/workflow/continuity.md` |
| Code review | Detect rule violations | Hard Rules below + `skills/antipatterns/` |

### Task → skill (within a stage)

| Task | Skill |
|---|---|
| Component boundary, splitting, composition | `skills/react/component-boundary.md` |
| Server vs client vs URL state placement | `skills/react/state-placement.md` |
| Custom hook extraction, effect discipline | `skills/react/hooks-discipline.md` |
| Frontend stack selection | `skills/lang/frontend-stack.md` |
| Folder structure / skeleton | `skills/skeleton/frontend-skeleton.md` |
| God component | `skills/antipatterns/god-component.md` |
| useEffect abuse (derived state, fetch chains) | `skills/antipatterns/useeffect-abuse.md` |
| Prop drilling | `skills/antipatterns/prop-drilling.md` |

## Hard Rules (v0.2 — validated against `examples/` at todo scale; larger examples may re-baseline. Decisions: `docs/research/competitor-skills.md`)

These limits are intentionally measurable. They come from review focus and agent context size, not arbitrary style:

- **200 lines/component file** — a unit a reviewer can hold in working memory
- **1 exported component per file** — one responsibility per file
- **200 lines/skill file** — one concept per agent context load; split when a skill teaches two ideas

- TypeScript `strict: true`; **no `any`** in committed code (use `unknown` + narrowing).
- **No direct state mutation** — immutable updates only; state changes go through the state API (`setX`, store actions).
- **Components render; hooks decide** — business logic lives in custom hooks or pure functions, not in JSX bodies.
- **Server state is not client state** — data fetched from an API lives in a query layer (TanStack Query or equivalent), never in `useState` + `useEffect` fetch chains.
- **useEffect is a last resort** — effects synchronize with external systems only; no derived state, no data transformation, no event handling in effects.
- **No prop drilling beyond 2 levels** — use composition (`children`) first, context second.
- **No cross-feature imports** — features are composed at the app/pages level. In `react-vite-feature`, a feature never imports from a sibling feature (barrel `index.ts` files are also avoided — they hurt Vite tree-shaking; import directly). In `react-vite-fsd`, every slice exposes a public API and cross-slice imports go through it only. Import direction: `shared ← entities ← features ← pages/app`.
- Do not commit logic hooks or pure domain functions without tests.
- Comments explain "why"; names explain "what".
- **Surgical changes only** — touch what the request requires; no drive-by edits to adjacent code, comments, or formatting. Clean orphans your change created; mention pre-existing dead code instead of deleting it in the same change. A defect your feature makes newly reachable or materially worse is *inside* the request: fix it minimally and say so, rather than deferring a bug you amplified.

### Layer layout

- **Each feature is its own folder** — grouping files only by type (`components/`, `hooks/`, `utils/` at the top level for the whole app) is a violation once the app has more than one feature.
- **Pages/routes must not contain business logic** — they compose features.
- After skeleton, list the directory tree and confirm the feature folders exist with the right file types. See `skills/skeleton/frontend-skeleton.md` self-check.
- CI enforcement planned per stack: ESLint `import/no-restricted-paths` zones for `react-vite-feature`; steiger (`@feature-sliced/steiger-plugin`) for `react-vite-fsd`. See `docs/roadmap.md` and `docs/research/competitor-skills.md`.

## Repository Discipline

- Do not add runtime dependencies for installer scripts unless there is no simpler shell-based alternative.
- Update `CHANGELOG.md` for user-visible changes.
- When changing install behavior, verify with a clean temporary `HOME`.
- Do not claim a harness integration works until documented setup steps and a clean-session smoke test prove it.

## What Not To Do

- Do not merge workflow stages to save time.
- Do not put data fetching, routing, or store wiring inside presentational components.
- Do not create mega-prompts, mega-skills, or broad abstractions without evidence.
- Do not mix refactoring with feature changes; use `workflow/refactor.md` only for behavior-preserving cleanup.
