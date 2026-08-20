# Claude Code Setup

Compforge is **fully supported** on Claude Code via symlink install.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LooSung/compforge/main/scripts/setup/bootstrap.sh)"
```

Restart Claude Code. Verify:

```bash
~/.compforge/scripts/setup/doctor.sh
```

`doctor.sh` checks the pack and Claude/Codex links. It does not execute Craft.
Restart Claude Code, then use `/compforge:craft`.

Installed paths:

- `~/.claude/skills/compforge`
- `~/.claude/commands/compforge`

Start Claude Code from the frontend project you want to change. If you are
maintaining Compforge itself, start from the Compforge repository and treat that
repository as the work target.

Optional: put enforcement into the project.

```bash
~/.compforge/scripts/setup/init.sh
```

## Slash commands

```text
/compforge:craft Start Discovery for the checkout flow. No code yet.
/compforge:craft Add a quantity stepper to the cart item
/compforge:craft Refactor the imported cart module without changing behavior
```

## Update after pull

```bash
cd ~/.compforge && git pull && ./scripts/setup/install.sh update
```

Skill content updates immediately via symlinks; re-run `scripts/setup/install.sh update` when new link targets are added.

## Reference example

```text
Use examples/todo-react-feature as the structural reference for the filter in the URL.
```

See [Codex](./codex.md) and [Cursor](./cursor.md) for the other harnesses.
