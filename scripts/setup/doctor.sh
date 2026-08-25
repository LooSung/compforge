#!/usr/bin/env bash
#
# Compforge doctor
# Validates local pack structure and installed symlinks.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/setup/lib/common.sh
source "$SETUP_DIR/lib/common.sh"

PACK_DIR="$(compforge_pack_dir "$SETUP_DIR")"
INSTALLED_PACK_DIR="$(compforge_installed_pack_dir "$SETUP_DIR")"
FAILED=0

ok() { green "OK $*"; }
warn() { yellow "WARN $*"; }
fail() { red "FAIL $*"; FAILED=1; }

check_file() {
  local path="$1"
  if [ -f "$PACK_DIR/$path" ]; then
    ok "$path"
  else
    fail "missing file: $path"
  fi
}

check_dir() {
  local path="$1"
  if [ -d "$PACK_DIR/$path" ]; then
    ok "$path/"
  else
    fail "missing directory: $path/"
  fi
}

check_link() {
  local label="$1"
  local dst="$2"
  local expected="$3"

  if [ ! -e "$(dirname "$dst")" ]; then
    warn "$label config directory missing: $(dirname "$dst")"
    return
  fi

  if [ ! -L "$dst" ]; then
    warn "$label link missing: $dst"
    return
  fi

  local actual actual_path expected_path actual_root
  actual="$(readlink "$dst")"
  case "$actual" in
    /*) actual_path="$actual" ;;
    *) actual_path="$(dirname "$dst")/$actual" ;;
  esac
  if [ -d "$actual_path" ]; then
    actual_path="$(cd "$actual_path" && pwd -P)"
  fi
  if [ -d "$expected" ]; then
    expected_path="$(cd "$expected" && pwd -P)"
  else
    expected_path="$expected"
  fi

  if [ "$actual_path" = "$expected_path" ]; then
    ok "$label link: $dst -> $actual"
    return
  fi

  actual_root="$(dirname "$actual_path")"
  if [ "$(basename "$actual_path")" = "$(basename "$expected_path")" ] &&
    compforge_is_pack_dir "$actual_root"; then
    warn "$label link points to another valid Compforge pack: $dst -> $actual (installed: $expected)"
    return
  fi

  fail "$label link target mismatch: $dst -> $actual (expected: $expected)"
}

check_command() {
  local command_name="$1"
  if command -v "$command_name" >/dev/null 2>&1; then
    ok "$command_name found: $(command -v "$command_name")"
  else
    warn "$command_name not found"
  fi
}

cyan "==> Compforge doctor"

cyan "--- Pack structure"
check_dir "skills"
check_dir "skills/workflow"
check_dir "skills/react"
check_dir "skills/lang"
check_dir "skills/skeleton"
check_dir "skills/principles"
check_dir "skills/antipatterns"
check_dir "skills/playbooks"
check_dir "commands"
check_dir ".claude-plugin"
check_dir ".codex-plugin"
check_dir ".cursor-plugin"
check_dir "scripts/setup"
check_dir "scripts/ci"
check_dir "templates"
check_file "templates/agents/compforge-block.md"
check_file "templates/react-vite-feature/eslint.compforge.config.js"
check_file "templates/react-next-app/eslint.compforge.config.js"
check_file "templates/react-vite-fsd/steiger.config.ts"
check_file "templates/react-vite-fsd/eslint.compforge.config.js"
check_file "templates/github/compforge-check.yml"
check_file "templates/github/compforge-architecture-review.yml"
check_file "scripts/setup/bootstrap.sh"
check_file "scripts/setup/init.sh"
check_file "scripts/setup/install.sh"
check_file "scripts/setup/uninstall.sh"
check_file "scripts/setup/doctor.sh"
check_file "scripts/setup/lib/common.sh"
check_file "scripts/setup/lib/init-core.sh"
check_file "scripts/setup/lib/init-delivery.sh"
check_file "scripts/setup/lib/init-selftest.sh"
check_file "scripts/ci/lint-skills.sh"
check_file "scripts/ci/smoke-test.sh"
check_file "scripts/ci/init-smoke.sh"
check_file "scripts/ci/harness-smoke.sh"
check_file "scripts/ci/harness/probes.sh"
check_file "scripts/ci/harness/static_packaging.py"
check_file "scripts/ci/check-maintained-file-sizes.py"
check_file "scripts/ci/run-with-timeout.py"
check_file "scripts/ci/check-doc-links.py"
check_file "docs/reference/support-scope.md"
check_file "docs/README.md"
check_file ".github/SECURITY.md"
check_file "SECURITY.md"
check_file "skills/stability.json"
check_file "skills/SKILL.md"
check_file "skills/workflow/delivery-plan.md"
check_file "skills/playbooks/feature.md"
check_file "skills/playbooks/bug-fix.md"
check_file "skills/principles/hard-rules.md"
check_file "skills/skeleton/lint-enforcement.md"
check_file "scripts/ci/review/main.py"
check_file ".claude-plugin/plugin.json"
check_file ".codex-plugin/plugin.json"
check_file ".cursor-plugin/plugin.json"
check_file ".cursor-plugin/skills/compforge/SKILL.md"

cyan "--- Harness commands"
check_command "claude"
check_command "codex"
check_command "cursor-agent"

cyan "--- Cursor Agent CLI"
if command -v cursor-agent >/dev/null 2>&1; then
  ok "CLI found; see docs/setup/cursor.md for the verified --plugin-dir setup"
else
  warn "cursor-agent not found (install Cursor CLI to use Compforge with Cursor)"
fi
warn "Cursor is not installed automatically; doctor does not prove Craft loaded. See docs/setup/cursor.md."

cyan "--- Installed links"
if ! compforge_is_pack_dir "$INSTALLED_PACK_DIR"; then
  fail "invalid installed pack root: $INSTALLED_PACK_DIR"
elif [ "$INSTALLED_PACK_DIR" != "$PACK_DIR" ]; then
  warn "checking pack at $PACK_DIR; installed links resolve from $INSTALLED_PACK_DIR"
fi
check_link "Claude skills" "$HOME/.claude/skills/compforge" "$INSTALLED_PACK_DIR/skills"
check_link "Claude commands" "$HOME/.claude/commands/compforge" "$INSTALLED_PACK_DIR/commands"
check_link "Codex skills" "$HOME/.codex/skills/compforge" "$INSTALLED_PACK_DIR/skills"


if [ "$FAILED" -eq 0 ]; then
  green "==> doctor complete: no critical issues"
else
  red "==> doctor failed: review FAIL items above"
  exit 1
fi
