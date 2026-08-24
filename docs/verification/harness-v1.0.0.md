# v1.0.0 harness verification

## Candidate

- Tag: `v1.0.0`
- Commit: `3e38db9`
- Date: 2026-08-24
- Policy: local authenticated checks; no repository provider secrets

## Activation and isolation

| Harness | CLI version | Positive | Negative | Status |
|---|---|---|---|---|
| Claude Code | 2.1.212 | symlink install (`scripts/ci/smoke-test.sh`) | isolated HOME uninstall | pass (install lifecycle) |
| Codex CLI | 0.148.0 | symlink install (`scripts/ci/smoke-test.sh`) | isolated HOME uninstall | pass (install lifecycle) |
| Cursor Agent CLI | 2026.08.11-e8db854 | `--plugin-dir` and project-local loaded | clean workspace isolated | pass (live activation) |

Cursor live positives require `COMPFORGE_LOADED`, Assumptions, and Component
Contract. The isolated no-skill workspace must return `COMPFORGE_NOT_LOADED`.
`/compforge:craft` with `--plugin-dir` entered Craft.

Claude and Codex **live** Craft activation (`./scripts/ci/harness-smoke.sh live
claude|codex`) is a maintainer check. v1.0.0 CI proves the install links, not a
headless Craft reply. Re-run those live probes before claiming a new CLI
version.

## Release decision

The documented Cursor paths and the Claude/Codex symlink install were proven
on the candidate. Directory auto-discovery is not claimed.
Marketplace publication is out of scope.
