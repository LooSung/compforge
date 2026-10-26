# Compforge

![CI](https://github.com/LooSung/compforge/actions/workflows/lint.yml/badge.svg)
![Examples](https://github.com/LooSung/compforge/actions/workflows/examples.yml/badge.svg)
![License](https://img.shields.io/github/license/LooSung/compforge)

> **AI ships the UI. Compforge keeps the component architecture.**
>
> *Harness engineering that stops vibe coding from wrecking your frontend.*

**Forge small. Compose forever.** Compforge is a portable component-architecture
methodology pack and agent harness. Skills teach the grammar, hard rules act as
lint, runnable examples provide references, and Craft selects the smallest
workflow for the job.

Use it when a **TypeScript + React** frontend (Vite or Next.js) needs explicit
component boundaries, state placement (server / client / URL), and reviewable
feature structure. It is not a UI library, general agent framework, or automatic
code generator.

Sister pack for backends: [OOPforge](https://github.com/LooSung/oopforge).

[Positioning](docs/project/positioning.md) ·
[Support scope](docs/reference/support-scope.md) ·
[Proof protocol](docs/proof/README.md) · [Docs index](docs/README.md)

[English](./README.md) · [한국어](./README.ko.md)

## Quickstart

### 1. Install the latest `main`

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LooSung/compforge/main/scripts/setup/bootstrap.sh)"
```

The bootstrap clones or updates `~/.compforge` and installs detected Claude Code
and Codex links. It does not configure Cursor automatically.

### 2. Check the pack and installed links

```bash
~/.compforge/scripts/setup/doctor.sh
```

`doctor.sh` validates pack structure and links; it does not prove Craft loaded.
Use the harness-specific setup in step 4 to verify activation.

### 3. Open your frontend project

Compforge lives in `~/.compforge`. Your app code lives in **your frontend repo**.
Always start the agent from that project:

```bash
cd /path/to/your-frontend-project
```

### 4. Load Compforge and make one request

| Harness | Load and invoke |
|---|---|
| **Claude Code** | Restart Claude Code, then `/compforge:craft <request>` |
| **Codex CLI** | Restart Codex, use `/skills` to select **compforge**, then prompt without a leading `/` |
| **Cursor Agent CLI** | `cursor-agent --plugin-dir ~/.cursor/plugins/local/compforge`, then `Use Compforge craft: …` |

Claude Code:

```text
/compforge:craft Add a quantity stepper to the cart item
/compforge:refactor Split the cart page without changing behavior
/compforge:consult Review the cart state placement
```

Codex CLI:

```text
Use Compforge craft: Add a quantity stepper to the cart item
Use Compforge refactor: Split the cart page without changing behavior
Use Compforge consult: Review the cart state placement
```

Cursor is not configured by `install.sh`; follow the
[Cursor setup](docs/setup/cursor.md) for the local-plugin or project-skill path.

Craft is the default. It surfaces Assumptions and a Component Contract before
UI logic. Use Refactor or Consult when their authorization fits. Exact setup:
[Claude Code](docs/setup/claude-code.md) · [Codex](docs/setup/codex.md) ·
[Cursor](docs/setup/cursor.md).

### 5. Optional: leave the pack in the project

`compforge init` writes an `AGENTS.md` pointer and `compforge-lock.json` so an
agent that clones only your repository knows to read Compforge, and copies the
stack's ESLint import zones (feature folders / Next App Router) or steiger (FSD)
with a PR-blocking GitHub Actions check. It is not required to try Craft.

```bash
~/.compforge/scripts/setup/init.sh
```

Init preserves files it did not generate and proves the delivered guard with a
negative self-test. To re-run that proof later:

```bash
~/.compforge/scripts/setup/init.sh --verify
```

The pointer does not copy Hard Rules that would go stale. Delivery details and
self-test behavior live in [`templates/README.md`](./templates/README.md).

## Public commands

Craft is the default. Refactor, Consult, and Jira keep separate write boundaries. There is no public `test` command.

| Command | Use it when | Must not |
|---|---|---|
| `craft` | Implement or select the smallest frontend path | Skip required stages or broaden scope silently |
| `refactor` | Improve structure while preserving behavior | Add features or change visible UI behavior |
| `consult` | Ask, compare, review, or write one planning document | Change production, test, config, or CI code |
| `jira` | Write one Jira work card in the fixed template | Change anything but the card |

Claude: `/compforge:craft`, `/compforge:refactor`, `/compforge:consult`, `/compforge:jira`.
Codex and Cursor: `Use Compforge craft: …`, `refactor: …`, `consult: …`, `jira: …`.

## The Basic Workflow

Craft selects a focused path for small changes and preserves the full sequence
for a new feature area or large screen:

```text
Discovery → Design → Delivery Plan → Skeleton → Implement → Test
```

Each stage ends with a human checkpoint. Outputs and routing are canonical in
[`AGENTS.md`](AGENTS.md#required-workflow); refactoring remains a separate,
behavior-preserving workflow.

Shipped stack identifiers are `react-vite-feature`, `react-vite-fsd`, and
`react-next-app` — a ladder, not a menu. Compforge starts on
`react-vite-feature` (or `react-next-app` when you need SSR) and steps up to the
Feature-Sliced layers of `react-vite-fsd` only past roughly five feature areas
or multiple teams, so a small screen never begins on FSD. Next.js is the SSR
axis, not a thicker rung. Vue is outside the 1.x support scope. See
[docs/reference/support-scope.md](docs/reference/support-scope.md).

### Resume work across sessions

Execution tasks keep lightweight `.craft/` notes and resume unfinished work
before editing. See [`skills/workflow/continuity.md`](skills/workflow/continuity.md).

## Learn by example

| Resource | Purpose |
|---|---|
| [Examples index](examples/README.md) | Same todo app on the three shipped stacks |
| [Cart walkthrough](docs/guides/cart/README.md) | Discovery → Test on one real screen |
| [Docs index](docs/README.md) | Setup, project, reference, guides, evidence |
| [Harness verification](docs/verification/README.md) | What was actually smoked for v1.0.0 |
| [Support scope](docs/reference/support-scope.md) | Tested scope, verified harness paths, 1.x compatibility contract |
| [Skill stability](docs/reference/skill-stability.md) | Which skills are stable and which are still experimental |
| [Reviewer checklist](docs/reference/reviewer-checklist.md) | Post-implementation rule check |
| [Templates](templates/README.md) | Enforcement `init` copies into a project |

## Why Compforge

Most teams know what a clean React codebase looks like. The hard part is
stopping an agent from collapsing a screen into a 600-line page with eleven
`useState`s and a `useEffect` chain.

The canonical [product principles](docs/project/positioning.md#product-principles)
define the small, measurable, workflow-first, state-first approach.

### Before

```tsx
function CartPage() {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);
  useEffect(() => { fetch('/cart').then(...) }, []);
  useEffect(() => { setTotal(items.reduce(...)) }, [items]);
}
```

**Problems:** god page · server data in client state · derived state synced by
effects · untestable JSX

### After

```tsx
function CartPage() {
  const { items, addItem, removeItem } = useCart();
  const total = sumTotal(items);
  return <CartList items={items} onRemove={removeItem} />;
}
```

**Effects:** one state home · logic tested without rendering · small components ·
a repeatable layout. See the runnable [examples](examples/README.md).

### Evidence and limits

The [evidence standard](docs/project/positioning.md#evidence-standard) defines which
claims the [proof protocol and published runs](docs/proof/README.md) support.
Unfavourable runs are published too; no universal percentage is claimed.

## Installation, updates, and removal

The Quickstart bootstrap tracks the latest `main`. To install a reproducible
release instead:

```bash
git clone https://github.com/LooSung/compforge ~/.compforge
cd ~/.compforge
git checkout v1.3.6
chmod +x scripts/setup/*.sh
./scripts/setup/install.sh
./scripts/setup/doctor.sh
```

### Install targets

Canonical paths and invocation contracts live in
[`docs/reference/support-scope.md`](docs/reference/support-scope.md#canonical-harness-paths).
Harness-specific install controls remain in the
[Claude](docs/setup/claude-code.md), [Codex](docs/setup/codex.md), and
[Cursor](docs/setup/cursor.md) guides.

### Update

A GitHub Release does not update an existing clone:

```bash
cd ~/.compforge && git pull && ./scripts/setup/install.sh update
```

That command is for a `main`-tracking clone. A release-pinned clone must
`git fetch --tags`, check out the chosen newer tag, and then run
`./scripts/setup/install.sh update`.

Cursor's `--plugin-dir` link and any project-local skill are not managed by
`install.sh`; after the pull, restart the agent.

### Verify and troubleshoot

Run these commands from `~/.compforge`:

```bash
./scripts/setup/doctor.sh              # pack structure and installed links
./scripts/setup/install.sh --dry-run   # planned link changes
./scripts/setup/install.sh --force     # replace conflicting symlinks
./scripts/ci/harness-smoke.sh static   # packaged harness contracts
./scripts/ci/smoke-test.sh             # clean-HOME install lifecycle
```

From a development checkout, doctor checks that checkout's structure but
validates links against `$COMPFORGE_HOME` or `~/.compforge`; another valid pack
warns, while a non-pack target fails. These checks do not execute Craft. Verify
activation with the relevant harness guide:
[Claude Code](docs/setup/claude-code.md) · [Codex](docs/setup/codex.md) ·
[Cursor](docs/setup/cursor.md).

### Remove

```bash
./scripts/setup/uninstall.sh
```

This removes only managed Claude and Codex links that still point at this pack.
Cursor and project-local removal steps live in
[`docs/setup/cursor.md`](docs/setup/cursor.md#4-update-or-remove).

## What's included

- `skills/` — workflow, React, stack, skeleton, playbooks, and review instructions
- `commands/` — Claude Code command entry points (`craft`, `refactor`, `consult`, `jira`)
- `examples/` — three runnable TypeScript + React todo references
- `docs/` — harness guides, proof protocol, 1.x direction, support scope, verification
- `scripts/` — setup, init, lint, proof runner, and smoke tests
- `templates/` — ESLint zones, steiger, blocking CI, non-blocking architecture review

## Project policy

[`AGENTS.md`](./AGENTS.md) is the shared constitution and routing source;
detector-readable Hard Rules live in
[`skills/principles/hard-rules.md`](./skills/principles/hard-rules.md), and
[`CLAUDE.md`](./CLAUDE.md) is the Claude Code adapter.
Skill files, scripts, CI, and agent instructions use English as their canonical
language. Korean readers can use the conceptual
[`docs/reference/methodology.ko.md`](./docs/reference/methodology.ko.md) guide instead of unstable
per-skill translations.

Compforge remains a frontend component-architecture methodology layer, not a
model wrapper or general orchestration framework. See
[1.x direction](./docs/project/direction.md) for maintenance and non-goals, the
[support scope](./docs/reference/support-scope.md) for the 1.x compatibility contract,
and the [changelog](./CHANGELOG.md) for completed releases.

## License

MIT
