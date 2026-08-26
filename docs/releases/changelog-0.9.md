# Compforge changelog — 0.9.0

Archived from the root changelog.

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
