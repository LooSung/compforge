# Compforge Proof Result — 2026-07-27, legacy starter repeat 2, Opus 5 Thinking High Fast

**Headline: the gap repeats — 3 violations versus 1.** Same task, same model,
same starter as the [first legacy pair](../2026-07-27-legacy-cursor-claude-opus-5-thinking-high-fast/result.md),
fresh sessions. The control again mirrored the URL into `useState` and synced it
with an effect; the treatment again used `useSyncExternalStore` and added no
effect. Both arms passed lint, types, and their own tests.

## Status

- Result: valid
- Invalid reason: none
- Source commit: `6b8f4ce`
- Starter: `docs/proof/starters/todo-react-legacy`
- Cursor Agent version: `2026.07.23-e383d2b`
- Model: `claude-opus-5-thinking-high-fast`
- Run ID: `legacy-r2`

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
- User-level Compforge installs moved aside for the run: yes (`~/.claude/skills/{compforge,oopforge}`, `~/.codex/skills/{compforge,oopforge}`)

## Control

- Check (`npm run check`): pass — lint, `tsc --noEmit`, 48 tests
- Changed files: 10 (5 new)
- Architecture violations: **3**
- `App.tsx`: 125 → 165 lines
- Raw artifacts: [`artifacts/`](./artifacts/)

## Compforge

- Check (`npm run check`): pass — lint, `tsc --noEmit`, 37 tests
- Changed files: 9 (5 new)
- Architecture violations: **1**
- `App.tsx`: 125 → 153 lines
- Raw artifacts: [`artifacts/`](./artifacts/)

## Finding-by-finding comparison

| Finding | File | Control | Compforge | Human review |
|---|---|---|---|---|
| `search-query-in-usestate` | `src/App.tsx` | yes | no | agrees |
| `useeffect-added` (write state → URL) | `src/App.tsx` | yes | no | agrees — baseline has 3 effects, control ends with 4, treatment with 3 |
| `missing-bulk-completion-outside-component` | `src/App.tsx` | yes | yes | agrees — both arms loop the toggle inside the component |

The control repeated the first pair's decision almost exactly:

```tsx
const [query, setQuery] = useState(() => readQueryParam(window.location.search));

useEffect(() => { /* write query into the URL via history.replaceState */ }, [query]);
```

One difference from the first pair: this control did **not** add a `popstate`
listener, so it has one sync effect instead of two — and as a consequence
back/forward navigation does not update its UI at all. Fewer counted
violations, worse behavior; the count understates the difference here.

The treatment's `src/hooks/useUrlParam.ts` subscribes to the URL with
`useCallback` + `useSyncExternalStore`, keeps `history.replaceState` inside the
setter, and leaves the URL as the only source of truth. Zero effects added.

The shared finding is real in both arms: bulk completion loops `toggleTodo`
over pending matches inline in `App.tsx` instead of a hook or module function.
Unlike the first pair, this time the treatment also left it in the component.
Both arms correctly toggled only pending matches. Neither arm refactored the
starter's pre-existing effect-based derivation — correct under surgical scope.

## UX and accessibility

Both arms labelled the input (`<label htmlFor>`), announced the count in a
`role="status"` region, suppressed the count while loading, and rendered a
distinct "no todos match" empty state. Neither arm manages focus after the bulk
action. The treatment extracted matching into `src/utils/todoFilters.ts` with
its own tests; the control did the same in `src/utils/search.ts`. `App.tsx`
grew 40 lines in the control against 28 in the treatment.

## Interpretation

This is the second independent pair on the antipattern starter, and the shape
of the difference is the same as the first: **the control copies the
surrounding codebase's state-sync-by-effect pattern for a URL-state problem;
the treatment does not.** Green checks again failed to distinguish the arms —
only review sees it.

Limits: same as the first pair — small integer counts, one task, one seeded
starter written by this project. Two of the control's three findings trace to
one decision.

## Validity notes

- **Starter authorship bias:** unchanged from the first legacy pair; the
  starter was written by this project to contain the antipatterns the skills
  name.
- **Model stochasticity:** this run exists to address it; see the aggregate in
  [`../../README.md`](../../README.md#results).
- **Evaluator limitations:** `missing-bulk-completion-outside-component` was
  confirmed by hand in both arms; the other two findings were confirmed by hand
  in the control patch.
- **Counting:** by decision rather than by rule, this pair is 2 versus 1
  (URL-mirroring decision + inline bulk vs inline bulk).
