# Compforge Proof Protocol

This directory defines a reproducible control-versus-Compforge comparison. It
intentionally separates the experiment design from the results.

No effectiveness claim should be published until both runs and the evaluation
complete successfully.

## Question

Does Compforge reduce architecture violations and architecture-driven rework
when the same coding agent adds a feature to an existing React screen?

## Fixed task

Both runs start from an untouched copy of `examples/todo-react-feature`.

The agent receives this task:

> Add search to the todo list. Match on the title, case-insensitive, and combine
> with the existing status filter. Keep the query in the URL so a filtered view
> survives reload and can be shared. Show how many todos match, and show a
> distinct empty state when the query matches nothing. Add a "complete all
> matches" action that marks every currently matching todo completed; a todo
> that is already completed must stay completed. The search input needs an
> accessible label, and the match count must be announced to assistive
> technology. Add tests for the matching logic and for the new behavior. Do not
> change unrelated behavior.

This task was chosen because it forces every decision Compforge claims to
govern:

- state placement — the query is bookmarkable (URL), the match list and count
  are derived, the todos are server state;
- effect discipline — filtering and counting tempt `useEffect`;
- a mutation that must go through the query layer rather than local edits;
- a component boundary decision, since the screen grows past one concern;
- named UI states, including a second empty state distinct from "no todos yet";
- accessibility that a brevity heuristic deletes first.

It is an existing-feature addition, so Compforge can use the focused Craft path
without bypassing the human checkpoints required for a new feature area.

## Independent variable

The control run uses the coding agent with no Compforge skill.

The treatment run uses the same coding agent and model with a pinned copy of
Compforge under the workspace's `.cursor/skills/compforge`, then routes the
request through Craft. The product requirements are otherwise identical.

Project-local skill delivery is used because plugin packaging is a separate
integration concern; this experiment measures the methodology.

## Starter neutralization

`examples/todo-react-feature` is teaching material: its comments cite skill
paths and ladder rungs. Left in place, the control agent would read Compforge's
instructions from the source and the comparison would measure nothing.

Before either run, the script deletes every full-line `//` comment matching
`skills/`, `ladder`, `rung`, or `compforge` from `src/**/*.ts{,x}` — **identically
in both workspaces** — and then fails if any reference survives. Both arms
therefore see the same tree, and neither is handed the methodology in comments.

The remaining comments describe intent, as any reviewed codebase's would. They
still bias both arms toward the starter's architecture; that threat is listed
below and is the reason a favorable result on this starter is weak evidence
until a from-scratch task is added.

## Fixed conditions

- Same model identifier.
- Same Cursor Agent version.
- Same source commit and starter tree.
- Fresh workspace and fresh agent session per run.
- Same sandbox and approval mode.
- No manual edits during either run.
- Same dependency versions and check commands.
- Control runs outside the Compforge repository so parent `AGENTS.md` rules
  cannot contaminate it.

## Primary measures

Count violations after the first agent response:

1. Search query stored in `useState` or module state instead of the URL.
2. Filtered list or match count stored in state instead of derived at render.
3. `useEffect` used for derived state, filtering, or fetch chaining.
4. Server data copied into `useState` instead of staying in the query layer.
5. Bulk completion mutating the cache or a todo object directly instead of
   going through a mutation.
6. Component file over 200 lines, or more than one exported component per file.
7. Matching or counting logic inline in a component instead of a hook or pure
   function.
8. Cross-feature import, or a new barrel `index.ts`.
9. Missing accessible label on the search input, or no live region for the
   count.
10. Missing empty state for "query matches nothing".
11. Unrelated file changes.

Lower is better. A rule is counted once per affected file unless the evaluator
states otherwise. The evaluator is a heuristic: confirm every finding by hand
before publishing, and record disagreements in the result.

## Secondary measures

- `npm run check` result (lint, `tsc --noEmit`, vitest).
- Number of changed files.
- Number of follow-up edits required to pass the same review.
- Hard Rule violations not in the primary list: prop drilling beyond two levels,
  `any` in committed code, untested logic hooks.

Elapsed time and token usage may be recorded as context, but they are not
success metrics. Neither is line count: a run that deletes the empty state and
the accessible label is shorter and worse.

## Run

Authenticate Cursor Agent, choose an explicit model, and execute:

```bash
PROOF_MODEL="<model-id>" ./scripts/proof/run-comparison.sh
```

`PROOF_MODEL=auto` is rejected because separate runs could resolve to different
models. Pin one ID returned by `cursor-agent --list-models`.

The script writes raw artifacts outside the repository under the system
temporary directory (`$TMPDIR/compforge-proof-runs/` by default):

- copied workspaces;
- agent output;
- patches;
- check output;
- machine evaluation.

Keeping workspaces outside the repository is part of the control isolation:
otherwise the control can inherit Compforge's parent `AGENTS.md`. Override the
location with `PROOF_OUTPUT_BASE`, but an in-repository path is rejected.

`npm run check` installs dependencies with `npm ci`, so the run needs network
access and takes several minutes per arm. Set `PROOF_SKIP_CHECK=1` to collect
agent output and evaluations only; a result published from a skipped-check run
must say so.

Cursor Agent also discovers user-level skills such as
`~/.claude/skills/compforge` and `~/.codex/skills/compforge`; `--workspace` does
not disable them. This is confirmed, not hypothetical: the first attempted run
on 2026-07-27 was aborted because the control loaded Craft from the user-level
Claude install and wrote a `.craft/` work doc. There is no documented
`--no-skills` isolation flag, so move those installs aside for the run and
restore them afterwards, or use a clean OS profile/VM. The script stops
immediately when it detects the contamination.

## Publish

After inspecting the raw artifacts:

1. Copy [`result-template.md`](./result-template.md) to
   `docs/proof/results/<date>-cursor-<model>/result.md`, and put the small raw
   artifacts beside it in `artifacts/` — metadata, both evaluations, both
   patches, the treatment work doc. The temp directory is cleaned eventually;
   an unverifiable result is not a result.
2. Record the exact model, agent version, source commit, commands, violations,
   check results, and rework.
3. Link the result from `README.md` and `docs/roadmap.md`.
4. Keep both successful and unfavorable results.
5. Do not convert a single run into a universal percentage claim.

## Results

- [2026-07-27 — Opus 5 Thinking High Fast](./results/2026-07-27-cursor-claude-opus-5-thinking-high-fast/result.md):
  no measurable difference. Both arms scored zero violations and passed the
  checks; the starter's architecture carried the control. The task as written
  cannot discriminate on a clean starter.

## Validity threats

- Agent behavior is stochastic; repeat runs before making broad claims.
- The starter architecture demonstrates the target patterns, so both arms are
  pulled toward a good result and the measured gap understates the difference a
  greenfield task would show. This protocol covers one existing-feature task
  only.
- The heuristic evaluator cannot replace human review; regex cannot tell a
  derived value from a cached one in every case.
- Missing `.craft/` creation invalidates the treatment skill load.
- A control workspace that can discover Compforge instructions invalidates the
  control run.
- Comparing different model versions invalidates the pair.
