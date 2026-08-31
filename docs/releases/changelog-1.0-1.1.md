# Compforge changelog — 1.0.0 to 1.1.0

Archived from the root changelog. Newest release first.

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
[`docs/project/direction.md`](../project/direction.md).

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
- **[`docs/reference/support-scope.md`](../reference/support-scope.md)**:
  the tested scope, the canonical harness load paths, what automated evidence
  exists, and the core 1.x compatibility contract that decides
  major/minor/patch.
- **[`docs/reference/skill-stability.md`](../reference/skill-stability.md)** and
  `skills/stability.json`: stable versus experimental skills, checked by
  `harness-smoke.sh static` so a shipped skill cannot go unlisted.
- **[`SECURITY.md`](../../SECURITY.md)**: private vulnerability reporting and what is
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
