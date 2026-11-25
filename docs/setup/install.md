# Install, update, and remove Compforge

## Latest `main`

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LooSung/compforge/main/scripts/setup/bootstrap.sh)"
```

The bootstrap clones or updates `~/.compforge` and installs detected Claude Code
and Codex links. It does not configure Cursor; follow the
[Cursor setup](cursor.md).

## Claude Code plugin marketplace (experimental)

```text
/plugin marketplace add LooSung/compforge
/plugin install compforge@forge
```

Read permission, update, and removal:
[Claude Code setup](claude-code.md#plugin-marketplace-experimental).

## A pinned release

```bash
git clone https://github.com/LooSung/compforge ~/.compforge
cd ~/.compforge
git checkout v1.12.1
chmod +x scripts/setup/*.sh
./scripts/setup/install.sh
./scripts/setup/doctor.sh
```

Canonical install paths and invocation contracts live in
[support scope](../reference/support-scope.md#canonical-harness-paths).
Harness-specific controls live in the [Claude Code](claude-code.md),
[Codex](codex.md), and [Cursor](cursor.md) guides.

## Update

A GitHub Release does not update an existing clone:

```bash
cd ~/.compforge && git pull && ./scripts/setup/install.sh update
```

That command is for a `main`-tracking clone. A release-pinned clone must
`git fetch --tags`, check out the chosen newer tag, and then run
`./scripts/setup/install.sh update`.

Cursor's `--plugin-dir` link and any project-local skill are not managed by
`install.sh`; after the pull, restart the agent.

## Verify and troubleshoot

Run these commands from `~/.compforge`:

```bash
./scripts/setup/doctor.sh              # pack structure and installed links
./scripts/setup/install.sh --dry-run   # planned link changes
./scripts/setup/install.sh --force     # replace conflicting symlinks
./scripts/ci/harness-smoke.sh static   # packaged harness contracts
./scripts/ci/smoke-test.sh             # clean-HOME install lifecycle
```

`doctor.sh` validates pack structure and links; it does not prove Craft loaded.
From a development checkout, doctor checks that checkout's structure but
validates links against `$COMPFORGE_HOME` or `~/.compforge`; another valid pack
warns, while a non-pack target fails. Verify activation with the relevant
harness guide: [Claude Code](claude-code.md) · [Codex](codex.md) ·
[Cursor](cursor.md).

## Remove

```bash
./scripts/setup/uninstall.sh
```

This removes only managed Claude and Codex links that still point at this pack.
Cursor and project-local removal steps live in
[the Cursor guide](cursor.md#4-update-or-remove).
