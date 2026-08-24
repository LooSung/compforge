# Changelog

All notable changes to Compforge are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [Unreleased]

## [1.0.0] — 2026-08-24

First pinnable release. Every path the documentation claims has been smoked,
the accessibility rules the ladder refuses to drop now have a machine check,
and the support, stability, and security scope is written down instead of
implied. An unfamiliar team can pin `v1.0.0`.

All four roadmap conditions for 1.0 are closed. See
[`docs/roadmap.md`](docs/roadmap.md).

### Added

- **Accessibility detectors** (`scripts/ci/review/a11y.py`), closing the last
  1.0 condition: `CONTROL_WITHOUT_ACCESSIBLE_NAME` (icon-only controls with no
  text and no `aria-label`), `FORM_CONTROL_WITHOUT_LABEL` (no wrapping
  `<label>`, `htmlFor`, or `aria-label` — a placeholder is not a name), and
  `INTERACTIVE_HANDLER_WITHOUT_KEYBOARD` (`onClick` on a non-interactive
  element missing role, `tabIndex`, or a key handler). They run in the existing
  new-only PR review and stay **non-blocking**. This is a text scan of JSX, so
  a clean run is evidence about three rules, not an accessibility audit;
  ambiguous markup stays silent by design. `scripts/ci/test-review.py` holds
  the three shipped examples clean against them.
- **Cursor `--plugin-dir` smoke** (`scripts/ci/harness-smoke.sh`): isolated
  `CURSOR_CONFIG_DIR` probes for explicit plugin, project-local skill plus
  `--add-dir`, no-skill negative control, and `/compforge:craft` with
  `--plugin-dir`. Token positives require `COMPFORGE_LOADED`, Assumptions, and
  Component Contract. Static packaging runs in CI; live Cursor remains a local
  authenticated check (`./scripts/ci/harness-smoke.sh live cursor`).
- Activation probe short-circuit in `skills/SKILL.md`, the Cursor adapter, and
  `commands/craft.md`.
- **[`docs/support-scope.md`](docs/support-scope.md)**: the tested scope, the
  canonical harness load paths, what automated evidence exists, and the core
  1.x compatibility contract that decides major/minor/patch.
- **[`docs/skill-stability.md`](docs/skill-stability.md)** and
  `skills/stability.json`: stable versus experimental skills, checked by
  `harness-smoke.sh static` so a shipped skill cannot go unlisted.
- **[`SECURITY.md`](SECURITY.md)**: private vulnerability reporting and what is
  in scope for a local skill pack.
- `scripts/ci/run-with-timeout.py` with a self-test, so a hung harness probe
  fails instead of hanging CI.

### Changed

- Cursor's documented first path is now `cursor-agent --plugin-dir
  ~/.cursor/plugins/local/compforge`. The project-local skill remains a
  supported alternative.
- `.gitattributes` now counts `examples/` and Markdown in GitHub's language
  statistics. Linguist treats both as documentation, which left only the CI
  scripts visible and reported this React pack as a Python project.

## [0.9.0] — 2026-08-20

Delivery release: the pack now survives a clone of the target repository, the
Next stack is installable rather than example-only, and a delivered guard can be
re-proven instead of assumed.

### Added

- **Constitution pointer** (`templates/agents/compforge-block.md`): `compforge init`
  writes a marked block into the target's `AGENTS.md` naming the pack resolution
  order (`$COMPFORGE_HOME` → `~/.compforge`), the Craft entry point, the files to
  read, and the enforcement installed in that repository. It is the only delivered
  artifact that is committed, so an agent cloning just the target repo picks it up.
  The Hard Rules are deliberately **not** copied — a copy goes stale on the next
  release, which is the drift this delivery exists to prevent.
- **`compforge-lock.json`**: pack version, commit, stack, and check command pinned
  in the target project.
- **`compforge init --verify`**: reads the lock, refuses a stack that drifted from
  it, warns on a pack-version mismatch, and re-runs the negative self-test. A
  delivered guard is only worth the last time it was proven to fail.
- **`react-next-app` stack** (`templates/react-next-app/eslint.compforge.config.js`):
  the feature-folder zones plus the boundary that only exists on this stack —
  `features/` and `shared/` must not import `src/server/`. Its self-test breaks a
  server-only import, not just a cross-feature one.
- **`scripts/ci/init-smoke.sh`**, wired into `examples.yml` per stack: pins stack
  detection for all three examples, then checks delivery, self-test, `--verify`,
  idempotent re-run, survival of a hand-written `AGENTS.md`, and drift refusal.
  It also runs a pack whose Next template lost the server zones and requires that
  install to **fail** — the negative test on the negative test.

### Fixed

- **Next projects were detected as `react-vite-feature`.** `detect_stack` looked
  only for `src/features`, which a Next App Router project also has. The install
  then delivered zones with no `src/server` boundary and still printed
  "self-test passed", because the fixture only tried a cross-feature import.
  Measured on `examples/todo-react-next`; a server-only leak passed lint under the
  vite zones and fails under the Next zones. Detection is now by the `next`
  dependency (or `next.config.*`) and runs before the layout checks.

### Changed

- Roadmap: the Next `init` work planned as v0.10 is folded into this release.
  Splitting it would have tagged the misdetection above as a shipped state, with
  the constitution pointer landing on a false green. The v1.0 condition that read
  "v0.9 and v0.10 are tagged" is now stated as the result it always meant —
  constitution delivered and `init` covering all three stacks.
- `init.sh` shares one zone generator across the ESLint stacks, and the marker
  strings are defined once in the script rather than repeated per Python block.

## [0.8.0] — 2026-08-20

Education release: walk Discovery → Test on one real screen, and stop claiming
Next without a runnable example.

### Added

- **Cart walkthrough** (`docs/guides/cart/`): Discovery → Test on a cart screen.
  Not a third todo app. Checkout is out of scope.
- **`react-next-app` example** (`examples/todo-react-next/`): the same todo app
  on Next.js App Router. Server Components compose; interactive UI is a
  `'use client'` island; `src/server/` is `server-only`. ESLint zones block
  features/shared from importing server or app. The page passes the serializable
  `filter` search param so `useSyncExternalStore` can supply `getServerSnapshot`.
  CI runs `npm run check`, including `next build`.

## [0.7.0] — 2026-08-20

Reference examples, the proof evaluator, and `compforge init` now look at the
same Hard Rules. Architecture review comments on new findings; import zones and
`any` still block the build.

### Added

- **Hard Rules v0.4** as MUST / SHOULD / NEVER in `skills/principles/hard-rules.md`. Detector IDs live in that file once; `AGENTS.md` points at it.
- **Architecture review** (`scripts/ci/review/`): new-only findings for 200-line component files, extra exports, `any`, server data in `useState`, and derived state in `useEffect`, plus a correction prompt. Dogfood workflow on this repo; `compforge init` copies the non-blocking target template.
- **Blocking policy** in `skills/skeleton/lint-enforcement.md`: ESLint zones / steiger / `any` / pack CI fail the build; detector review never does.
- Evaluator and architecture-review self-tests in CI.
- **Evaluator rescore** of the published patches (`docs/proof/results/2026-08-20-evaluator-rescore.md`). Agents were not re-run.

### Fixed

- **Evaluator net-versus-added `useEffect` count**: replacing N effects with N different ones no longer reports zero `useeffect-added`. Bodies are compared, not occurrence indexes.
- **Bulk-completion extraction locked**: the named-definition check has a regression test in `scripts/proof/test-evaluate-run.py`.

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
