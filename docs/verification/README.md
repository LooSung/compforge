# Harness verification

Harness verification is release evidence, separate from the methodology
experiments under [`../proof/`](../proof/).

Each release record includes:

- the candidate commit and date;
- harness CLI versions that were actually probed;
- positive activation and isolated negative-control results;
- skipped checks and their release impact.

Records, newest first:

- [`marketplace-2026-11-19.md`](marketplace-2026-11-19.md) — Claude Code
  plugin marketplace install, update, and removal, plus live root and
  activation probes on the installed copies.
- [`evals-2026-11-16.md`](evals-2026-11-16.md) — `claude plugin eval` with and
  without the plugin, plus Haiku and Sonnet, for v1.7.0.
- [`harness-cursor-negative-v1.3.5.md`](harness-cursor-negative-v1.3.5.md) —
  Cursor negative control passed after uninstalling HOME-scoped pack links.
- [`harness-v1.3.4.md`](harness-v1.3.4.md) — live activation for the `refactor`
  and `consult` commands; Cursor's negative control recorded as skipped.
- [`harness-v1.0.0.md`](harness-v1.0.0.md) — the v1 baseline.
