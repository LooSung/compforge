---
name: hard-rules
description: Detector-readable Compforge Hard Rules as MUST / SHOULD / NEVER. Canonical list; do not keep a second prose copy.
tags: [rules, react, typescript, detector]
stability: experimental
---

# Hard Rules (v0.4)

One list. Detector IDs in backticks. Limits come from review focus and agent
context size. Validated at todo scale against `examples/` and published proof
runs. Larger examples may re-baseline.

The ladder in `component-discipline.md` decides what not to write. This file
is the mechanical subset a detector can read.

## MUST

- A component file MUST be 200 lines or fewer. `FILE_OVER_200_LINES`
- A file MUST export at most one component. `MULTIPLE_EXPORTED_COMPONENTS`
- A skill file MUST be 200 lines or fewer and teach one concept.
- TypeScript MUST use `strict: true`.
- State updates MUST go through the state API (`setX`, store actions).
- Business logic MUST live in hooks or pure functions, not in JSX bodies.
- Server data MUST live in a query layer, never in `useState`. `SERVER_DATA_IN_USESTATE`
- Bookmarkable UI state MUST live in the URL.
- Features MUST be composed at the app/pages level.
- Logic hooks and pure domain functions MUST ship with tests.
- Pages/routes MUST compose features and MUST NOT contain business logic.
- Each feature MUST be its own folder once the app has more than one feature.

## SHOULD

- Comments SHOULD explain why; names SHOULD explain what.
- Shared state SHOULD use composition (`children`) before context.
- `useEffect` SHOULD be a last resort: synchronize with an external system only.
- A structure SHOULD earn its exemption by naming the invariant it protects
  and the user's word for it.
- Ask for approval in the user's words, not Contract jargon.

## NEVER

- NEVER commit `any`. Use `unknown` and narrow. `ANY_TYPE`
- NEVER mutate state, props, or store objects in place.
- NEVER derive or transform data in `useEffect`. `DERIVED_STATE_IN_EFFECT`
- NEVER fetch server data with `useState` + `useEffect` chains.
- NEVER drill props more than two levels.
- NEVER import across sibling features. `react-vite-feature`: no barrels;
  import files directly. `react-vite-fsd`: cross-slice imports go through the
  public API only. Direction: `shared ← entities ← features ← pages/app`.
- NEVER narrate code in comments.
- NEVER mix unrelated refactors into a feature or bug fix.
- NEVER ship a defect your change makes newly reachable; fix it minimally.

## Blocking versus review

Import zones, FSD steiger, and `any` are **blocking** where `compforge init`
installed them. Detector findings on this list are **non-blocking** PR review
unless that policy file says otherwise. See `skills/skeleton/lint-enforcement.md`.
