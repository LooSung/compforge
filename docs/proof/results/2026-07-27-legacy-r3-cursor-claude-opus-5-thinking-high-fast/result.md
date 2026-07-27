# Compforge Proof Result — 2026-07-27, legacy starter repeat 3, Opus 5 Thinking High Fast

**Headline: 3 violations versus 1, for the third time — with the most
interesting control of the series.** This control extracted a custom hook, the
move a reviewer would ask for, and then implemented the hook itself as a
`useState` mirror of the URL synced by a `popstate` effect. Structure improved;
the state model did not. Both arms passed lint, types, and their own tests.

## Status

- Result: valid
- Invalid reason: none
- Source commit: `6b8f4ce`
- Starter: `docs/proof/starters/todo-react-legacy`
- Cursor Agent version: `2026.07.23-e383d2b`
- Model: `claude-opus-5-thinking-high-fast`
- Run ID: `legacy-r3`

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

- Check (`npm run check`): pass — lint, `tsc --noEmit`, 25 tests
- Changed files: 8 (4 new)
- Architecture violations: **3**
- `App.tsx`: 125 → 160 lines
- Raw artifacts: [`artifacts/`](./artifacts/)

## Compforge

- Check (`npm run check`): pass — lint, `tsc --noEmit`, 32 tests
- Changed files: 12 (7 new)
- Architecture violations: **1**
- `App.tsx`: 125 → 138 lines
- Raw artifacts: [`artifacts/`](./artifacts/)

## Finding-by-finding comparison

| Finding | File | Control | Compforge | Human review |
|---|---|---|---|---|
| `search-query-in-usestate` | `src/hooks/useUrlSearchQuery.ts` (control) | yes | no | agrees |
| `useeffect-added` (popstate → state) | `src/hooks/useUrlSearchQuery.ts` (control) | yes | no | agrees |
| `missing-bulk-completion-outside-component` | `src/App.tsx` | yes | yes | agrees — both arms loop the toggle inline |

The control's hook:

```tsx
const [query, setQuery] = useState(readQuery);

useEffect(() => {
  const syncFromUrl = () => setQuery(readQuery());
  window.addEventListener('popstate', syncFromUrl);
  return () => window.removeEventListener('popstate', syncFromUrl);
}, []);
```

Two sources of truth reconciled by an effect — the starter's signature pattern,
now wrapped in a hook so it *looks* extracted. This is the strongest evidence
in the series that the control copies the state model, not just the file
layout: even when it reinvents the same file boundary as the treatment
(`src/hooks/`), the inside is the surrounding codebase's pattern.

The treatment's `src/hooks/useTodoSearchQuery.ts` uses `useCallback` +
`useSyncExternalStore`; writers call `history.replaceState` and notify
subscribers directly. Zero effects added, URL as the only source of truth.

The shared finding is real: both arms keep bulk completion inline in `App.tsx`.

## UX and accessibility

Both arms labelled the input, announced the count via `role="status"`, and
rendered a distinct "no todos match" empty state. Neither manages focus after
the bulk action. The treatment extracted `TodoSearch.tsx` and
`TodoMatchSummary.tsx`, so `App.tsx` grew 13 lines against the control's 35.
The control wrote fewer tests than the treatment this time (25 versus 32).

## Interpretation

Third pair, same asymmetry, new nuance: **surface structure is not the
methodology.** The control can converge on the same file layout as the
treatment and still ship the antipattern inside it. A reviewer checking "is
there a hook?" would pass this control; only a reviewer checking *where state
lives* catches it — which is precisely the review Compforge encodes.

Limits: small integer counts, one task, one seeded starter, same model as the
other two Opus pairs.

## Validity notes

- **Starter authorship bias:** unchanged; see the first legacy pair.
- **Model stochasticity:** third same-model pair; see the aggregate in
  [`../../README.md`](../../README.md#results).
- **Evaluator limitations:** all three control findings and the shared
  treatment finding confirmed by hand against the patches.
- **Counting:** by decision this pair is 2 versus 1.
