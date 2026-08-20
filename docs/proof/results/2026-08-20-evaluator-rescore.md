# Evaluator rescore of published pairs — 2026-08-20

Same saved patches, current `scripts/proof/evaluate-run.py`.
Agents were not re-run. Original `*-evaluation.json` files are unchanged.
Rescored JSON sits beside them as `*-evaluation-rescored.json`.
Reproducer: `python3 scripts/proof/rescore-published.py`.

This is a **measure change on frozen diffs**, not a new comparison. Do not
quote these counts as a new agent outcome.

## Counts

| Pair | Arm | Original machine | Rescored | What changed |
|---|---|---|---|---|
| clean Opus 5 | control | 0 | 0 | same |
| clean Opus 5 | treatment | 0 | 0 | same |
| legacy Sonnet 4.5 | control | 5 | 6 | one extra replaced `useEffect` now counted |
| legacy Sonnet 4.5 | treatment | 2 | 4 | the two URL-sync effects the net counter missed |
| legacy Opus 5 | control | 3 | 5 | identity count + named bulk check |
| legacy Opus 5 | treatment | 1 | 1 | same |
| legacy Opus 5 r2 | control | 3 | 4 | one extra replaced effect |
| legacy Opus 5 r2 | treatment | 1 | 1 | same |
| legacy Opus 5 r3 | control | 3 | 3 | same |
| legacy Opus 5 r3 | treatment | 1 | 1 | same |

## Interpretation

1. **The documented Sonnet false negative is closed.** Hand review had already
   added two `useeffect-added` rows to that treatment. The machine now reports
   those two itself. Clean-starter arms stay at zero, so the fix did not invent
   violations on a good tree.
2. **Treatment stays below control** on every legacy pair after rescore
   (4v6, 1v5, 1v4, 1v3). The pre-declared repetition criterion still holds.
   Some control counts rose because replacing an old derivation effect with a
   new URL-sync effect is now an addition, which is the point of the repair.
3. **No new agent runs.** A stochastic re-run of the fixed task remains future
   work if a later release wants a fresh pair. This file only re-scores what
   was already published.

## Validity

- Starter trees are archived from each pair's `source_commit`, neutralized the
  same way as `run-comparison.sh`, then patched with the saved diff.
- `git add -N .` is required so new files enter `git diff`, matching the
  original evaluator invocation.
- Historical result.md files keep their hand-corrected narrative. This rescore
  is the machine follow-up, not a rewrite of those pages.
