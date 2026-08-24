#!/usr/bin/env bash
#
# Static packaging checks and authenticated harness activation probes.

set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMP_DIRS=()
SAVED_LINKS=()
ACTIVATION_TOKEN="COMPFORGE_ACTIVATION_PROBE"
NEGATIVE_PROBE="$ACTIVATION_TOKEN. If no loaded Compforge instruction defines \
this probe, output exactly COMPFORGE_NOT_LOADED."

green() { printf "\033[32m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*" >&2; }
probe_step() { printf "RUN %s\n" "$*" >&2; }

restore_links() {
  local entry path target
  set +u
  for entry in "${SAVED_LINKS[@]}"; do
    path="${entry%%=*}"
    target="${entry#*=}"
    ln -sfn "$target" "$path"
  done
  set -u
}

cleanup() {
  local path
  restore_links
  set +u
  for path in "${TEMP_DIRS[@]}"; do
    rm -rf "$path"
  done
  set -u
}

trap cleanup EXIT

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    red "FAIL missing command: $1"
    exit 1
  }
}

require_link_target() {
  local link="$1"
  local expected="$2"
  if [ ! -L "$link" ] || [ "$(readlink "$link")" != "$expected" ]; then
    red "FAIL expected link: $link -> $expected"
    exit 1
  fi
}

save_link() {
  local path="$1"
  if [ -L "$path" ]; then
    SAVED_LINKS+=("$path=$(readlink "$path")")
  fi
}

bind_pack_links() {
  mkdir -p "$HOME/.claude/skills" "$HOME/.claude/commands" "$HOME/.codex/skills"
  save_link "$HOME/.claude/skills/compforge"
  save_link "$HOME/.claude/commands/compforge"
  save_link "$HOME/.codex/skills/compforge"
  ln -sfn "$PACK_DIR/skills" "$HOME/.claude/skills/compforge"
  ln -sfn "$PACK_DIR/commands" "$HOME/.claude/commands/compforge"
  ln -sfn "$PACK_DIR/skills" "$HOME/.codex/skills/compforge"
}

run_timed() {
  python3 "$PACK_DIR/scripts/ci/run-with-timeout.py" \
    "${COMPFORGE_HARNESS_TIMEOUT:-1200}" "$@"
}

probe_failure() {
  local message="$1"
  local output="$2"
  red "FAIL $message"
  printf '%s\n' "--- probe output ---" >&2
  sed -n '1,80p' "$output" >&2
  return 1
}

assert_positive() {
  local output="$1"
  grep -Fxq "COMPFORGE_LOADED" "$output" ||
    { probe_failure "positive probe did not load Compforge" "$output"; return 1; }
  grep -Eq "^Assumptions:?$" "$output" ||
    { probe_failure "positive probe missed Assumptions" "$output"; return 1; }
  grep -Eq "^Component Contract:?$" "$output" ||
    { probe_failure "positive probe missed Component Contract" "$output"; return 1; }
  if grep -Fxq "COMPFORGE_NOT_LOADED" "$output"; then
    probe_failure "positive probe also reported not loaded" "$output"
    return 1
  fi
  green "PASS positive activation probe"
}

assert_negative() {
  local output="$1"
  grep -Fxq "COMPFORGE_NOT_LOADED" "$output" ||
    { probe_failure "negative control did not report isolation" "$output"; return 1; }
  if grep -Fxq "COMPFORGE_LOADED" "$output"; then
    probe_failure "negative control loaded Compforge" "$output"
    return 1
  fi
  green "PASS negative activation control"
}

report_slash() {
  local output="$1"
  if grep -Fxq "COMPFORGE_NOT_LOADED" "$output"; then
    probe_failure "slash reported not loaded while plugin-dir was set" "$output"
    return 1
  fi
  if grep -Fxq "COMPFORGE_LOADED" "$output" ||
     grep -Eq "Compforge Craft|workflow/craft.md" "$output"; then
    green "PASS slash invoked Craft with --plugin-dir"
    return 0
  fi
  probe_failure "slash did not enter Craft" "$output"
  return 1
}

static_smoke() {
  python3 - "$PACK_DIR" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
manifests = [
    root / ".claude-plugin/plugin.json",
    root / ".codex-plugin/plugin.json",
    root / ".cursor-plugin/plugin.json",
]
versions = {json.loads(path.read_text())["version"] for path in manifests}
if len(versions) != 1:
    raise SystemExit("manifest versions differ")

registry = json.loads((root / "skills/stability.json").read_text())
stable = registry["stable"]
experimental = registry["experimental"]
listed = stable + experimental
actual = sorted(
    str(path.relative_to(root))
    for path in (root / "skills").rglob("*.md")
)
if len(listed) != len(set(listed)):
    raise SystemExit("skill stability registry contains duplicates")
if sorted(listed) != actual:
    missing = sorted(set(actual) - set(listed))
    extra = sorted(set(listed) - set(actual))
    raise SystemExit(f"skill stability mismatch: missing={missing}, extra={extra}")
if registry["schema"] != "compforge.skill-stability.v1":
    raise SystemExit("unexpected skill stability schema")
for status in ("stable", "experimental"):
    for relative in registry[status]:
        frontmatter = (root / relative).read_text().split("---", 2)[1]
        if f"stability: {status}" not in frontmatter:
            raise SystemExit(f"stability frontmatter mismatch: {relative}")

required = [
    "commands/craft.md",
    ".cursor-plugin/skills/compforge/SKILL.md",
    "docs/support-scope.md",
    "docs/cursor.md",
    "docs/claude-code.md",
    "docs/codex.md",
]
for relative in required:
    if not (root / relative).is_file():
        raise SystemExit(f"missing harness path: {relative}")
for relative in ["commands/craft.md", "skills/SKILL.md",
                 ".cursor-plugin/skills/compforge/SKILL.md"]:
    if "COMPFORGE_ACTIVATION_PROBE" not in (root / relative).read_text():
        raise SystemExit(f"missing activation probe: {relative}")
print("PASS static harness packaging")
PY
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

live_claude() {
  require_command claude
  bind_pack_links
  require_link_target "$HOME/.claude/skills/compforge" "$PACK_DIR/skills"
  require_link_target "$HOME/.claude/commands/compforge" "$PACK_DIR/commands"
  claude --version >&2
  local run_dir positive negative
  run_dir="$(mktemp -d)"
  TEMP_DIRS+=("$run_dir")
  positive="$run_dir/positive.txt"
  negative="$run_dir/negative.txt"
  (
    cd "$run_dir"
    probe_step "Claude command positive"
    run_timed claude -p --no-session-persistence --permission-mode plan \
      --tools "" >"$positive" <<<"/compforge:craft $ACTIVATION_TOKEN"
    probe_step "Claude safe-mode negative"
    run_timed claude --safe-mode -p --no-session-persistence \
      --permission-mode plan --tools "" >"$negative" <<<"$NEGATIVE_PROBE"
  )
  if [ -n "${COMPFORGE_HARNESS_OUT:-}" ]; then
    mkdir -p "$COMPFORGE_HARNESS_OUT"
    cp "$positive" "$COMPFORGE_HARNESS_OUT/claude-positive.txt"
    cp "$negative" "$COMPFORGE_HARNESS_OUT/claude-negative.txt"
  fi
  assert_positive "$positive"
  assert_negative "$negative"
}

live_codex() {
  require_command codex
  bind_pack_links
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
  probe_step "Codex isolated negative"
  CODEX_HOME="$negative_home" run_timed codex exec --skip-git-repo-check \
    --ignore-user-config --ephemeral --sandbox read-only -C "$workspace" \
    -o "$negative" "$NEGATIVE_PROBE"
  if [ -n "${COMPFORGE_HARNESS_OUT:-}" ]; then
    mkdir -p "$COMPFORGE_HARNESS_OUT"
    cp "$positive" "$COMPFORGE_HARNESS_OUT/codex-positive.txt"
    cp "$negative" "$COMPFORGE_HARNESS_OUT/codex-negative.txt"
  fi
  assert_positive "$positive"
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
  fi
  assert_positive "$plugin_output"
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
