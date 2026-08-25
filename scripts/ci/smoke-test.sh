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

cyan "==> explicit zero does not force-install into a clean HOME"
ZERO_HOME="$TMP_HOME/zero-home"
mkdir -p "$ZERO_HOME"
HOME="$ZERO_HOME" INSTALL_CLAUDE=0 INSTALL_CODEX=0 "$SETUP_DIR/install.sh"
test ! -e "$ZERO_HOME/.claude/skills/compforge"
test ! -e "$ZERO_HOME/.codex/skills/compforge"

cyan "==> one explicit harness does not enable another"
CODEX_HOME_ONLY="$TMP_HOME/codex-only"
mkdir -p "$CODEX_HOME_ONLY"
HOME="$CODEX_HOME_ONLY" INSTALL_CLAUDE=0 INSTALL_CODEX=1 "$SETUP_DIR/install.sh"
test ! -e "$CODEX_HOME_ONLY/.claude/skills/compforge"
test -L "$CODEX_HOME_ONLY/.codex/skills/compforge"

cyan "==> invalid install flags are rejected"
for name in INSTALL_CLAUDE INSTALL_CODEX; do
  if HOME="$TMP_HOME/invalid-$name" env "$name=yes" "$SETUP_DIR/install.sh" \
    >"$TMP_HOME/invalid-$name.log" 2>&1; then
    printf "FAIL install accepted %s=yes\n" "$name" >&2
    exit 1
  fi
  grep -q "must be 0 or 1" "$TMP_HOME/invalid-$name.log"
done

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

cyan "==> doctor accepts links to another valid pack"
ALT_PACK="$TMP_HOME/alternate-pack"
mkdir -p "$ALT_PACK/skills" "$ALT_PACK/commands" \
  "$ALT_PACK/.claude-plugin" "$ALT_PACK/.codex-plugin"
touch "$ALT_PACK/skills/SKILL.md" \
  "$ALT_PACK/.claude-plugin/plugin.json" "$ALT_PACK/.codex-plugin/plugin.json"
doctor_output="$(COMPFORGE_HOME="$ALT_PACK" "$SETUP_DIR/doctor.sh" 2>&1)"
printf '%s\n' "$doctor_output"
printf '%s\n' "$doctor_output" | grep -q "another valid Compforge pack"

cyan "==> doctor rejects the wrong component of a valid pack"
rm "$HOME/.claude/commands/compforge"
ln -s "$PACK_DIR/skills" "$HOME/.claude/commands/compforge"
if "$SETUP_DIR/doctor.sh" >"$TMP_HOME/wrong-component.log" 2>&1; then
  printf "FAIL doctor accepted a commands link to the skills directory\n" >&2
  exit 1
fi
grep -q "link target mismatch" "$TMP_HOME/wrong-component.log"
rm "$HOME/.claude/commands/compforge"
ln -s "$PACK_DIR/commands" "$HOME/.claude/commands/compforge"

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
if "$SETUP_DIR/doctor.sh" >"$TMP_HOME/invalid-link.log" 2>&1; then
  printf "FAIL doctor accepted a link to a non-pack directory\n" >&2
  exit 1
fi
grep -q "link target mismatch" "$TMP_HOME/invalid-link.log"
"$SETUP_DIR/uninstall.sh"
test -L "$HOME/.codex/skills/compforge"
test "$(readlink "$HOME/.codex/skills/compforge")" = "$HOME/other-skills"

green "==> Smoke test passed"
