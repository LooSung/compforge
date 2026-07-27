# Compforge Proof Result — 2026-07-27, legacy starter, Sonnet 4.5 Thinking

**Headline: the gap survives on a weaker model, but it narrows — 5 violations
versus 4 after hand correction, and the machine evaluator missed half the
treatment's violations.** This is the least favourable valid pair published so
far, and the most informative one about the evaluator.

## Status

- Result: valid
- Invalid reason: none
- Source commit: `6b8f4ce`
- Starter: `docs/proof/starters/todo-react-legacy`
- Cursor Agent version: `2026.07.23-e383d2b`
- Model: `claude-4.5-sonnet-thinking`
- Run ID: `legacy-sonnet45`

## Task

Use the fixed task from [`../../README.md`](../../README.md#fixed-task).

## Conditions

- Control skill: none
- Treatment delivery: project-local Compforge skill at the source commit above
- Starter neutralization applied to both workspaces: yes (guard ran and passed)
- Manual edits during runs: none
- Same model and starter confirmed: yes
- Treatment skill load confirmed by `.craft/` creation: yes
- `npm run check` executed: yes
- User-level Compforge installs moved aside for the run: yes

## Control

- Check (`npm run check`): pass — lint, `tsc --noEmit`, 21 tests
- Changed files: 8 (4 new)
- Architecture violations: **5** (machine and hand review agree)
- `App.tsx`: 125 → 208 lines — crosses the 200-line rule
- Raw artifacts: [`artifacts/`](./artifacts/)

## Compforge

- Check (`npm run check`): pass — lint, `tsc --noEmit`, 20 tests
- Changed files: 7 (3 new, plus the `.craft/` work doc)
- Architecture violations: **4** (machine reported 2; hand review found 2 more —
  see below)
- `App.tsx`: 125 → 175 lines
- Raw artifacts: [`artifacts/`](./artifacts/)

## Finding-by-finding comparison

| Finding | File | Control | Compforge | Human review |
|---|---|---|---|---|
| `search-query-in-usestate` | `src/App.tsx` | yes | yes | agrees — both arms mirror the URL into state |
| `derived-value-in-usestate` (`matchCount`) | `src/App.tsx` | yes | no | agrees — treatment derives at render |
| `useeffect-added` (state → URL write) | `src/App.tsx` | yes | **missed by machine** | hand adds it to the treatment |
| `useeffect-added` (URL → state read on mount) | `src/App.tsx` | no | **missed by machine** | hand adds it to the treatment |
| `file-over-200-lines` (208) | `src/App.tsx` | yes | no | agrees |
| `missing-bulk-completion-outside-component` | `src/App.tsx` | yes | yes | agrees |

**Evaluator false negative, new mode.** The treatment refactored the starter's
two derivation-sync effects away (`visibleTodos` and `activeCount` are now
derived at render — a genuine improvement the control did not make) and then
added two new effects to mirror the URL into `searchQuery` state. Removed two,
added two: the file ends at the baseline's three effects, and the evaluator's
baseline subtraction reports nothing. The counter measures net effects, not
added effects. Recorded as a detector gap for roadmap item 3; the run-time
evaluations in [`artifacts/`](./artifacts/) are unmodified.

Corrected counts: control 5, treatment 4. By decision: control 4 (URL
mirroring, matchCount as stored state, god-component growth past 200 lines,
inline bulk) versus treatment 2 (URL mirroring, inline bulk).

## UX and accessibility

Both arms labelled the input, announced the count via `role="status"`, and
rendered a distinct no-match empty state. Neither manages focus after the bulk
action. Both extracted matching into `src/utils/match.ts`. Test counts were
nearly identical (21 versus 20) and far below the Opus pairs' (25–48).

## Interpretation

Two things are true at once:

1. **The direction held.** Treatment stayed below control even here, and the
   treatment's work doc shows the methodology acting: it named the starter's
   derivation effects as an antipattern and removed them, which no control in
   any pair has done.
2. **Transmission weakened.** The same work doc that says "removed useEffect
   anti-pattern" sits next to two freshly added URL-sync effects and a
   `useState` mirror of the URL. The model knew the rule, applied it to the
   starter's old code, and violated it in its own new code. On this model the
   skill made the agent a better refactorer of existing violations but not a
   reliable non-producer of new ones.

The claim this run supports is narrower than the Opus pairs': on a weaker
model, Compforge reduced violations but did not prevent the core one.

## Validity notes

- **Starter authorship bias:** unchanged; see the first legacy pair.
- **Model stochasticity:** single pair on this model; the Opus aggregate does
  not transfer automatically.
- **Evaluator limitations:** the net-versus-added effect-counting gap above is
  the second documented evaluator failure (after the bulk-completion false
  negative in the first legacy pair). Machine output is preserved unmodified;
  published counts are the hand-corrected ones.
- **Counting:** 5 versus 4 by rule, 4 versus 2 by decision. The by-rule gap is
  one small integer; do not quote this pair alone as evidence.
