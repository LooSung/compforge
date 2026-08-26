# v1.3.4 harness verification

## Candidate

- Tag: `v1.3.4`
- Probed checkout: `v1.3.3` (`47a972f`) plus the changes in this release
- Date: 2026-08-26
- Policy: local authenticated checks; no repository provider secrets

This record exists because v1.3.0 added the `refactor` and `consult` commands
after the v1.0.0 baseline. Those command paths had static packaging evidence but
no live activation record.

## Activation and isolation

| Harness | CLI version | Positive | Negative | Status |
|---|---|---|---|---|
| Claude Code | 2.1.212 | `craft`, `refactor`, `consult` via session `--plugin-dir`, plus the candidate plugin root | `--safe-mode` isolated | pass |
| Codex CLI | 0.148.0 | `craft`, `refactor`, `consult` under an isolated `CODEX_HOME` with `--ignore-user-config` | isolated `CODEX_HOME` | pass |
| Cursor Agent CLI | 2026.08.11-e8db854 | `craft`, `refactor`, `consult` via `--plugin-dir`; `craft` via project-local skill with `--add-dir`; `/compforge:craft` slash with `--plugin-dir` | **skipped** — not isolatable on this HOME | positives pass; negative control skipped |

Positives require `COMPFORGE_LOADED`, Assumptions, and Component Contract.
Negative controls require `COMPFORGE_NOT_LOADED` and the absence of
`COMPFORGE_LOADED`.

## Cursor negative control

`cursor-agent` discovers `~/.claude/skills`, `~/.codex/skills`, and
`~/.agents/skills` from `HOME`. `CURSOR_CONFIG_DIR` does not scope that
discovery, and the CLI ignored `CLAUDE_CONFIG_DIR` and `CODEX_HOME` when both
were pointed at temporary directories. Confirmed by asking an agent in an
isolated `CURSOR_CONFIG_DIR` and an empty workspace to list its skill paths: it
reported `~/.claude/skills/compforge/SKILL.md`, the symlink `install.sh`
creates.

So on any machine that followed the documented install, the previously
"isolated" clean-workspace control saw the installed pack and reported
`COMPFORGE_LOADED`. That was a false failure about the harness script, not a
Compforge activation regression, and because the run aborted there it also
withheld the slash-probe evidence.

Isolating `HOME` does isolate discovery but loses the OS credential store, so
the probe cannot authenticate without `CURSOR_API_KEY`. `live cursor` now
reports `SKIP` with the reason and continues, so the positives and the slash
probe are still collected. Cursor negative-control evidence requires a `HOME`
without the pack installed; it is not claimed in this record.

## Release decision

The `refactor` and `consult` command paths are proven live on all three
harnesses. Claude and Codex negative controls hold. Cursor's documented load
paths (`--plugin-dir` and the project-local skill) and the slash invocation are
proven positive on the candidate; its negative control is recorded as skipped
rather than passed.
