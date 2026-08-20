# Cursor Setup (Experimental)

Use Compforge with **Cursor Agent CLI** (`cursor-agent`) through a
project-local skill. There is no `scripts/setup/install.sh` target for Cursor.

Do not claim `--plugin-dir` auto-loads Craft until a clean Compforge smoke
test proves it. The plugin adapter under `.cursor-plugin/skills/compforge/`
exists for packaging; the verified path today is the project-local skill.

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

## 2. Link the skill into the target project

```bash
cd /path/to/your-frontend-project
mkdir -p .cursor/skills
ln -s ~/.compforge/skills .cursor/skills/compforge
printf '%s\n' '.cursor/skills/compforge' >> .git/info/exclude
```

Start the agent from the target project so paths like `docs/foo.md` resolve in
the app repository. For Compforge maintenance, the pack repository is the work
target.

Optional: `compforge init` delivers ESLint zones or steiger plus a PR check.

```bash
~/.compforge/scripts/setup/init.sh
```

## 3. Run Craft

```text
Use Compforge craft: Add a quantity stepper to the cart item
Use Compforge craft: Read docs/screens/checkout.md and advise only.
```

Planning-only sessions (Discovery, Design, Delivery Plan): ask for that stage
explicitly and do not implement.

If you start Cursor Agent with `--plugin-dir`, treat it as unverified for this
pack. After `git pull` in `~/.compforge`, restart the agent to pick up changes.

## 4. Update or remove

A GitHub Release does not update the local clone:

```bash
cd ~/.compforge && git pull
```

Restart the agent after the pull. Cursor links are not managed by
`scripts/setup/install.sh` or `uninstall.sh`. To unregister the documented
project-local skill:

```bash
rm -f /path/to/your-frontend-project/.cursor/skills/compforge
```

Also remove the matching `.cursor/skills/compforge` line from
`.git/info/exclude` if you added it during setup. The source pack at
`~/.compforge` is kept.

## 5. Example prompts

```text
Use Compforge craft: Add search to the todo list. Keep the query in the URL.
Use Compforge Discovery for the checkout flow. No code yet.
Use Compforge craft: Refactor the cart page without changing behavior.
```

## Verified vs unverified

| Path | Status |
|---|---|
| Project-local `.cursor/skills/compforge` | Documented experimental setup |
| `cursor-agent --plugin-dir …` | Adapter present; **not** claimed until a Compforge smoke test proves it |
| `/compforge:craft` as a Cursor slash command | Unverified |

See [Claude Code](./claude-code.md) and [Codex](./codex.md) for the supported harnesses.
