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

[Positioning and non-goals](docs/positioning.md) ·
[Reproducible proof protocol](docs/proof/README.md)

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

`doctor.sh` validates the pack and available symlinks. A successful result does
not prove that a running agent loaded Craft; use the harness-specific check in
step 4. If it warns that your chosen Claude or Codex link is missing, run
`INSTALL_CLAUDE=1 ~/.compforge/scripts/setup/install.sh` or the Codex equivalent.

### 3. Open your frontend project

Compforge lives in `~/.compforge`. Your app code lives in **your frontend repo**.
Always start the agent from that project:

```bash
cd /path/to/your-frontend-project
```

### 4. Load Craft and make one request

| Harness | Load and invoke Craft |
|---|---|
| **Claude Code** | Restart Claude Code, then `/compforge:craft <request>` |
| **Codex CLI** | Restart Codex, use `/skills` to select **compforge**, then prompt without a leading `/` |
| **Cursor Agent CLI** | Link the project-local skill, then use `Use Compforge craft: …` |

Claude Code:

```text
/compforge:craft Add a quantity stepper to the cart item
```

Codex CLI:

```text
Use Compforge craft: Add a quantity stepper to the cart item
```

Cursor Agent CLI is not configured by `install.sh`. Link the skill into the
target project (documented experimental path — `--plugin-dir` is not claimed):

```bash
mkdir -p .cursor/skills
ln -s ~/.compforge/skills .cursor/skills/compforge
printf '%s\n' '.cursor/skills/compforge' >> .git/info/exclude
```

```text
Use Compforge craft: Add a quantity stepper to the cart item
```

For a fresh execution task, a loaded Craft flow identifies the smallest path
and surfaces Assumptions and a Component Contract before UI logic. Advisory
requests recommend a path without implementing. Exact setup:
[Claude Code](docs/claude-code.md) · [Codex](docs/codex.md) ·
[Cursor](docs/cursor.md).

### 5. Optional: put guardrails in the project

`compforge init` copies ESLint import zones (feature folders) or steiger (FSD)
and a PR-blocking GitHub Actions check. It is not required to try Craft.

```bash
~/.compforge/scripts/setup/init.sh
```

It detects the stack from `src/`, never overwrites files it did not generate,
and finishes with a **negative self-test**: a deliberate cross-feature import
must fail, or init refuses to report success. Re-run after adding a feature.
Details: [`templates/`](./templates/README.md).

## The Basic Workflow

Craft is the single entry point. It selects a focused path for small changes and
preserves the full sequence for a new feature area or large screen:

```text
Discovery → Design → Delivery Plan → Skeleton → Implement → Test
```

| Stage | Output | Do not do |
|---|---|---|
| **Discovery** | User flows, screens, glossary, open questions | Code |
| **Design** | Component tree, state homes, API contracts | Implementation |
| **Delivery Plan** | Scope, order, tests, release risks | Coding |
| **Skeleton** | Feature folders, typed empty components/hooks | Business logic |
| **Implement** | One tested feature at a time, hooks first | Multiple features at once |
| **Test** | Unit (hooks), component, and E2E evidence | Untested logic hooks |

Each stage ends with a human checkpoint. Ask Craft to start at a named stage
only when earlier decisions already exist. Refactoring stays outside the feature
flow because it must preserve behavior.

Shipped stack identifiers are `react-vite-feature`, `react-vite-fsd`, and
`react-next-app`. Vue is gated behind the React vertical. See
[docs/roadmap.md](docs/roadmap.md).

### Resume work across sessions

Execution tasks keep lightweight notes under `.craft/`. If unfinished work
exists, Craft presents a Resume block before editing. When a session ends with
work remaining, `.craft/next-session-prompt.md` records the next decision.

## Learn by example

| Resource | Purpose |
|---|---|
| [Examples index](examples/README.md) | Same todo app on the three shipped stacks |
| [Cart walkthrough](docs/guides/cart/README.md) | Discovery → Test on one real screen |
| [Reviewer checklist](docs/reviewer-checklist.md) | Post-implementation rule check |
| [Templates](templates/README.md) | Enforcement `init` copies into a project |

## Why Compforge

Most teams know what a clean React codebase looks like. The hard part is
stopping an agent from collapsing a screen into a 600-line page with eleven
`useState`s and a `useEffect` chain.

| Principle | What it means |
|---|---|
| **Small** | One skill, one concept; 200 lines per skill |
| **Measurable** | 200 lines/component file, 1 export/file |
| **Workflow-first** | Discovery → Test with human checkpoints |
| **State-first** | Every piece of state has exactly one named home |
| **Proof over philosophy** | Effect claims cite [published runs](docs/proof/) |

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

The [proof protocol](docs/proof/README.md) fixes the task, control, treatment,
evaluation rules, and publication standard. What the [published runs](docs/proof/)
currently support, and nothing wider: *Compforge stops an agent from copying a
codebase's bad patterns; it adds nothing to a codebase that already has good
ones, and on a weaker model it reduces violations without preventing the core
one.* Unfavourable runs are published too. This is not a percentage claim.

## Installation, updates, and removal

The Quickstart bootstrap tracks the latest `main`. To install a reproducible
release instead:

```bash
git clone https://github.com/LooSung/compforge ~/.compforge
cd ~/.compforge
git checkout v0.8.0
chmod +x scripts/setup/*.sh
./scripts/setup/install.sh
./scripts/setup/doctor.sh
```

### Install targets

| Harness | Installed or registered path |
|---|---|
| **Claude Code** | `~/.claude/skills/compforge` and `~/.claude/commands/compforge` |
| **Codex CLI** | `~/.codex/skills/compforge` |
| **Cursor Agent CLI** | Manual project-local skill; `install.sh` does not configure it |

`install.sh` only creates Claude and Codex links when their config directories
exist. Set `INSTALL_CLAUDE=1` or `INSTALL_CODEX=1` to create a missing target
explicitly.

### Update

A GitHub Release does not update an existing clone:

```bash
cd ~/.compforge && git pull && ./scripts/setup/install.sh update
```

That command is for a `main`-tracking clone. A release-pinned clone must
`git fetch --tags`, check out the chosen newer tag, and then run
`./scripts/setup/install.sh update`.

Cursor's manually registered project-local skill is not managed by `install.sh`;
after the pull, restart the agent.

### Verify and troubleshoot

Run these commands from `~/.compforge`:

```bash
./scripts/setup/doctor.sh              # pack structure and installed links
./scripts/setup/install.sh --dry-run   # planned link changes
./scripts/setup/install.sh --force     # replace conflicting symlinks
./scripts/ci/smoke-test.sh             # isolated Claude/Codex install lifecycle
```

These checks do not execute a live Craft response. Verify activation with the
entry point in the relevant harness guide:
[Claude Code](docs/claude-code.md) · [Codex](docs/codex.md) ·
[Cursor](docs/cursor.md).

### Remove

```bash
./scripts/setup/uninstall.sh
```

This removes only Compforge-managed Claude and Codex links that still point at
this pack. It keeps `~/.compforge`, any Cursor project-local
`.cursor/skills/compforge` link, and any same-name symlink that points somewhere
else. Remove those paths manually if you want a complete uninstall.

## What's included

- `skills/` — workflow, React, stack, skeleton, playbooks, and review instructions
- `commands/` — Claude Code command entry point
- `examples/` — three runnable TypeScript + React todo references
- `docs/` — harness guides, proof protocol, roadmap
- `scripts/` — setup, init, lint, proof runner, and smoke tests
- `templates/` — ESLint zones, steiger, blocking CI, non-blocking architecture review

Agents use [`AGENTS.md`](./AGENTS.md) as the shared rule source;
[`CLAUDE.md`](./CLAUDE.md) is the Claude Code adapter.

## Project policy

The enforceable rules live in [`AGENTS.md`](./AGENTS.md). Skill files, scripts,
CI, and agent instructions use English as their canonical language. Korean
readers can use the conceptual
[`docs/methodology.ko.md`](./docs/methodology.ko.md) guide instead of unstable
per-skill translations.

Compforge remains a frontend component-architecture methodology layer, not a
model wrapper or general orchestration framework. See the
[roadmap](./docs/roadmap.md) for required future work and non-goals, and the
[changelog](./CHANGELOG.md) for completed releases.

## License

MIT
