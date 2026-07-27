# Compforge Proof Result — 2026-07-27, Opus 5 Thinking High Fast

**Headline: no measurable difference.** Both arms scored zero architecture
violations and both passed `npm run check`. On this starter, with this model,
Compforge did not change the architectural outcome. Two quality differences went
in opposite directions, one of them against Compforge.

## Status

- Result: valid
- Invalid reason: none
- Source commit: `dd4e5bbd6fc26ba6541716a105ddb7c087ee5d7f`
- Starter: `examples/todo-react-feature` (neutralized)
- Cursor Agent version: `2026.07.23-e383d2b`
- Model: `claude-opus-5-thinking-high-fast`
- Run ID: `first`

An earlier attempt on the same commit was aborted as **invalid**: the control
created `.craft/` and produced Craft-shaped work, because Cursor Agent
discovered the user-level install at `~/.claude/skills/compforge`. The valid run
above was produced after moving that install and `~/.codex/skills/compforge`
aside. This is the first hard evidence that the contamination gate is load
bearing rather than defensive.

## Task

Use the fixed task from [`../../README.md`](../../README.md#fixed-task).

## Conditions

- Control skill: none
- Treatment delivery: project-local Compforge skill at the source commit above
- Starter neutralization applied to both workspaces: yes
- Manual edits during runs: none
- Same model and starter confirmed: yes
- Treatment skill load confirmed by `.craft/` creation: yes
  (`.craft/feature-todo-search.md`)
- `npm run check` executed: yes

## Control

- Check (`npm run check`): pass — lint, `tsc --noEmit`, 35 tests
- Changed files: 13
- Architecture violations: 0
- Missing coverage: none
- Architecture-driven rework: none
- Raw artifacts: [`artifacts/`](./artifacts/) (`control-changes.patch`,
  `control-evaluation.json`)

## Compforge

- Check (`npm run check`): pass — lint, `tsc --noEmit`, 29 tests
- Changed files: 10
- Architecture violations: 0
- Missing coverage: none
- Architecture-driven rework: none
- Raw artifacts: [`artifacts/`](./artifacts/) (`treatment-changes.patch`,
  `treatment-evaluation.json`, `treatment-craft-work-doc.md`)

## Finding-by-finding comparison

The evaluator reported no findings for either arm. Hand review of both patches
across all eleven primary measures agrees — there are no false negatives to
report. Both arms independently:

- put the query in the URL through the existing `useSearchParamState`;
- kept matching in `lib/filterTodos.ts` as pure functions;
- derived the visible list and the match count at render;
- added a bulk-completion mutation in the query layer with an idempotent
  `completed: true` write rather than looping `toggleTodo`;
- wrote zero `useEffect`;
- labelled the input, announced the count in a `role="status"` region, and gave
  "no matches" its own empty state distinct from "no todos yet".

Differences are quality, not architecture:

| | Control | Compforge |
|---|---|---|
| History pollution while typing | **Fixed** — added a `history: 'replace'` option to the shared hook | **Deferred** — left one history entry per keystroke, with a comment naming the upgrade path |
| Live region during load | Announces "0 todos match" before data arrives | **Guarded** — stays silent until the query settles |
| Bulk action UI | Extracted `TodoBulkActions`, pluralized the count | Inlined the button in `App.tsx` |
| Tests added | 23 | 17 |

## UX and accessibility

Both labels are meaningful and both live regions are polite. The control's
region is wrong during loading: it claims "0 todos match" before any data
exists, which a screen-reader user hears as a real answer. The treatment
suppresses the count until loading and error resolve, which is the better
behavior and the one Compforge's named-UI-states discipline predicts.

The history-entry defect runs the other way. Typing five characters leaves five
back-button steps in both the starter's filter and the new search. The control
fixed it by extending the shared hook. The treatment identified the same defect,
wrote it down, and left it — a direct consequence of the surgical-scope rule
("touch what the request requires"). The rule is right about drive-by edits and
wrong here: the feature the request asked for is the thing that exposes the
defect. This is a real methodology finding, not a model artifact.

## Interpretation

This pair demonstrates that **on a starter that already models the target
architecture, a top-tier model does not need Compforge to reproduce it.** The
control had `useSearchParamState`, a pure `filterTodos` module, and a query-layer
hook in front of it, and it followed those patterns.

It does not show that Compforge is ineffective. It shows that this task cannot
discriminate: the independent variable is swamped by the starter. Nothing here
generalizes to other models, other stacks, greenfield work, or a codebase whose
existing patterns are bad.

## Validity notes

- **Starter-architecture bias: decisive.** This is the threat the protocol
  listed, and it consumed the experiment. A discriminating task needs a starter
  that does not already demonstrate the answer — greenfield, or one seeded with
  the antipatterns the skills name.
- **Model stochasticity:** single pair, no repeats. Even the observed quality
  differences could reverse on a rerun.
- **Evaluator limitations:** it confirmed what hand review found on this pair,
  but a zero-versus-zero result exercises none of its discrimination. The
  fixture test (14 violations versus 0) is what currently shows it can tell the
  two apart.
- **Other:** the control's fix to `useSearchParamState` improves shared code
  that the treatment left alone; measures counting "changed files" as cost would
  score that backwards.
