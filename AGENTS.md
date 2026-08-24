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
3. **Delivery Plan** — read `skills/workflow/delivery-plan.md`; align requirements, scope, implementation order, tests, and release risks.
4. **Skeleton** — read `skills/workflow/skeleton.md`; create folder structure and empty components/hooks only.
5. **Implement** — read `skills/workflow/implement.md`; implement one feature with tests.
6. **Test** — read `skills/workflow/test.md`; run unit, component, and E2E checks as needed.

Ask for human approval before moving from one stage to the next.

**For smaller, focused tasks** (one component, extending an existing feature, refactoring, code review) — start with `/compforge:craft` (`commands/craft.md`). It selects the smallest path and does not force the full pipeline.

## Default Entry Point

Use `/compforge:craft` (`commands/craft.md`) as the single Compforge user entry point.

`/compforge:craft` delegates orchestration to `skills/workflow/craft.md`, reads `skills/principles/component-discipline.md` and `skills/principles/hard-rules.md`, requires Assumptions then a Component Contract before UI implementation, and verifies Hard Rules (including surgical scope) before completion.

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

By default, continuity work docs are **auto-created (opt-out)** for execution tasks (feature/refactor/bugfix); advisory and tiny tasks never create one. If previous work exists, Craft emits a **Resume block** (previous work / last verified / proposed job / parked) **before any code** and re-scopes an inherited prompt to one decision — the user does not have to mention it. When a session unit ends with work remaining, Craft writes `.craft/next-session-prompt.md` without being asked. See `skills/workflow/continuity.md`.

## Skill Routing

Use this table to decide **which skill to read first**. Workflow stage always wins over ad-hoc coding.

| Workflow stage | Goal | Read first |
|---|---|---|
| Craft (entrypoint) | Select and execute the smallest frontend path, or recommend only for advisory requests | `skills/workflow/craft.md` + `skills/principles/component-discipline.md` |
| Discovery | User flows, screens, domain terms | `skills/workflow/discovery.md` |
| Design | Component tree, state placement, API contracts | `skills/workflow/design.md` + `skills/react/component-boundary.md` |
| Delivery Plan | Scope, order, tests, risks | `skills/workflow/delivery-plan.md` |
| Skeleton | Folders, empty components/hooks | `skills/workflow/skeleton.md` + `skills/skeleton/frontend-skeleton.md` (stack via `skills/lang/frontend-stack.md`) |
| Implement | One feature + tests | `skills/workflow/implement.md` + `skills/react/state-placement.md` |
| Test | Unit / component / E2E | `skills/workflow/test.md` |
| Refactor | Behavior-preserving cleanup | `skills/workflow/refactor.md` |
| Continuity | Resume work across sessions | `skills/workflow/continuity.md` |
| Code review | Detect rule violations | `skills/principles/hard-rules.md` + `skills/antipatterns/` + `docs/reviewer-checklist.md` |

### Task → skill (within a stage)

| Task | Skill |
|---|---|
| Component boundary, splitting, composition | `skills/react/component-boundary.md` |
| Server vs client vs URL state placement | `skills/react/state-placement.md` |
| Custom hook extraction, effect discipline | `skills/react/hooks-discipline.md` |
| Frontend stack selection | `skills/lang/frontend-stack.md` |
| Folder structure / skeleton | `skills/skeleton/frontend-skeleton.md` |
| Lint enforcement (ESLint zones / steiger) | `skills/skeleton/lint-enforcement.md` |
| Hard Rules (MUST / SHOULD / NEVER) | `skills/principles/hard-rules.md` |
| Add one behavior to an existing feature | `skills/playbooks/feature.md` |
| Reproduce a UI bug with a failing test | `skills/playbooks/bug-fix.md` |
| God component | `skills/antipatterns/god-component.md` |
| useEffect abuse (derived state, fetch chains) | `skills/antipatterns/useeffect-abuse.md` |
| Prop drilling | `skills/antipatterns/prop-drilling.md` |

### Harness setup

| Harness | Guide |
|---|---|
| Codex | `docs/codex.md` |
| Claude Code | `docs/claude-code.md` |
| Cursor | `docs/cursor.md` |

Reference implementations: [examples/README.md](examples/README.md) — the same todo app on the three shipped stacks.

## Hard Rules (v1.0)

Canonical detector-readable list: [`skills/principles/hard-rules.md`](skills/principles/hard-rules.md) (MUST / SHOULD / NEVER). Do not keep a second prose copy here.

Validated against `examples/` at todo scale and published proof runs; surgical scope narrowed from run evidence. Larger examples may re-baseline. Decisions: `docs/research/competitor-skills.md`, runs: `docs/proof/`.

Blocking versus review: import zones, FSD steiger, and `any` fail CI where `compforge init` installed them. Detector findings are non-blocking PR comments. See `skills/skeleton/lint-enforcement.md`.

### Layer layout

- **Each feature is its own folder** — grouping files only by type (`components/`, `hooks/`, `utils/` at the top level for the whole app) is a violation once the app has more than one feature.
- **Pages/routes must not contain business logic** — they compose features.
- After skeleton, list the directory tree and confirm the feature folders exist with the right file types. See `skills/skeleton/frontend-skeleton.md` self-check.
- Enforced in the target project by `compforge init` — ESLint `import/no-restricted-paths` zones for `react-vite-feature` and `react-next-app` (the latter also blocks `src/server` imports from features/shared); steiger (`@feature-sliced/steiger-plugin`) for `react-vite-fsd`. Init also writes the `AGENTS.md` constitution pointer and `compforge-lock.json`; `--verify` re-runs the negative self-test. See `skills/skeleton/lint-enforcement.md`.

## Repository Discipline

- Do not add runtime dependencies for installer scripts unless there is no simpler shell-based alternative.
- Update `CHANGELOG.md` for user-visible changes.
- When changing install behavior, verify with a clean temporary `HOME`.
- Do not claim a harness integration works until documented setup steps and a clean-session smoke test prove it. Cursor's documented paths are `--plugin-dir` and the project-local skill; both are pinned by `scripts/ci/harness-smoke.sh live cursor`.
- **Effect claims need runs.** Any statement that Compforge improves an outcome must cite a published pair in `docs/proof/results/`. Unfavorable runs get published too; a measure changed after seeing the data must say so in the result.

## What Not To Do

- Do not merge workflow stages to save time.
- Do not put data fetching, routing, or store wiring inside presentational components.
- Do not create mega-prompts, mega-skills, or broad abstractions without evidence.
- Do not mix refactoring with feature changes; use `workflow/refactor.md` only for behavior-preserving cleanup.
