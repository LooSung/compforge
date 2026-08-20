#!/usr/bin/env bash
#
# Compforge uninstaller
# Removes installed symlinks only. It never deletes the source pack.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/setup/lib/common.sh
source "$SETUP_DIR/lib/common.sh"

PACK_DIR="$(compforge_pack_dir "$SETUP_DIR")"

rm_link() {
  local path="$1"
  local expected="$2"

  if [ -L "$path" ]; then
    local actual
    actual="$(readlink "$path")"
    if [ "$actual" != "$expected" ]; then
      yellow "Different symlink; leaving untouched: $path -> $actual"
      return
    fi
    rm "$path"
    green "Removed: $path"
    return
  fi

  if [ -e "$path" ]; then
    yellow "Not a symlink; leaving untouched: $path"
  fi
}

rm_link "$HOME/.claude/skills/compforge" "$PACK_DIR/skills"
rm_link "$HOME/.claude/commands/compforge" "$PACK_DIR/commands"
rm_link "$HOME/.codex/skills/compforge" "$PACK_DIR/skills"

green "==> Uninstall complete."
