#!/usr/bin/env bash
#
# Compforge skill lint
# Enforces the pack's own Hard Rules on skill files:
#   - every skills/**/*.md has YAML frontmatter with name + description
#   - every skill file is 200 lines or less
#   - no legacy skills/compforge/... self-nesting paths are referenced

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"
FAILED=0

red() { printf "\033[31m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }

fail() { red "FAIL $*"; FAILED=1; }

while IFS= read -r -d '' file; do
  rel="${file#"$ROOT_DIR"/}"

  lines="$(wc -l < "$file" | tr -d ' ')"
  if [ "$lines" -gt 200 ]; then
    fail "$rel: $lines lines (limit 200)"
  fi

  if [ "$(head -n 1 "$file")" != "---" ]; then
    fail "$rel: missing YAML frontmatter"
  else
    if ! sed -n '2,10p' "$file" | grep -q '^name:'; then
      fail "$rel: frontmatter missing 'name:'"
    fi
    if ! sed -n '2,10p' "$file" | grep -q '^description:'; then
      fail "$rel: frontmatter missing 'description:'"
    fi
  fi

  if grep -q 'skills/compforge/' "$file"; then
    fail "$rel: references legacy skills/compforge/... path"
  fi
done < <(find "$SKILLS_DIR" -name '*.md' -print0)

if [ "$FAILED" -eq 0 ]; then
  green "==> lint-skills: all skill files pass"
else
  red "==> lint-skills failed"
  exit 1
fi
