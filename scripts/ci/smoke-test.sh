#!/usr/bin/env bash
#
# Compforge smoke test — install and doctor in an isolated HOME.

set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SETUP_DIR="$PACK_DIR/scripts/setup"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

cyan() { printf "\033[36m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }

cyan "==> Compforge smoke test"
cyan "HOME=$TMP_HOME"

export HOME="$TMP_HOME"
export INSTALL_CLAUDE=1
export INSTALL_CODEX=1

mkdir -p "$HOME/.claude" "$HOME/.codex"

"$SETUP_DIR/install.sh"
"$SETUP_DIR/doctor.sh"

test -L "$HOME/.claude/skills/compforge"
test -L "$HOME/.claude/commands/compforge"
test -L "$HOME/.codex/skills/compforge"
test -f "$HOME/.codex/skills/compforge/SKILL.md"

actual_skills="$(readlink "$HOME/.claude/skills/compforge")"
if [ "$actual_skills" != "$PACK_DIR/skills" ]; then
  printf "FAIL skills link: %s (expected %s)\n" "$actual_skills" "$PACK_DIR/skills" >&2
  exit 1
fi

cyan "==> scripts/setup/install.sh update"
"$SETUP_DIR/install.sh" update

test -L "$HOME/.claude/skills/compforge"
test -f "$HOME/.codex/skills/compforge/SKILL.md"

cyan "==> scripts/setup/uninstall.sh"
"$SETUP_DIR/uninstall.sh"

test ! -e "$HOME/.claude/skills/compforge"
test ! -e "$HOME/.claude/commands/compforge"
test ! -e "$HOME/.codex/skills/compforge"

cyan "==> preserve unrelated symlink"
mkdir -p "$HOME/other-skills" "$HOME/.codex/skills"
ln -s "$HOME/other-skills" "$HOME/.codex/skills/compforge"
"$SETUP_DIR/uninstall.sh"
test -L "$HOME/.codex/skills/compforge"
test "$(readlink "$HOME/.codex/skills/compforge")" = "$HOME/other-skills"

green "==> Smoke test passed"
