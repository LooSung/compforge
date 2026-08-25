# Compforge changelog — 0.5.0 to 0.8.0

Archived from the root changelog. Newest release first.

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
