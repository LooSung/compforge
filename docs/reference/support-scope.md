# Compforge support scope

This document records the currently tested Compforge scope. It is a compatibility
guide for a skill pack, not a hosted-service SLA.

## Supported frontend scope

- TypeScript + React with Vite: feature-folder and Feature-Sliced Design references.
- TypeScript + React with Next.js App Router: `react-next-app` reference.
- Component boundaries, server/client/URL state placement, Craft, and
  `compforge init` enforcement (ESLint zones or steiger, `no-explicit-any`,
  and a `strict: true` tsconfig check).

Vue, Angular, Svelte, plain JS, mobile-native, and backend work are outside
this pack. OOPforge covers backend OOP/DDD.

The three todo apps are executable references, not product boilerplates.

## Canonical harness paths

| Harness | Supported load path | Craft invocation |
|---|---|---|
| Claude Code | `~/.claude/skills/compforge` and `~/.claude/commands/compforge` symlinks | `/compforge:craft …` |
| Codex CLI | `~/.codex/skills/compforge` symlink | select `compforge`, then `Use Compforge craft: …` |
| Cursor Agent CLI | explicit `--plugin-dir` | `Use Compforge craft: …` |
| Cursor Agent CLI | `.cursor/skills/compforge` plus pack `--add-dir` | `Use Compforge craft: …` |

Cursor directory auto-discovery, marketplace installation, and automatic Cursor
setup via `install.sh` are not currently supported paths.

`/compforge:craft` is Claude Code's installed slash command. On Cursor Agent CLI
with `--plugin-dir` it entered Craft in a clean headless session; the documented
Cursor invoke remains `Use Compforge craft: …`.

`doctor.sh` validates the invoked checkout's files. Installed links resolve
against `$COMPFORGE_HOME`, then a valid `~/.compforge`, then the invoked
checkout. A link to another valid Compforge pack is a warning; a link to a
non-pack directory fails. Doctor does not prove agent activation.
Maintainers can run `scripts/ci/harness-smoke.sh live <harness>` with their own
local CLI authentication. A positive run must report `COMPFORGE_LOADED`, and an
isolated negative control must report `COMPFORGE_NOT_LOADED`. Cursor slash with
`--plugin-dir` must enter Craft. Claude loads the candidate checkout with a
session-only `--plugin-dir` and verifies the plugin root reported by its harness
command; it never rewrites installed Claude or Codex links. Codex uses an
isolated temporary `CODEX_HOME`. Cursor's isolated live probe reuses its OS
credential-store token through sanitized login metadata, or a local
`CURSOR_API_KEY` when present. No provider credential is stored in the
repository.

## Automated evidence

- Pull requests and pushes run packaging/static smoke, isolated-HOME install,
  `compforge init` self-tests, and the three example `npm run check` jobs
  without provider credentials.
- Authenticated live probes are optional maintainer checks, not hosted CI gates.
- Architecture-review detectors use the Hard Rule IDs in
  `skills/principles/hard-rules.md`. Import zones, steiger, `any`, and
  `strict: true` block where `compforge init` installed them. Detector review
  comments are non-blocking by default.
- Accessibility detectors (`CONTROL_WITHOUT_ACCESSIBLE_NAME`,
  `FORM_CONTROL_WITHOUT_LABEL`, `INTERACTIVE_HANDLER_WITHOUT_KEYBOARD`) run in
  the same review. They are a text scan of JSX, so they are evidence about
  those three rules only — not an accessibility audit — and the shipped
  examples are held clean against them by `scripts/ci/test-review.py`.

## Versioning and compatibility

The pack version is the shared version in the three plugin manifests, Git tag,
and changelog. Skill maturity is tracked separately in
[`skills/stability.json`](../../skills/stability.json).

Compforge 1.x keeps this core usage contract compatible:

- the canonical harness load paths and Craft invocations above;
- the Discovery → Design → Delivery Plan → Skeleton → Implement → Test stage
  order and its human checkpoints;
- the meaning of existing Hard Rules and the Component Contract fields;
- stable skill paths used by the default execution routes.

For the pack version:

- **major** removes or incompatibly changes that core usage contract;
- **minor** adds compatible skills, checks, examples, stacks, or load paths;
- **patch** corrects guidance, packaging, tests, or documentation without
  changing the contract.

`stable` is a maturity signal, not a promise that every sentence is frozen.
Stable guidance may improve within 1.x when the core contract remains
compatible and user-visible changes are documented. Experimental skills are
outside the compatibility promise.

CLI vendors may make a previously verified path unavailable. Until a clean
local positive/negative smoke re-establishes it, documentation should mark that
path unverified rather than claiming support.

## Not currently supported

A Compforge MCP server, Vue stacks, marketplace publication, a standalone
Compforge CLI, and a claim that Compforge universally improves agent output are
outside this 1.0 scope.

Accessibility enforcement stops at the three detector rules above. Focus order,
live regions, colour contrast, and screen-reader flow stay Craft/discipline
requirements — the ladder does not drop them to save lines — and are reviewed by
a human, not gated. Widening that gate is 1.x work.
