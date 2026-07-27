# Changelog

All notable changes to Compforge are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [Unreleased]

The proof harness is live and its first run is published. That run found **no measurable difference**, so no effectiveness claim is made.

### Added

- **Proof protocol** (`docs/proof/`, `scripts/proof/`): a reproducible control-versus-Compforge comparison on one fixed task — add search to `examples/todo-react-feature`, chosen because it forces URL state, derived values, a query-layer mutation, a component split, a second empty state, and accessibility in a single request.
- `scripts/proof/run-comparison.sh` builds both workspaces from the source commit (`git archive`, so the working tree and `node_modules` cannot leak in), runs both arms, and refuses to continue when the control discovers Compforge (`.craft/` created) or the treatment does not (`.craft/` missing).
- `scripts/proof/evaluate-run.py` scores eleven React-specific violations against each file's pre-change baseline, so only findings the run introduced are counted.
- **Starter neutralization**: the example teaches Compforge in its comments, README, and page title. The harness strips those from **both** workspaces and fails if any reference survives — otherwise the control reads the methodology off the starter and the comparison measures nothing.
- **First proof result** (`docs/proof/results/2026-07-27-cursor-claude-opus-5-thinking-high-fast/`), published with its patches and evaluations: zero violations on both arms, checks passing on both. The starter already models the target architecture, so a top-tier model reproduces it unaided and the task cannot discriminate. Two quality differences went in opposite directions, one against Compforge — the surgical-scope rule made the treatment defer a history-pollution bug that the control fixed.
- Confirmed that Cursor Agent loads user-level skills from `~/.claude/skills/compforge` regardless of `--workspace`: the first attempted run was aborted by the contamination gate. The gate is load bearing, and isolation is a manual prerequisite for a valid run.

### Changed

- **The ladder is the first thing an agent reads.** The pre-write and state-home ladders are merged into one eight-rung ladder at the top of `skills/principles/component-discipline.md`; principles #3 and #7 now point at it instead of restating it. `skills/SKILL.md` carries a one-line summary and a pointer rather than a copy, so there is exactly one canonical text to keep correct.
- **"Never on the chopping block" guard** ships next to the ladder: loading, error, and empty states, accessible names and roles, focus management, and input validation are exempt from subtraction. Small code is a consequence of building only what the screen needs, never a target.
- **Roadmap restructured** as promise → ladder → now → not doing → gates, with chapter numbering dropped. Proof moves ahead of enforcement distribution, and the success metric is stated outright: architecture-violation and rework rates plus state and accessibility coverage, never lines of code. Orchestration, long-term agent memory, and wrapping the git/PR cycle are recorded as non-goals.
- **README / README.ko** describe `examples/` as the reference implementations rather than planned work, and Hard Rules as v0.2.

## [0.3.0] — 2026-07-23

Chapter 1 close: the install → use → self-verify loop is complete.

### Added

- **Repo CI** (`.github/workflows/`): `lint.yml` (skill lint + pack doctor) and `examples.yml` (both examples run `npm ci && npm run check` in a matrix) on every push/PR to main. README badges added.

### Changed

- **Hard Rules promoted to v0.2** — validated against both reference examples; all research-doc open items decided: prop-drilling limit stays at 2 levels, MUST/SHOULD/NEVER phrasing deferred to chapter 2 detectors, numeric limits kept as written (`docs/research/competitor-skills.md`).

## [0.2.0] — 2026-07-23

### Added

- **Runnable reference examples** (`examples/`): the same todo app on both shipped stacks, each passing `npm run check` (lint/arch + `tsc --noEmit` + vitest):
  - `todo-react-feature` — feature folders, app-level composition, no barrels; boundaries enforced by ESLint `import/no-restricted-paths` zones (12 tests).
  - `todo-react-fsd` — FSD layers with slice public APIs; architecture enforced by steiger (9 tests).
- Both examples demonstrate the full state-placement ladder (query layer / URL via `useSyncExternalStore` / local draft / derived-at-render) with **zero `useEffect` in application code**.
- `examples/README.md` index documenting what stays identical and what differs on purpose.

### Fixed (found by dogfooding the examples)

- ESLint's default node resolver does not resolve `.ts`/`.tsx` imports, which **silently disables** `import/no-restricted-paths`. The example config adds resolver extensions; verified with a negative test (violation → exit 1).
- steiger's `fsd/insignificant-slice` flags every slice in a one-page app; disabled in the example config with a documented reason (keep it on in real multi-page apps).

### Deep-dive applied (competitor research)

- Corrected barrel-file rule: `react-vite-feature` forbids cross-feature imports and barrels (Vite tree-shaking, per bulletproof-react); FSD keeps slice public APIs.
- Named per-stack enforcement: ESLint zones / steiger.
- Adopted agent-skills' Rationalizations table into `skills/principles/component-discipline.md`.
- Findings recorded in `docs/research/competitor-skills.md`.

## [0.1.0] — 2026-07-23

Initial scaffold, mirroring the [OOPforge](https://github.com/LooSung/oopforge) pack structure.

### Added

- **Install runtime**: `scripts/setup/` (bootstrap, install, uninstall, doctor) — symlinks the pack into Claude Code (`~/.claude/{skills,commands}/compforge`) and Codex CLI (`~/.codex/skills/compforge`); Cursor via project-local link.
- **Entry point**: `/compforge:craft` slash command (`commands/craft.md`) → `skills/workflow/craft.md` orchestrator with Assumptions block, Component Contract, and Hard Rule verification.
- **Workflow skills**: discovery, design, skeleton, implement, test, refactor, continuity.
- **Principles**: `skills/principles/component-discipline.md` (11 rules incl. state-home ladder, pre-write ladder, surgical changes).
- **React skills**: component-boundary, state-placement, hooks-discipline.
- **Anti-patterns**: god-component, useeffect-abuse, prop-drilling.
- **Stack gate**: `skills/lang/frontend-stack.md` — TypeScript + React only (`react-vite-feature`, `react-vite-fsd`, `react-next-app`); Vue explicitly marked not-yet-supported.
- **Skeleton conventions**: `skills/skeleton/frontend-skeleton.md`.
- **Hard Rules v0.1 draft** in `AGENTS.md` (200 lines/component file, 1 export/file, TS strict, no direct mutation, server state in query layer, effects as last resort, 2-level prop limit, feature public APIs).
- **CI**: `scripts/ci/lint-skills.sh` (frontmatter + 200-line skill limit).
- Docs: `README.md`, `README.ko.md`, `AGENTS.md`, `CLAUDE.md`, `docs/roadmap.md`.
- Plugin manifests: `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/`.

### Known gaps (tracked in `docs/roadmap.md`)

- No runnable `examples/` yet — Hard Rules are a draft until validated against them.
- No CI architecture lint for target projects (eslint-plugin-boundaries / dependency-cruiser integration pending).
- No proof protocol runs yet.
- Vue not supported.
