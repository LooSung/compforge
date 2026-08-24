# Cursor Setup

Use Compforge with **Cursor Agent CLI** (`cursor-agent`) through an explicit
local plugin directory or a project-local skill. There is no
`scripts/setup/install.sh` target for Cursor.

## 1. Install Compforge

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LooSung/compforge/main/scripts/setup/bootstrap.sh)"
```

Or clone manually:

```bash
git clone https://github.com/LooSung/compforge ~/.compforge
cd ~/.compforge
chmod +x scripts/setup/*.sh
./scripts/setup/doctor.sh
```

`doctor.sh` checks the pack and Claude/Codex links. It does not register Cursor
or execute Craft.

## 2. Register the local plugin

Link the installed pack into Cursor's local-plugin directory:

```bash
mkdir -p ~/.cursor/plugins/local
ln -s ~/.compforge ~/.cursor/plugins/local/compforge
```

Pass this directory explicitly when starting Cursor Agent. A clean headless
session did not load Craft from an empty workspace without `--plugin-dir`.

Project-local skill links remain a supported alternative. Because the symlink
target is outside the project, include the pack with `--add-dir`:

```bash
cd /path/to/your-frontend-project
mkdir -p .cursor/skills
ln -s ~/.compforge/skills .cursor/skills/compforge
printf '%s\n' '.cursor/skills/compforge' >> .git/info/exclude
```

Start the agent from the target project so paths like `docs/foo.md` resolve in
the app repository. For Compforge maintenance, the pack repository is the work
target.

Optional: `compforge init` leaves an `AGENTS.md` pointer and `compforge-lock.json`
in the project, plus ESLint zones or steiger and a PR check. Unlike the symlink
above, the pointer is committed, so it survives a clone on someone else's machine.

```bash
~/.compforge/scripts/setup/init.sh
~/.compforge/scripts/setup/init.sh --verify   # later: is the guard still alive?
```

## 3. Run Craft

Start Cursor Agent and invoke Craft by name:

```bash
cd /path/to/your-frontend-project
cursor-agent --plugin-dir ~/.cursor/plugins/local/compforge
```

```text
Use Compforge craft: Add a quantity stepper to the cart item
Use Compforge craft: Read docs/screens/checkout.md and advise only.
```

Planning-only sessions (Discovery, Design, Delivery Plan): ask for that stage
explicitly and do not implement.

One-shot (non-interactive):

```bash
cursor-agent --plugin-dir ~/.cursor/plugins/local/compforge \
  -p "Use Compforge craft: Add a quantity stepper to the cart item"
```

If you chose the project-local skill alternative, start with
`cursor-agent --add-dir ~/.compforge` and omit `--plugin-dir`. After
`git pull` in `~/.compforge`, restart the agent to pick up changes.

## 4. Update or remove

A GitHub Release does not update the local clone:

```bash
cd ~/.compforge && git pull
```

Restart the agent after the pull. Cursor links are not managed by
`scripts/setup/install.sh` or `uninstall.sh`. To unregister them:

```bash
rm -f ~/.cursor/plugins/local/compforge
rm -f /path/to/your-frontend-project/.cursor/skills/compforge
```

The second command applies only if you created the project-local alternative.
Also remove the matching `.cursor/skills/compforge` line from
`.git/info/exclude` if you added it during setup. The source pack at
`~/.compforge` is kept.

## 5. Example prompts

```text
Use Compforge craft: Add search to the todo list. Keep the query in the URL.
Use Compforge Discovery for the checkout flow. No code yet.
Use Compforge craft: Refactor the cart page without changing behavior.
```

## Verified paths

Measured on Cursor Agent `2026.08.11-e8db854` in empty temporary workspaces
with `CURSOR_CONFIG_DIR` isolation (2026-08-24).

| Path | Status |
|---|---|
| `cursor-agent --plugin-dir …` + `Use Compforge craft: …` | Verified (activation probe) |
| Project-local `.cursor/skills/compforge` + `--add-dir` | Verified (activation probe) |
| Empty workspace, no plugin, no project skill | Isolated (`COMPFORGE_NOT_LOADED`) |
| `/compforge:craft` with `--plugin-dir` | Enters Craft. Documented invoke remains `Use Compforge craft: …` |
| Directory auto-discovery without `--plugin-dir` | Not claimed |

`/compforge:craft` is Claude Code's installed slash command. On Cursor Agent CLI
it routed to Craft when the plugin was loaded; it is not installed under
`~/.cursor/commands` by `install.sh`.

See [Claude Code](./claude-code.md) and [Codex](./codex.md) for the other harnesses.

### Local plugin smoke evidence

Maintainers can reproduce explicit-plugin, project-local, slash, and no-skill
controls with an authenticated Cursor CLI:

```bash
./scripts/ci/harness-smoke.sh live cursor
```

The check requires `COMPFORGE_LOADED`, Assumptions, and Component Contract from
both supported paths. Its isolated no-skill workspace must return
`COMPFORGE_NOT_LOADED`. Slash with `--plugin-dir` must enter Craft. It uses
temporary workspaces and `CURSOR_CONFIG_DIR` while retaining the real `HOME` so
the OS credential-store token remains available. Only non-secret login metadata
(`version` and `authInfo`) is copied into each temporary config. Never add a
provider key as a repository secret; live smoke remains a local release check.
Static packaging (`./scripts/ci/harness-smoke.sh static`) runs in CI.
