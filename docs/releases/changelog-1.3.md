# Compforge changelog — 1.3.0 to 1.3.6

Archived from the root changelog. Newest release first.

## [1.3.6] — 2026-08-31

Documentation patch. The 1.3 command surface does not change.

### Added

- [`docs/verification/harness-cursor-negative-v1.3.5.md`](../verification/harness-cursor-negative-v1.3.5.md):
  Cursor's isolated negative control passed `COMPFORGE_NOT_LOADED` on v1.3.5
  after `uninstall.sh` removed the HOME-scoped pack links. Positives and slash
  still pass. The installed-pack `SKIP` path is unchanged.

## [1.3.5] — 2026-08-31

Documentation patch. The 1.3 command surface does not change.

### Changed

- The 1.0.0–1.1.0 records moved to
  [`docs/releases/changelog-1.0-1.1.md`](changelog-1.0-1.1.md).
  Root keeps 1.2.x onward so the 300-line maintained-text gate has room for the
  next release. `docs/releases/` is no longer 0.x-only.

## [1.3.4] — 2026-08-26

Live harness evidence for the 1.3 command surface, and the script fix that run
exposed. Stack identifiers, selection questions, and the command surface do not
change.

### Fixed

- `harness-smoke.sh live cursor` no longer fails its negative control on a
  machine where Compforge is installed. `cursor-agent` discovers
  `~/.claude/skills`, `~/.codex/skills`, and `~/.agents/skills` from `HOME`, so
  the clean-workspace control saw the symlink `install.sh` creates and reported
  `COMPFORGE_LOADED`. Because the run aborted there, it also withheld the
  slash-probe evidence. The control is now skipped with a `SKIP` line naming the
  leaking path, and the remaining probes still run.

### Changed

- The Vue scope gate in `skills/lang/frontend-stack.md`, `skills/SKILL.md`, and
  `skills/workflow/craft.md` now says Vue is outside the 1.x support scope
  instead of planned or not-yet-applicable. It already was in
  `docs/reference/support-scope.md`, the READMEs, and the 1.x direction; the
  skills were promising a stack the pack does not commit to.
- `docs/reference/support-scope.md` records that Cursor's negative control needs
  a `HOME` without the pack installed.

### Added

- [`docs/verification/harness-v1.3.4.md`](../verification/harness-v1.3.4.md):
  live activation for `craft`, `refactor`, and `consult` on Claude Code 2.1.212,
  Codex 0.148.0, and Cursor Agent 2026.08.11-e8db854. Claude and Codex negative
  controls pass; Cursor's is recorded as skipped, not passed.
- Self-tests covering both branches of the Cursor negative control, so the skip
  cannot silently become the only path.

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
- The 0.9.0 record moved to [`docs/releases/changelog-0.9.md`](changelog-0.9.md),
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
