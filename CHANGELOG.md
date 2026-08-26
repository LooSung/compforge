# Changelog

All notable changes to Compforge are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [Unreleased]

## [1.3.3] — 2026-08-26

Carries the 1.3.2 complexity ladder into the Skeleton stage and the READMEs.
Stack identifiers, selection questions, and the command surface do not change.

### Changed

- `skills/skeleton/frontend-skeleton.md` and `skills/workflow/skeleton.md` now
  scaffold the thin rung by default. An agent that enters at Skeleton no longer
  sees three stacks as a flat menu, and must not create `pages/`, `widgets/`, or
  `entities/` to reserve room for growth.
- The Skeleton self-check has a layer assertion: a feature stack has no
  `pages/`, `widgets/`, or `entities/` directory.
- Both READMEs present the shipped stack identifiers as a ladder instead of a
  list, so readers see `react-vite-feature` as the starting point and
  `react-vite-fsd` as a step taken past roughly five feature areas.
- The 0.9.0 record moved to [`docs/releases/changelog-0.9.md`](docs/releases/changelog-0.9.md),
  finishing the 1.2.0 split that left root history holding one 0.x release. Root
  now keeps 1.x only and fits the 300-line maintained-text gate.

## [1.3.2] — 2026-08-26

Documentation patch. Stack identifiers, selection questions, and the command
surface do not change.

### Changed

- `skills/lang/frontend-stack.md` now states the complexity ladder explicitly:
  start on feature folders and step up to `react-vite-fsd` only when the second
  selection question is yes. Next.js stays the SSR axis, not a thicker rung.
- The import-direction diagram is now per stack. Feature folders no longer show
  `entities/` and `pages/` layers they do not have.
- The Hard Rules cross-feature import bullet names the direction per stack for
  the same reason, instead of one merged chain.

## [1.3.1] — 2026-08-26

Documentation patch. The 1.3 command surface does not change.

### Changed

- README quickstart now shows `craft`, `refactor`, and `consult` before the
  optional init step.
- Codex plugin copy and default prompts name craft, refactor, and consult.

## [1.3.0] — 2026-08-25

Public command surface. Craft stays the default entry point. Refactor and
Consult exist because they use a different authorization boundary. Frontend
tests default to hooks and DOM; Playwright E2E is not the default.

### Added

- Public `refactor` and `consult` commands. Craft stays the default entry
  point. Refactor preserves behavior; Consult does not change implementation
  code. There is no public `test` command.
- Live harness probes now activate `refactor` and `consult` on Claude, Codex,
  and Cursor in addition to Craft.

### Changed

- The Test workflow now defaults to hook and DOM component tests. Playwright
  E2E is not part of the default surface; live API wiring is a manual
  connected check.
- Claude live positive probes use `--permission-mode dontAsk`. Plan mode
  refused the activation token as an injection.

## [1.2.2] — 2026-08-25

### Fixed

- The Claude Craft command now supports both session-plugin
  `${CLAUDE_PLUGIN_ROOT}` resolution and the canonical
  `~/.claude/skills/compforge` symlink install path.
- Claude live smoke now generates a uniquely named temporary probe, preventing
  a same-named command from an older global install from masking the candidate.

## [1.2.1] — 2026-08-25

### Added

- A credential-free regression test proves Claude candidate activation never
  creates or rewrites installed Claude or Codex links.

### Fixed

- Claude plugin metadata now follows the current manifest schema, and the Craft
  command resolves its workflow through `${CLAUDE_PLUGIN_ROOT}`.
- Claude live smoke loads the current checkout with session-only `--plugin-dir`
  and verifies its reported plugin root instead of temporarily rebinding global
  links.

## [1.2.0] — 2026-08-25

### Added

- Standard GitHub contribution, issue, pull-request, conduct, and security
  policies, plus a pack path-convention reference.
- Proof export mode and a CI characterization test that verify starter and
  treatment skills come from the same recorded commit.
- Cart data-flow, wiring, example cross-check, and import-rule guidance.
- A 300-line maintained-text gate with explicit exemptions for generated
  lockfiles and immutable published proof patches.

### Changed

- `compforge init` no longer writes a `verifyCommand` for a standalone
  `compforge` CLI that does not exist; verification guidance points directly to
  `{pack}/scripts/setup/init.sh --verify`.
- Cursor local-plugin notes now live only in `docs/setup/cursor.md`; the
  unreferenced duplicate `.cursor-plugin/README.md` was removed.
- Setup, reference, and project docs now live in logical subfolders, leaving
  `docs/README.md` as the only top-level Markdown document under `docs/`.
- Doctor now checks the invoked checkout's structure while resolving installed
  links through `$COMPFORGE_HOME` or `~/.compforge`; another valid pack warns
  instead of failing.
- English and Korean READMEs keep the runnable quickstart and examples while
  delegating workflow, harness, enforcement, and evidence detail to their
  canonical documents.
- Root CHANGELOG now keeps current 1.x history; 0.x records live under
  `docs/releases/`. Public direction no longer carries future backlog.
- The docs index now separates project contracts, references, guides, evidence,
  and archives; the 1.x direction delegates product definition and release
  history to their canonical owners. CI rejects orphaned top-level docs.
- Architecture-review consumers pin the released `v1.2.0` workflow, and comment
  steps skip forks and Dependabot.
- Init, harness smoke, and architecture-review tests are split by responsibility
  without changing their public entry points.
- The canonical security policy lives under `.github/SECURITY.md`; the v1.0 root
  path remains as a compatibility pointer.

### Fixed

- Canonical Hard Rules, workflow, pack-document, Next example, proof-publish,
  and historical research references now match the shipped v1.1 pack.
- Repository lint now validates Claude, Codex, and Cursor manifest component
  paths and checks both `skills/` and `docs/` references in `AGENTS.md`.
- Published-proof rescoring refreshes machine JSON without overwriting the
  curated interpretation report; a CI regression test preserves that boundary.
- `INSTALL_CLAUDE=0` and `INSTALL_CODEX=0` no longer force installation into a
  clean HOME; invalid values are rejected and covered by smoke tests.

## [1.1.0] — 2026-08-25

Type-rule integrity. The Hard Rules already required `strict: true` and forbade
`any`; init now proves both on every stack instead of leaving FSD and tsconfig
as documentation. No schema library. No type-aware ESLint gate.

### Added

- **`strict: true` gate** in `compforge init` / `--verify`: refuses a project
  whose `tsconfig.json` does not set `compilerOptions.strict` to true. Init
  does not rewrite tsconfig, and it does not follow `extends`.
- **FSD `no-explicit-any`**: `templates/react-vite-fsd/eslint.compforge.config.js`.
  Steiger still owns layers; the FSD check command now runs eslint then steiger.
- **`any` self-test** on all three stacks — a deliberate `any` must fail
  `no-explicit-any`, or init refuses to succeed.
- I/O sentence in `skills/react/state-placement.md`: JSON / URL / storage enter
  as `unknown` and are narrowed in the query layer. `as Todo[]` is the same lie
  as `any`. No new detector.

### Changed

- Init prints a `tsc --noEmit` snippet when no script runs it; it still does
  not rewrite `package.json`.
- Workflow templating uses a string replace (not sed) so FSD's `&&` check
  command cannot be corrupted.
- `scripts/ci/init-smoke.sh` refuses `strict: false` and an FSD template that
  dropped `no-explicit-any`.
- Existing FSD installs must re-run `compforge init` to pick up the eslint
  check command.

## [1.0.1] — 2026-08-24

Documentation patch. The 1.0 usage contract does not change.

### Added

- **Docs index** (`docs/README.md`) and **harness verification record**
  (`docs/verification/harness-v1.0.0.md`): what v1.0.0 actually smoked,
  separate from methodology proof runs.
- `AGENTS.md` Support Scope pointer to `docs/reference/support-scope.md` and
  `skills/stability.json`.

### Changed

- Roadmap is now 1.x maintenance (OOPforge shape): harness drift, compatible
  evolution, documentation ownership. Long-term Vue/MCP/marketplace stay
  listed and do not block 1.x.
- README / README.ko point at support scope, the docs index, and
  `harness-smoke.sh static` as a maintainer check.

## [1.0.0] — 2026-08-24

First pinnable release. Every path the documentation claims has been smoked,
the accessibility rules the ladder refuses to drop now have a machine check,
and the support, stability, and security scope is written down instead of
implied. An unfamiliar team can pin `v1.0.0`.

All four roadmap conditions for 1.0 are closed. See
[`docs/project/direction.md`](docs/project/direction.md).

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
- **[`docs/reference/support-scope.md`](docs/reference/support-scope.md)**:
  the tested scope, the canonical harness load paths, what automated evidence
  exists, and the core 1.x compatibility contract that decides
  major/minor/patch.
- **[`docs/reference/skill-stability.md`](docs/reference/skill-stability.md)** and
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

## Older releases

- [0.9.0](docs/releases/changelog-0.9.md)
- [0.5.0–0.8.0](docs/releases/changelog-0.5-0.8.md)
- [0.1.0–0.4.1](docs/releases/changelog-0.1-0.4.md)
