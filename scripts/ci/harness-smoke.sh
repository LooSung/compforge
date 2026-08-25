#!/usr/bin/env bash
#
# Static packaging checks and authenticated harness activation probes.

set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMP_DIRS=()
ACTIVATION_TOKEN="COMPFORGE_ACTIVATION_PROBE"
NEGATIVE_PROBE="$ACTIVATION_TOKEN. If no loaded Compforge instruction defines \
this probe, output exactly COMPFORGE_NOT_LOADED."

green() { printf "\033[32m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*" >&2; }
probe_step() { printf "RUN %s\n" "$*" >&2; }

# shellcheck source=scripts/ci/harness/probes.sh
source "$PACK_DIR/scripts/ci/harness/probes.sh"
trap cleanup EXIT

static_smoke() {
  python3 "$PACK_DIR/scripts/ci/harness/static_packaging.py" "$PACK_DIR"
}

link_codex_auth() {
  local target_home="$1"
  local source_home="${CODEX_HOME:-$HOME/.codex}"
  mkdir -p "$target_home"
  if [ -f "$source_home/auth.json" ]; then
    ln -s "$source_home/auth.json" "$target_home/auth.json"
  elif [ -z "${CODEX_API_KEY:-}" ]; then
    red "FAIL Codex requires CODEX_API_KEY or $source_home/auth.json"
    exit 1
  fi
}

validate_claude_candidate() {
  local validation_dir="$1"
  local probe_name="$2"
  mkdir -p "$validation_dir/.claude-plugin"
  cp "$PACK_DIR/.claude-plugin/plugin.json" \
    "$validation_dir/.claude-plugin/plugin.json"
  ln -s "$PACK_DIR/skills" "$validation_dir/skills"
  mkdir "$validation_dir/commands"
  cp "$PACK_DIR/commands/"*.md "$validation_dir/commands/"
  cat > "$validation_dir/commands/$probe_name.md" <<EOF
---
name: $probe_name
description: Verify that this exact Compforge candidate plugin loaded.
---

Output exactly these four lines and stop:

\`\`\`text
COMPFORGE_PLUGIN_ROOT=\${CLAUDE_PLUGIN_ROOT}
COMPFORGE_LOADED
Assumptions
Component Contract
\`\`\`
EOF
  claude plugin validate --strict "$validation_dir" >&2
}

live_claude() {
  require_command claude
  local run_dir candidate_dir probe_name positive negative
  run_dir="$(mktemp -d)"
  TEMP_DIRS+=("$run_dir")
  candidate_dir="$run_dir/candidate"
  probe_name="harness-probe-$$-$RANDOM"
  validate_claude_candidate "$candidate_dir" "$probe_name"
  claude --version >&2
  positive="$run_dir/positive.txt"
  negative="$run_dir/negative.txt"
  (
    cd "$run_dir"
    probe_step "Claude session-plugin command positive"
    run_timed claude --plugin-dir "$candidate_dir" -p --no-session-persistence \
      --permission-mode dontAsk --tools "" \
      >"$positive" <<<"/compforge:$probe_name"
    for name in refactor consult; do
      probe_step "Claude $name command positive"
      run_timed claude --plugin-dir "$candidate_dir" -p --no-session-persistence \
        --permission-mode dontAsk --tools "" \
        >"$run_dir/claude-$name.txt" <<<"/compforge:$name $ACTIVATION_TOKEN"
    done
    probe_step "Claude safe-mode negative"
    run_timed claude --safe-mode -p --no-session-persistence \
      --permission-mode plan --tools "" >"$negative" <<<"$NEGATIVE_PROBE"
  )
  if [ -n "${COMPFORGE_HARNESS_OUT:-}" ]; then
    mkdir -p "$COMPFORGE_HARNESS_OUT"
    cp "$positive" "$COMPFORGE_HARNESS_OUT/claude-positive.txt"
    cp "$negative" "$COMPFORGE_HARNESS_OUT/claude-negative.txt"
    cp "$run_dir/claude-refactor.txt" "$COMPFORGE_HARNESS_OUT/claude-refactor.txt"
    cp "$run_dir/claude-consult.txt" "$COMPFORGE_HARNESS_OUT/claude-consult.txt"
  fi
  assert_claude_candidate "$positive" "$candidate_dir"
  assert_positive "$run_dir/claude-refactor.txt"
  assert_positive "$run_dir/claude-consult.txt"
  assert_negative "$negative"
}

live_codex() {
  require_command codex
  codex --version >&2
  local run_dir workspace positive_home negative_home positive negative
  run_dir="$(mktemp -d)"
  TEMP_DIRS+=("$run_dir")
  workspace="$run_dir/workspace"
  positive_home="$run_dir/codex-positive"
  negative_home="$run_dir/codex-negative"
  positive="$run_dir/positive.txt"
  negative="$run_dir/negative.txt"
  mkdir -p "$workspace" "$positive_home/skills"
  link_codex_auth "$positive_home"
  link_codex_auth "$negative_home"
  ln -s "$PACK_DIR/skills" "$positive_home/skills/compforge"
  probe_step "Codex global-skill positive"
  CODEX_HOME="$positive_home" run_timed codex exec --skip-git-repo-check \
    --ignore-user-config --ephemeral --sandbox read-only -C "$workspace" \
    -o "$positive" "Use Compforge craft: $NEGATIVE_PROBE"
  for name in refactor consult; do
    probe_step "Codex $name positive"
    CODEX_HOME="$positive_home" run_timed codex exec --skip-git-repo-check \
      --ignore-user-config --ephemeral --sandbox read-only -C "$workspace" \
      -o "$run_dir/codex-$name.txt" "Use Compforge $name: $NEGATIVE_PROBE"
  done
  probe_step "Codex isolated negative"
  CODEX_HOME="$negative_home" run_timed codex exec --skip-git-repo-check \
    --ignore-user-config --ephemeral --sandbox read-only -C "$workspace" \
    -o "$negative" "$NEGATIVE_PROBE"
  if [ -n "${COMPFORGE_HARNESS_OUT:-}" ]; then
    mkdir -p "$COMPFORGE_HARNESS_OUT"
    cp "$positive" "$COMPFORGE_HARNESS_OUT/codex-positive.txt"
    cp "$negative" "$COMPFORGE_HARNESS_OUT/codex-negative.txt"
    cp "$run_dir/codex-refactor.txt" "$COMPFORGE_HARNESS_OUT/codex-refactor.txt"
    cp "$run_dir/codex-consult.txt" "$COMPFORGE_HARNESS_OUT/codex-consult.txt"
  fi
  assert_positive "$positive"
  assert_positive "$run_dir/codex-refactor.txt"
  assert_positive "$run_dir/codex-consult.txt"
  assert_negative "$negative"
}

seed_cursor_auth() {
  local target_dir="$1"
  local source="${CURSOR_CONFIG_DIR:-$HOME/.cursor}/cli-config.json"
  [ -n "${CURSOR_API_KEY:-}" ] && return
  [ -f "$source" ] || {
    red "FAIL Cursor requires a local login or CURSOR_API_KEY"
    exit 1
  }
  python3 - "$source" "$target_dir/cli-config.json" <<'PY'
import json
import pathlib
import sys

source = json.loads(pathlib.Path(sys.argv[1]).read_text())
safe = {key: source[key] for key in ("version", "authInfo") if key in source}
pathlib.Path(sys.argv[2]).write_text(json.dumps(safe))
PY
}

run_cursor() {
  local workspace="$1"
  local output="$2"
  local prompt="$3"
  shift 3
  mkdir -p "$workspace/.cursor-config"
  seed_cursor_auth "$workspace/.cursor-config"
  CURSOR_CONFIG_DIR="$workspace/.cursor-config" run_timed cursor-agent \
    --print --mode ask --trust --workspace "$workspace" "$@" "$prompt" \
    >"$output"
}

live_cursor() {
  require_command cursor-agent
  cursor-agent --version >&2
  local run_dir plugin_workspace local_workspace clean_workspace slash_workspace
  local plugin_output local_output negative_output slash_output
  run_dir="$(mktemp -d)"
  TEMP_DIRS+=("$run_dir")
  plugin_workspace="$run_dir/plugin"
  local_workspace="$run_dir/project-local"
  clean_workspace="$run_dir/clean"
  slash_workspace="$run_dir/slash"
  plugin_output="$run_dir/plugin.txt"
  local_output="$run_dir/project-local.txt"
  negative_output="$run_dir/negative.txt"
  slash_output="$run_dir/slash.txt"
  mkdir -p "$plugin_workspace" "$local_workspace/.cursor/skills" \
    "$clean_workspace" "$slash_workspace"
  probe_step "Cursor explicit-plugin positive"
  run_cursor "$plugin_workspace" "$plugin_output" \
    "Use Compforge craft: $NEGATIVE_PROBE" --plugin-dir "$PACK_DIR"
  for name in refactor consult; do
    probe_step "Cursor $name positive"
    mkdir -p "$run_dir/$name"
    run_cursor "$run_dir/$name" "$run_dir/cursor-$name.txt" \
      "Use Compforge $name: $NEGATIVE_PROBE" --plugin-dir "$PACK_DIR"
  done
  ln -s "$PACK_DIR/skills" "$local_workspace/.cursor/skills/compforge"
  probe_step "Cursor project-local positive"
  run_cursor "$local_workspace" "$local_output" \
    "Use Compforge craft: $NEGATIVE_PROBE" --add-dir "$PACK_DIR"
  probe_step "Cursor isolated negative"
  run_cursor "$clean_workspace" "$negative_output" "$NEGATIVE_PROBE"
  probe_step "Cursor /compforge:craft slash with --plugin-dir"
  run_cursor "$slash_workspace" "$slash_output" \
    "/compforge:craft $ACTIVATION_TOKEN" --plugin-dir "$PACK_DIR"
  if [ -n "${COMPFORGE_HARNESS_OUT:-}" ]; then
    mkdir -p "$COMPFORGE_HARNESS_OUT"
    cp "$plugin_output" "$COMPFORGE_HARNESS_OUT/cursor-plugin.txt"
    cp "$local_output" "$COMPFORGE_HARNESS_OUT/cursor-project-local.txt"
    cp "$negative_output" "$COMPFORGE_HARNESS_OUT/cursor-negative.txt"
    cp "$slash_output" "$COMPFORGE_HARNESS_OUT/cursor-slash.txt"
    cp "$run_dir/cursor-refactor.txt" "$COMPFORGE_HARNESS_OUT/cursor-refactor.txt"
    cp "$run_dir/cursor-consult.txt" "$COMPFORGE_HARNESS_OUT/cursor-consult.txt"
  fi
  assert_positive "$plugin_output"
  assert_positive "$run_dir/cursor-refactor.txt"
  assert_positive "$run_dir/cursor-consult.txt"
  assert_positive "$local_output"
  assert_negative "$negative_output"
  report_slash "$slash_output"
}

usage() {
  echo "Usage: $0 static|assert-positive FILE|assert-negative FILE|live HARNESS"
  echo "HARNESS: claude, codex, cursor, or all"
}

case "${1:-}" in
  static)
    static_smoke
    ;;
  assert-positive)
    assert_positive "${2:?output file required}"
    ;;
  assert-negative)
    assert_negative "${2:?output file required}"
    ;;
  live)
    case "${2:-}" in
      claude) live_claude ;;
      codex) live_codex ;;
      cursor) live_cursor ;;
      all)
        live_claude
        live_codex
        live_cursor
        ;;
      *) usage; exit 2 ;;
    esac
    ;;
  *)
    usage
    exit 2
    ;;
esac
