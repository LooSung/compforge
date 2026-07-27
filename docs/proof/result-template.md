# Compforge Proof Result — <date, model>

## Status

- Result: valid | invalid
- Invalid reason: none | <reason>
- Source commit:
- Starter:
- Cursor Agent version:
- Model:
- Run ID:

## Task

Use the fixed task from [`README.md`](./README.md#fixed-task).

## Conditions

- Control skill: none
- Treatment delivery: project-local Compforge skill at the source commit above
- Starter neutralization applied to both workspaces: yes | no
- Manual edits during runs: none
- Same model and starter confirmed: yes | no
- Treatment skill load confirmed by `.craft/` creation: yes | no
- `npm run check` executed: yes | skipped

## Control

- Check (`npm run check`):
- Changed files:
- Architecture violations:
- Missing coverage:
- Architecture-driven rework:
- Raw artifact location or durable link:

## Compforge

- Check (`npm run check`):
- Changed files:
- Architecture violations:
- Missing coverage:
- Architecture-driven rework:
- Raw artifact location or durable link:

## Finding-by-finding comparison

List each evaluator finding, the affected file, and whether human review agrees.
Explain false positives and false negatives instead of silently removing them.

## UX and accessibility

The evaluator only checks that a label, a live region, and an empty-state branch
exist. Record what each arm actually produced: is the label meaningful, is the
count announced without spamming, does the empty state distinguish "no matches"
from "no todos yet", does keyboard focus survive the bulk action?

## Interpretation

State only what this pair demonstrates. Do not generalize a single run into a
percentage improvement or a claim about other models, stacks, or tasks.

## Validity notes

- Starter-architecture bias:
- Model stochasticity:
- Evaluator limitations:
- Other:
