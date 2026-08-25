# Codex Setup

Compforge is supported on Codex through a skill entry point at `skills/SKILL.md`.

Codex installs **skills only** — not Claude Code `commands/`. The string `/compforge:craft` is **not** a Codex slash command; Codex reserves `/` for built-ins such as `/skills` and `/model`.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LooSung/compforge/main/scripts/setup/bootstrap.sh)"
```

Restart Codex. Verify:

```bash
~/.compforge/scripts/setup/doctor.sh
```

`doctor.sh` checks the pack and Codex link. It does not execute Craft. Restart
Codex, then `/skills` → **compforge**, then prompt without a leading `/`.

Installed path:

- `~/.codex/skills/compforge`

Because this path is a symlink to `~/.compforge/skills`, Codex sees:

- `~/.codex/skills/compforge/SKILL.md`
- `~/.codex/skills/compforge/workflow/*.md`
- `~/.codex/skills/compforge/react/*.md`
- `~/.codex/skills/compforge/lang/*.md`

Works in **any project directory** — skills are global under `~/.codex/skills/`.

**Important:** start Codex **from your target project**, not from `~/.compforge`:

```bash
cd /path/to/your-frontend-project
codex
```

If `pwd` is `~/.compforge`, relative paths like `docs/screens/foo.md` will be resolved in the **pack**, not your app repo. Use an absolute path or restart Codex after `cd` to your project.

Exception: when you are maintaining Compforge itself, start Codex from the
Compforge repository and treat that repository as the work target.

## Run Craft on Codex

1. Start Codex in your frontend project: `cd /path/to/your-project && codex`
2. Type `/skills` and select **compforge**
3. Prompt **without** a leading `/`:

```text
Use Compforge craft: Add a quantity stepper to the cart item
Use Compforge refactor: Split the cart page without changing behavior
Use Compforge consult: Review the cart state placement
Use Compforge Discovery for the checkout flow. No code yet.
```

Optional: `~/.compforge/scripts/setup/init.sh` leaves an `AGENTS.md` pointer and
`compforge-lock.json` in the project and delivers ESLint zones or steiger.
`--verify` re-runs the negative self-test later.

## Update after pull

```bash
cd ~/.compforge && git pull && ./scripts/setup/install.sh update
```

See [Claude Code](claude-code.md) and [Cursor](cursor.md) for the other harnesses.
Release evidence: [harness verification](../verification/harness-v1.0.0.md).
