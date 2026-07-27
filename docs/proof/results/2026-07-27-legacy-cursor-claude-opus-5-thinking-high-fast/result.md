# Compforge Proof Result — 2026-07-27, legacy starter, Opus 5 Thinking High Fast

**Headline: a difference, on the starter designed to show one.** Same task, same
model, same day as the [clean-starter run](../2026-07-27-cursor-claude-opus-5-thinking-high-fast/result.md)
that found nothing. Against an antipattern codebase the control extended the
antipattern and the treatment did not: **4 violations versus 1** after hand
correction. Both passed their checks, so a test suite would not have caught the
difference.

## Status

- Result: valid
- Invalid reason: none
- Source commit: `57c24dc`
- Starter: `docs/proof/starters/todo-react-legacy`
- Cursor Agent version: `2026.07.23-e383d2b`
- Model: `claude-opus-5-thinking-high-fast`
- Run ID: `legacy`

## Task

Use the fixed task from [`../../README.md`](../../README.md#fixed-task).

## Conditions

- Control skill: none
- Treatment delivery: project-local Compforge skill at the source commit above
- Starter neutralization applied to both workspaces: yes (the legacy starter has
  nothing to scrub; the guard ran and passed)
- Manual edits during runs: none
- Same model and starter confirmed: yes
- Treatment skill load confirmed by `.craft/` creation: yes
- `npm run check` executed: yes
- User-level Compforge installs moved aside for the run: yes

## Control

- Check (`npm run check`): pass — lint, `tsc --noEmit`, 32 tests
- Changed files: 8 (4 new)
- Architecture violations: **4** (3 at run time; the fourth after the evaluator
  fix described below — `artifacts/control-evaluation.json` is the run-time output)
- `App.tsx`: 125 → 176 lines
- Raw artifacts: [`artifacts/`](./artifacts/)

## Compforge

- Check (`npm run check`): pass — lint, `tsc --noEmit`, 27 tests
- Changed files: 10 (5 new)
- Architecture violations: **1**
- `App.tsx`: 125 → 153 lines
- Raw artifacts: [`artifacts/`](./artifacts/)

## Finding-by-finding comparison

| Finding | File | Control | Compforge | Human review |
|---|---|---|---|---|
| `search-query-in-usestate` | `src/App.tsx` | yes | no | agrees |
| `useeffect-added` (write state → URL) | `src/App.tsx` | yes | no | agrees |
| `useeffect-added` (popstate → state) | `src/App.tsx` | yes | no | agrees |
| Bulk completion inside the component | `src/App.tsx` | **missed at run time** | flagged | evaluator was wrong about the control |

The three control findings share one root cause and are counted separately
because the protocol counts rules, not decisions. The control mirrored the URL
into `useState` and then kept the two in sync with a pair of effects:

```tsx
const [query, setQuery] = useState(() => readQueryParam(window.location.search));

useEffect(() => { /* write query into the URL */ }, [query]);
useEffect(() => { /* popstate: read the URL back into query */ }, []);
```

Two sources of truth for one value, reconciled by effects. It works and its
tests pass. The treatment used `useSyncExternalStore` in
`src/hooks/useUrlSearchParam.ts`, so the URL stays the only source and **no new
effect was added at all**.

The fourth row is an evaluator failure, not a methodology difference. Both arms
loop `toggleTodo` over pending matches inside `App.tsx`. The check passed the
control only because its `src/utils/search.ts` contains the word "completed"
(from the status filter), which the heuristic accepted as evidence of bulk logic
living outside a component. The check now looks for a named bulk-completion
definition in a non-component file; re-running it gives 4 versus 1, matching
hand review, and leaves the clean-starter run at 0 versus 0 where both arms did
extract the operation.

Both arms also, correctly, toggled only the *pending* matches so an already
completed todo does not flip back to active. Neither refactored the starter's
existing effect-based derivation, which is the right call under surgical scope.

## UX and accessibility

Both labelled the search input (`<label htmlFor>`), both announced the count in
a `role="status"` region, and both rendered a distinct "No todos match …" empty
state separate from "No todos yet". The control additionally suppressed the
count during loading and error — the mirror image of the clean-starter run,
where the treatment was the one that got this right. Neither arm managed focus
after the bulk action.

The treatment extracted `TodoSearch.tsx`; the control put the input, the count,
and the bulk button inline in `App.tsx`, which is why its god component grew 51
lines against the treatment's 28.

## Interpretation

This pair demonstrates that **when the surrounding code models the wrong
patterns, the methodology changes what the agent writes.** The control read a
codebase that keeps state in `useState` and syncs it with effects, and it solved
a URL-state problem the same way. The treatment solved it with a subscription
and added zero effects.

It also demonstrates that green tests do not detect this: both arms passed lint,
`tsc`, and their own tests. The difference is only visible to review — which is
the case Compforge claims to serve.

Limits: one pair, one model, one task, one seeded starter that was written by
the same project that publishes this result. The violation counts are small
integers, and three of the control's four trace to a single decision. Nothing
here supports a percentage claim.

## Validity notes

- **Starter authorship bias:** the legacy starter was written by this project to
  contain the antipatterns the skills name. It is a fair test of "does the agent
  copy its surroundings", not a sample of real legacy code.
- **Model stochasticity:** single pair, no repeats.
- **Evaluator limitations:** `bulk_completion_outside_component` produced a
  false negative for the control at run time and was fixed afterwards. Fixing a
  measure after seeing the data is a bias risk; it is recorded here, the run-time
  output is kept in `artifacts/`, and the fix was verified not to move the
  clean-starter run. The other three findings were confirmed by hand.
- **Counting:** rule-based counting inflates one bad decision into three
  findings. The comparison would be 1 versus 0 if counted by decision, and
  4 versus 1 by rule. Both are reported so neither framing hides.
