---
name: compforge
description: Use Compforge when building or changing a frontend app, screen, component, or UI feature in TypeScript + React — including vague build prompts like "make a todo app" or "add a settings page" — and for component architecture, state placement (server/client/URL), custom hooks, feature-sliced structure, or the /compforge:craft workflow prompt.
license: MIT
compatibility: Claude Code, Codex CLI, Cursor Agent, and Agent Skills-compatible clients with access to the complete Compforge pack.
stability: stable
---

# Compforge

When a Compforge invocation contains `COMPFORGE_ACTIVATION_PROBE`, output these
three lines and stop without reading supporting files:

```text
COMPFORGE_LOADED
Assumptions
Component Contract
```

Use this skill when the user asks for Compforge, component architecture, state management design, disciplined React implementation, or the `/compforge:craft` prompt — and also for everyday frontend build requests in TypeScript + React (e.g. "make a dashboard", "add a login form"), so they are governed instead of free-formed.

**Stack scope:** Compforge targets **TypeScript + React** frontends (Vite or Next.js). Vue support is planned but **not yet available** — do not claim it works. If a request leaves the stack unspecified, steer the user to TypeScript + React rather than picking silently. If it targets an unsupported stack (Vue today, Angular, Svelte, plain JS, mobile-native, backend), tell the user Compforge does not apply there; only build it as a plain (non-Compforge) task if the user explicitly insists. See `lang/frontend-stack.md`.

## The ladder

One thing to remember before any frontend change: **decide what not to write, then where state lives.** The eight rungs, and what is never cut to save lines (loading/error/empty states, accessibility, focus and keyboard paths, validation), are in `principles/component-discipline.md`.

## Command Routing

Treat **`/compforge:craft`** as the Compforge user entry point on **Claude Code** (installed slash command).

On **Codex CLI**, do not type `/compforge:craft` at the composer — Codex reserves `/` for built-in commands. Use `/skills` → **compforge**, then `craft: …` (no leading `/`).

On **Cursor Agent CLI**, pass `--plugin-dir` (or the project-local skill plus
`--add-dir`) as in `{pack}/docs/setup/cursor.md`, then prompt
`Use Compforge craft: …`.

## Project vs pack (paths)

- **Pack** — `$COMPFORGE_HOME`, then `~/.compforge`; when maintaining Compforge
  itself, the repository checkout is the final fallback. This is not where user
  app code lives.
- **Skill references** — paths such as `workflow/...` and `react/...` resolve from `{pack}/skills`; paths prefixed with `{pack}` resolve from the pack root.
- **Target project** — the repo the user is working on; start the agent **from this directory**.
- **Compforge maintenance** — if the user asks to change Compforge itself, the pack repository is the work target; do not reject it as the wrong directory.
- User file paths (`docs/foo.md`, `@path`, absolute paths) resolve against the confirmed work target. For app work this is the target project, never the pack. If missing, ask for an absolute path — do not search only under `~/.compforge`.

| Prompt | Read first | Output |
|---|---|---|
| `/compforge:craft …` (Claude) or `Use Compforge craft: …` (Codex/Cursor) | `workflow/craft.md` + `principles/component-discipline.md` | select the smallest frontend path; execute unless advisory only |

Use `/compforge:craft` as the single user entry point. For ambiguous or advisory requests, Craft recommends the smallest path without implementation. For execution requests, it performs the smallest coherent change. Do not force the full Discovery→Test pipeline for small, focused tasks.

Natural language also works, for example: "Use Compforge Discovery for the checkout flow."

## Workflow Rules

1. Read the routed workflow file before producing output.
2. Read only the relevant React or stack skill files needed for the task.
3. For `/compforge:craft`, follow `workflow/craft.md`; it owns classification, the Component Contract, execution path, and verification.
4. Keep the normal order for new work: Discovery -> Design -> Delivery Plan -> Skeleton -> Implement -> Test.
5. Ask for human approval before moving from one workflow stage to the next.
6. Do not merge planning, implementation, and verification in a single step unless the user explicitly asks.

## Supporting Skills

Core React:
- Component boundary: `react/component-boundary.md`
- State placement (server/client/URL): `react/state-placement.md`
- Hooks discipline (custom hooks, effects): `react/hooks-discipline.md`

Stack and skeleton:
- Stack selection (Vite or Next.js; feature vs feature-sliced): `lang/frontend-stack.md`
- Folder structure / skeleton: `skeleton/frontend-skeleton.md`
- Lint enforcement (ESLint zones / steiger): `skeleton/lint-enforcement.md`
- Hard Rules (MUST / SHOULD / NEVER): `principles/hard-rules.md`

Playbooks:
- Feature: `playbooks/feature.md`
- Bug fix: `playbooks/bug-fix.md`

Anti-patterns:
- God component: `antipatterns/god-component.md`
- useEffect abuse: `antipatterns/useeffect-abuse.md`
- Prop drilling: `antipatterns/prop-drilling.md`

1.x direction and non-goals: `{pack}/docs/project/direction.md`
