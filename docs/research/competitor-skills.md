# Competitor Skill Deep-Dive (2026-07)

Historical research record of what we read, adopted, and rejected. It informed
Hard Rules v0.2 and the skill format. Current rules are canonical in
[`skills/principles/hard-rules.md`](../../skills/principles/hard-rules.md);
subsequent-status notes only preserve this historical record.

## 1. addyosmani/agent-skills (~80k stars)

**Read:** `skills/frontend-ui-engineering/SKILL.md` (their only frontend vertical skill).

**Format observed:** frontmatter (`name`, trigger-phrase-rich `description`) → Overview → When to Use → content with Good/Avoid code pairs → **Common Rationalizations** (excuse ↔ reality table) → **Red Flags** (mechanical smell list) → **Verification** (evidence checklist).

**Adopted:**
- **Rationalizations table** → added to `skills/principles/component-discipline.md` (the always-read file), frontend-specific excuses.
- Their Red Flags list independently confirms our **200 lines/component** Hard Rule (they use the same number).
- Their state ladder matches ours (they add "lifted state" as an explicit rung — ours folds it into local; acceptable).

**Noted, not adopted:**
- They allow prop drilling to 3 levels; we hold at 2 (stricter, revisit against examples).
- "Avoid the AI aesthetic" table (purple gradients, rounded-everything) is visual-design guidance — out of our altitude for now; candidate for a future `ui-baseline`-style skill.

**Structural difference to preserve:** they are a horizontal lifecycle pack (24 skills, frontend is one); we are a frontend vertical with workflow + enforcement. Do not drift toward horizontal.

## 2. ibelick/ui-skills (~6k stars)

**Read:** `skills/ui-skills-root/SKILL.md` (router), `skills/baseline-ui/SKILL.md`.

**Format observed:** RFC-2119 style **MUST / SHOULD / NEVER** rule lists — terse, lintable, zero prose. Root skill is a "smallest useful skill set" router (max 3 skills per task) delivered via `npx ui-skills` CLI.

**Adopted:**
- Their router philosophy validates Craft's "smallest path" selection (independent convergence).
- One of their rules is literally our effect rule: "NEVER use `useEffect` for anything that can be expressed as render logic."

**Subsequent status:** completed in v0.4. The canonical Hard Rules now use
MUST / SHOULD / NEVER phrasing.

**Noted:** `npx`-based skill delivery is a Phase 2 packaging option alongside symlinks.

## 3. alan2207/bulletproof-react (docs/project-structure.md)

**The correction that changed our rules:**
- **Barrel files (`index.ts`) are no longer recommended** for Vite projects — they break tree-shaking. Import files directly.
- **Cross-feature imports are forbidden outright** — features compose at the app level, not through feature public APIs.
- Enforcement is concrete and shipping today: ESLint `import/no-restricted-paths` zones per feature + unidirectional `shared → features → app` zones.

**Applied:** the then-current Hard Rules, `skills/skeleton/frontend-skeleton.md`,
`skills/lang/frontend-stack.md`, and `skills/workflow/skeleton.md` were updated:
`react-vite-feature` = no cross-feature imports, no barrels;
`react-vite-fsd` = slice public APIs (FSD keeps barrels by design). The
canonical rules now live in `skills/principles/hard-rules.md`.

## 4. feature-sliced/steiger

**Found:** the official FSD architecture linter (`steiger` + `@feature-sliced/steiger-plugin`): zero-config, `npx steiger ./src`, rules like `fsd/public-api`, `fsd/no-segmentless-slices`, ESLint-style config, watch mode.

**Applied:** steiger is our `archlint.py` equivalent for the FSD stack — no need to build one. Enforcement matrix:

| Stack | Boundary enforcement |
|---|---|
| `react-vite-feature` | ESLint `import/no-restricted-paths` zones |
| `react-vite-fsd` | steiger (`@feature-sliced/steiger-plugin`) |
| both | CI workflow template that runs the above and blocks violating PRs (shipped in `templates/github/compforge-check.yml`) |

## Rejected / out of scope (boundary check)

- **design.md** (Google Labs): visual tokens spec — explicitly not architecture; stay out.
- **stitch-skills**: design-to-code pipeline tooling; stay out.
- **agent-native** (BuilderIO): apps *containing* agents — different axis entirely.

## Hard Rules v0.2 decisions (closed 2026-07-23, after the reference examples shipped)

1. **Prop drilling limit: keep 2 levels.** Neither example ever needed more than 1 level of pass-through; agent-skills' 3-level allowance gains nothing at todo scale. Re-open only if a larger example forces it.
2. **MUST/SHOULD/NEVER phrasing migration: deferred at v0.2, completed in v0.4.**
   The detector-readable canonical list now uses that phrasing.
3. **`react-next-app` boundary recipe: closed in v0.8.** Encoded in `examples/todo-react-next/` (Server Component compose, `'use client'` island, `server-only` + ESLint zones, serializable `getServerSnapshot`).
4. **Numbers kept as-is** (200 lines/file, ~15-line logic threshold, ~7 props). Both examples satisfied every limit without exceptions. Largest file: `TodosPage.tsx` at ~45 lines. Larger examples may still re-baseline.
