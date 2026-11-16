# Compforge changelog — 1.2.0 to 1.2.2

Archived from the root changelog. Newest release first.

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
