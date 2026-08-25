# Changelog

All notable changes to Compforge are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [Unreleased]

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

## Older releases

- [0.5.0–0.8.0](docs/releases/changelog-0.5-0.8.md)
- [0.1.0–0.4.1](docs/releases/changelog-0.1-0.4.md)
