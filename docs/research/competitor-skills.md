# Competitor Skill Deep-Dive (2026-07)

What we read, what we adopted, what we rejected. Feeds Hard Rules v0.2 and the skill format.

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

**Candidate for v0.2:** rewrite our Hard Rules section in MUST/SHOULD/NEVER phrasing — it is more mechanically checkable than prose bullets.

**Noted:** `npx`-based skill delivery is a Phase 2 packaging option alongside symlinks.

## 3. alan2207/bulletproof-react (docs/project-structure.md)

**The correction that changed our rules:**
- **Barrel files (`index.ts`) are no longer recommended** for Vite projects — they break tree-shaking. Import files directly.
- **Cross-feature imports are forbidden outright** — features compose at the app level, not through feature public APIs.
- Enforcement is concrete and shipping today: ESLint `import/no-restricted-paths` zones per feature + unidirectional `shared → features → app` zones.

**Applied:** `AGENTS.md` Hard Rules, `skills/skeleton/frontend-skeleton.md`, `skills/lang/frontend-stack.md`, `skills/workflow/skeleton.md` all updated: `react-vite-feature` = no cross-feature imports, no barrels; `react-vite-fsd` = slice public APIs (FSD keeps barrels by design).

## 4. feature-sliced/steiger

**Found:** the official FSD architecture linter (`steiger` + `@feature-sliced/steiger-plugin`): zero-config, `npx steiger ./src`, rules like `fsd/public-api`, `fsd/no-segmentless-slices`, ESLint-style config, watch mode.

**Applied:** steiger is our `archlint.py` equivalent for the FSD stack — no need to build one. Enforcement matrix:

| Stack | Boundary enforcement |
|---|---|
| `react-vite-feature` | ESLint `import/no-restricted-paths` zones |
| `react-vite-fsd` | steiger (`@feature-sliced/steiger-plugin`) |
| both | CI workflow template that runs the above and blocks violating PRs (to build) |

## Rejected / out of scope (boundary check)

- **design.md** (Google Labs): visual tokens spec — explicitly not architecture; stay out.
- **stitch-skills**: design-to-code pipeline tooling; stay out.
- **agent-native** (BuilderIO): apps *containing* agents — different axis entirely.

## Open items for Hard Rules v0.2 (validate against reference examples)

1. Prop drilling limit: 2 vs 3 levels.
2. MUST/SHOULD/NEVER phrasing migration.
3. Whether `react-next-app` needs its own boundary enforcement recipe (server/client import rules).
4. Numbers to re-baseline: 200 lines/file, ~15-line logic-in-component threshold, ~7 props.
