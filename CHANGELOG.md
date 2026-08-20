# Changelog

All notable changes to Compforge are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [0.6.0] — 2026-08-20

The sister pack's harness matured. This release brings that *philosophy* into Compforge — translated into React language, not copied as backend domain skills.

### Added

- **Delivery Plan** (`skills/workflow/delivery-plan.md`): after Design, one execution plan for scope, contracts, implementation order, tests, and release risks. New feature areas now run Discovery → Design → Delivery Plan → Skeleton → Implement → Test.
- **Craft playbooks**: `skills/playbooks/feature.md` (one behavior on an existing feature) and `skills/playbooks/bug-fix.md` (failing hook/component test first).
- **Session cut + next-session prompt**: one session ships one decision. When the unit ends with work remaining, Craft writes `.craft/next-session-prompt.md` without being asked (`skills/workflow/continuity.md`).
- **Resume block**: if `.craft/` holds unfinished work, Craft emits Previous work / Last verified / Proposed job / Parked **before any code**, even when the user did not mention it. Inherited prompts are re-scoped to one decision.
- **Product language at the human boundary** (`component-discipline` #14): Feature, hook, slice, and invented names stay in the Component Contract and the code; approval is asked in the user's words.
- **Evidence before cause** (`component-discipline` #12) and **comment discipline** (`#13`): a cause needs one falsifiable observation; narration comments are deleted or replaced by names.
- **Structure earns its exemption** (`component-discipline` #7): a feature boundary / query layer / URL home is essential only when you can name the invariant *and* the user's own word for it.
- **Brownfield refactor order**: surface (pages) → feature/hooks → shared/query; one branch one decision; abandon-branch residue (`skills/workflow/refactor.md`).
- **Lint-enforcement skill** pointing at `templates/` and `compforge init` (ESLint zones / steiger / negative self-test).
- **Positioning** (`docs/positioning.md`), **reviewer checklist**, harness guides (`docs/claude-code.md`, `docs/codex.md`, `docs/cursor.md`), and a Korean concept guide (`docs/methodology.ko.md`) that is not a per-skill mirror.
- **Docs link-integrity CI** (`scripts/ci/check-doc-links.py`) with a self-test, **isolated-HOME smoke test**, and a Cursor packaging adapter (`.cursor-plugin/skills/compforge/SKILL.md`). `--plugin-dir` is **not** claimed until a Compforge smoke test proves it.

### Changed

- Craft skips Assumptions/Component Contract for non-frontend work (docs, tooling, ops) but keeps Verification and Scope drift. Pack-repository maintenance is a valid work target.
- `commands/craft.md` carries the official `name: craft` frontmatter; plugin manifests are `0.6.0`; Cursor plugin skills path is `./.cursor-plugin/skills/`.
- README / AGENTS.md / SKILL.md describe Resume, Delivery Plan, and the language policy. Vue gates for docs-link CI and Skill frontmatter are closed.
- **Roadmap restated in the OOPforge shape** (`docs/roadmap.md`): vision, immutable principles, **one** next release (v0.7 fitness functions), long-term, non-goals. History stays in the changelog.
- **First-user onboarding (OOPforge 0.12.1 analogue):** English and Korean READMEs are a ≤300-line user path — Quickstart, Craft success criteria, core workflow, evidence, then install lifecycle. `doctor.sh` is documented as pack/link check, not Craft activation. Cursor stays on the project-local skill; `--plugin-dir` is still not claimed. `compforge init` is optional step 5, after Craft works.

### Fixed

- **Codex/Cursor invoke mix-up:** Korean README and `docs/methodology.ko.md` no longer treat `/compforge:craft` as the universal prompt. Codex and Cursor use `Use Compforge craft: …`.
- **Uninstall safety:** `uninstall.sh` leaves same-name symlinks that point elsewhere, and does not touch Cursor's project-local skill. Smoke test locks the preserve path.

### Not copied from OOPforge (on purpose)

- Outbox, CQRS, Aggregates, transaction boundaries — backend domain, not frontend.
- Library-loan walkthrough — still a Compforge-original tutorial, still a long-term item on the roadmap.
- C2 PR domain-review engine — next after antipattern detectors; this pack already has `scripts/proof/evaluate-run.py`.
- 20-lines/method as a Hard Rule — Compforge keeps 200 lines/component, evidenced at todo scale.
- Cursor `--plugin-dir` as the documented first path, and a Craft asciinema — neither is proven in this pack.

## [0.5.0] — 2026-07-27

The claim survived repetition, and the pack now delivers its enforcement into target projects. This closes the chapter that began with the proof harness: measure first, then distribute what the measurement justified.

### Added

- **`compforge init`** (`scripts/setup/init.sh`): copies the stack's enforcement into a target project — ESLint `import/no-restricted-paths` zones for feature folders, steiger for FSD, and a GitHub Actions workflow that blocks violating PRs. Detects the stack from `src/` and refuses to guess when detection fails.
- **`templates/`**: the enforcement configs, extracted from the runnable examples where CI exercises them. The FSD template keeps `fsd/insignificant-slice` on; the example turns it off only because a one-page demo has single-consumer slices.
- **Negative self-test in init**: after installing, a deliberate cross-feature import must fail lint (and a compliant file must pass), or init exits non-zero. The `.ts` resolver trap makes the zone rule silently a no-op when misconfigured — a delivered-but-dead guard is worse than none, so init proves the mechanism can fail before reporting success.
- **Per-feature zone generation**: cross-feature zones are enumerated from the directories under `src/features/` at init time, inside a marked block that a re-run regenerates idempotently. Files init did not generate are never overwritten; an existing `eslint.config.js` gets a printed merge snippet instead.
- **Three repeat proof runs** (`docs/proof/results/`): the legacy-starter pair re-run twice on Opus 5 (3v1, 3v1) and once on Sonnet 4.5 Thinking (5v4 hand-corrected). The pre-declared criterion — treatment below control in at least 2 of 3 pairs — was met in all three.

### Changed

- **The claim narrowed instead of coming down**: *Compforge stops an agent from copying a codebase's bad patterns; it adds nothing to a codebase that already has good ones, and on a weaker model it reduces violations without preventing the core one.* The Sonnet 4.5 treatment mirrored the URL into `useState` despite loading the skill — recorded, published, and reflected in README and roadmap.
- **A second evaluator failure mode is documented**: baseline subtraction counts net effects, not added ones — a run that removes two effects and adds two reports zero `useeffect-added`. Fix queued as the first task of the antipattern-detector roadmap item.
- Quickstart gains the init step; `doctor.sh` validates `templates/` and `init.sh`; roadmap marks proof repetition and enforcement distribution done. Init is enforcement delivery only — not a scaffold; the Promise paragraph is unchanged.

## [0.4.1] — 2026-07-27

Documentation catch-up after the proof work. No behavior change to install, skills, or the harness.

### Changed

- **Hard Rules promoted to v0.3** in `AGENTS.md`, `README.md`, and `README.ko.md`: the ruleset changed in 0.4.0 when surgical scope was narrowed, and its evidence base is now the examples *and* two published runs. The label was left at v0.2 by mistake.
- **READMEs state v0.4 status**, carry the narrow claim the runs support, and link `docs/proof/`. The old status line still advertised the proof protocol as upcoming work. "Proof over philosophy" now means published pairs including unfavourable ones, and `examples/` is described as reference implementations so "proof" refers to one thing only.
- **Roadmap drops the completed surgical-scope item** and leads with repeating the runs — one pair per starter is an anecdote, and the claim comes down if the gap does not survive repetition. The Vue gate now requires runs to be repeated, not merely public. Antipattern detectors point at `scripts/proof/evaluate-run.py` as their starting point.
- **`AGENTS.md` gains an evidence rule** under Repository Discipline: effect claims must cite a published pair in `docs/proof/results/`, unfavourable runs get published too, and a measure changed after seeing the data must say so in the result.

## [0.4.0] — 2026-07-27

Compforge starts measuring itself. The proof harness is live with two published runs. Together they support one narrow claim: **Compforge stops an agent from copying a codebase's bad patterns, and adds nothing to a codebase that already has good ones.** No broader claim is made from two runs.

### Added

- **Proof protocol** (`docs/proof/`, `scripts/proof/`): a reproducible control-versus-Compforge comparison on one fixed task — add search to `examples/todo-react-feature`, chosen because it forces URL state, derived values, a query-layer mutation, a component split, a second empty state, and accessibility in a single request.
- `scripts/proof/run-comparison.sh` builds both workspaces from the source commit (`git archive`, so the working tree and `node_modules` cannot leak in), runs both arms, and refuses to continue when the control discovers Compforge (`.craft/` created) or the treatment does not (`.craft/` missing).
- `scripts/proof/evaluate-run.py` scores eleven React-specific violations against each file's pre-change baseline, so only findings the run introduced are counted.
- **Starter neutralization**: the example teaches Compforge in its comments, README, and page title. The harness strips those from **both** workspaces and fails if any reference survives — otherwise the control reads the methodology off the starter and the comparison measures nothing.
- **First proof result** (`docs/proof/results/2026-07-27-cursor-claude-opus-5-thinking-high-fast/`), published with its patches and evaluations: zero violations on both arms, checks passing on both. The starter already models the target architecture, so a top-tier model reproduces it unaided and the task cannot discriminate. Two quality differences went in opposite directions, one against Compforge — the surgical-scope rule made the treatment defer a history-pollution bug that the control fixed.
- **Antipattern starter** (`docs/proof/starters/todo-react-legacy`) and `PROOF_STARTER` to select it: the same todo app with the same dependencies, built the way the skills say not to. It lints, type-checks, and passes its tests — bad architecture, not broken code.
- **Second proof result** (`docs/proof/results/2026-07-27-legacy-.../`): on that starter, 4 violations versus 1. The control mirrored the URL into `useState` and added two effects to keep them in sync; the treatment used `useSyncExternalStore` and added none. Both arms passed lint, types, and their own tests, so only review would have caught the difference.
- Confirmed that Cursor Agent loads user-level skills from `~/.claude/skills/compforge` regardless of `--workspace`: the first attempted run was aborted by the contamination gate. The gate is load bearing, and isolation is a manual prerequisite for a valid run.

### Changed

- **Surgical scope narrowed, using the proof run as the evidence.** Hard Rule and principle #11 now say that a defect your feature makes newly reachable or materially worse is *inside* the request: fix it minimally and say so, rather than deferring a bug you amplified. The first run showed the old wording making the treatment leave a history-pollution bug in place with a comment while the control simply fixed it. A matching Rationalizations row blocks "that bug was already there".
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
