#!/usr/bin/env bash
#
# Compforge setup scripts — shared helpers.

cyan() { printf "\033[36m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*"; }

compforge_pack_dir() {
  local setup_dir="$1"
  cd "$setup_dir/../.." && pwd
}

compforge_is_pack_dir() {
  local candidate="$1"
  [ -f "$candidate/skills/SKILL.md" ] &&
    [ -f "$candidate/.claude-plugin/plugin.json" ] &&
    [ -f "$candidate/.codex-plugin/plugin.json" ]
}

compforge_installed_pack_dir() {
  local setup_dir="$1"
  local candidate

  if [ -n "${COMPFORGE_HOME:-}" ]; then
    candidate="$COMPFORGE_HOME"
  elif compforge_is_pack_dir "$HOME/.compforge"; then
    candidate="$HOME/.compforge"
  else
    compforge_pack_dir "$setup_dir"
    return
  fi

  if [ -d "$candidate" ]; then
    cd "$candidate" && pwd
  else
    printf '%s\n' "$candidate"
  fi
}
