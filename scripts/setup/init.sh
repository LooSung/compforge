#!/usr/bin/env bash
#
# compforge init — deliver Compforge's enforcement into a target project.
#
# Copies the stack's enforcement template (ESLint import zones or steiger),
# generates per-feature zones from the directories that actually exist,
# installs a GitHub Actions check, and then runs a negative self-test: a
# deliberate violation must fail lint. A silent no-op (the .ts resolver trap)
# cannot survive an install.
#
# What it never does: overwrite a file it did not generate, install npm
# dependencies, or touch package.json. Existing files get a printed merge
# snippet instead.
#
# Usage:
#   ./scripts/setup/init.sh [--stack react-vite-feature|react-vite-fsd] [target-dir]
#   ./scripts/setup/init.sh --dry-run [target-dir]

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/setup/lib/common.sh
source "$SETUP_DIR/lib/common.sh"

PACK_DIR="$(compforge_pack_dir "$SETUP_DIR")"
TEMPLATES="$PACK_DIR/templates"
STACK=""
TARGET=""
DRY_RUN=0

usage() {
  cat <<USAGE
compforge init

Usage:
  init.sh [--stack react-vite-feature|react-vite-fsd] [--dry-run] [target-dir]

target-dir defaults to the current directory. The stack is detected from the
src/ layout; pass --stack when detection reports ambiguity.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --stack) STACK="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) red "unknown flag: $1"; usage; exit 2 ;;
    *) TARGET="$1"; shift ;;
  esac
done

TARGET="$(cd "${TARGET:-.}" && pwd)"

if [ ! -f "$TARGET/package.json" ]; then
  red "no package.json in $TARGET — run init inside a project."
  exit 2
fi

# --- stack detection -------------------------------------------------------

detect_stack() {
  local fsd=0 feature=0
  for layer in entities widgets pages; do
    [ -d "$TARGET/src/$layer" ] && fsd=1
  done
  [ -d "$TARGET/src/features" ] && feature=1

  if [ "$fsd" = 1 ]; then
    printf 'react-vite-fsd'
  elif [ "$feature" = 1 ]; then
    printf 'react-vite-feature'
  else
    printf ''
  fi
}

if [ -z "$STACK" ]; then
  STACK="$(detect_stack)"
  if [ -z "$STACK" ]; then
    red "cannot detect the stack from $TARGET/src (no features/ and no FSD layers)."
    red "Pass --stack react-vite-feature or --stack react-vite-fsd; do not guess."
    exit 2
  fi
  cyan "detected stack: $STACK"
else
  case "$STACK" in
    react-vite-feature|react-vite-fsd) ;;
    *) red "unknown stack: $STACK"; exit 2 ;;
  esac
fi

# --- helpers ---------------------------------------------------------------

have_dep() {
  python3 - "$TARGET/package.json" "$1" <<'PY'
import json, sys
pkg = json.load(open(sys.argv[1]))
deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}
sys.exit(0 if sys.argv[2] in deps else 1)
PY
}

write_file() { # $1 = destination, stdin = content
  if [ "$DRY_RUN" = 1 ]; then
    yellow "dry-run: would write $1"
    cat >/dev/null
  else
    mkdir -p "$(dirname "$1")"
    cat >"$1"
    green "wrote $1"
  fi
}

MISSING_DEPS=()

require_dep() {
  if ! have_dep "$1"; then
    MISSING_DEPS+=("$1")
  fi
}

# --- feature stack ---------------------------------------------------------

init_feature() {
  local config="$TARGET/eslint.compforge.config.js"

  # Generate or regenerate: the file is ours by name; only the marked block
  # is rewritten, so edits outside it survive a re-run.
  python3 - "$TEMPLATES/react-vite-feature/eslint.compforge.config.js" "$config" "$TARGET" "$DRY_RUN" <<'PY'
import sys
from pathlib import Path

template, config, target, dry = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3]), sys.argv[4] == "1"
BEGIN = "// BEGIN COMPFORGE GENERATED FEATURE ZONES (do not edit; re-run compforge init)"
END = "// END COMPFORGE GENERATED FEATURE ZONES"

features_dir = target / "src" / "features"
features = sorted(
    p.name for p in features_dir.iterdir()
    if p.is_dir() and not p.name.startswith(("_", "."))
) if features_dir.is_dir() else []

indent = " " * 12
zones = []
for name in features:
    zones.append(
        f"{indent}{{\n"
        f"{indent}  target: './src/features/{name}',\n"
        f"{indent}  from: './src/features',\n"
        f"{indent}  except: ['./{name}'],\n"
        f"{indent}  message: 'No cross-feature imports; compose features at the app level.',\n"
        f"{indent}}},"
    )
block = "\n".join(zones)

source = config if config.exists() else template
text = source.read_text(encoding="utf-8")
if BEGIN not in text or END not in text:
    sys.stderr.write(f"marker block missing in {source}; not touching it.\n")
    sys.exit(3)

head, rest = text.split(BEGIN, 1)
_, tail = rest.split(END, 1)
body = head + BEGIN + ("\n" + block + "\n" + indent if block else "\n" + indent) + END + tail

if dry:
    print(f"dry-run: would write {config} with {len(features)} feature zone(s): {', '.join(features) or '(none)'}")
else:
    config.write_text(body, encoding="utf-8")
    print(f"wrote {config} with {len(features)} feature zone(s): {', '.join(features) or '(none)'}")
PY

  if [ ! -f "$TARGET/eslint.config.js" ] && [ ! -f "$TARGET/eslint.config.mjs" ]; then
    write_file "$TARGET/eslint.config.js" <<'EOF'
import compforge from './eslint.compforge.config.js';

export default [...compforge];
EOF
  else
    yellow "eslint.config.js already exists — not touched. Merge with:"
    printf '\n  import compforge from '\''./eslint.compforge.config.js'\'';\n  // then spread ...compforge into your exported array\n\n'
  fi

  require_dep eslint
  require_dep eslint-plugin-import
  require_dep typescript-eslint

  CHECK_CMD="npx eslint --config eslint.compforge.config.js src"
}

# --- fsd stack ---------------------------------------------------------------

init_fsd() {
  if [ -f "$TARGET/steiger.config.ts" ]; then
    yellow "steiger.config.ts already exists — not touched. Compare against:"
    yellow "  $TEMPLATES/react-vite-fsd/steiger.config.ts"
  else
    write_file "$TARGET/steiger.config.ts" <"$TEMPLATES/react-vite-fsd/steiger.config.ts"
  fi

  require_dep steiger
  require_dep '@feature-sliced/steiger-plugin'

  CHECK_CMD="npx steiger src"
}

# --- workflow ----------------------------------------------------------------

install_workflow() {
  local wf="$TARGET/.github/workflows/compforge-check.yml"
  if [ -f "$wf" ]; then
    yellow "$wf already exists — not touched."
  else
    sed "s|__COMPFORGE_CHECK_CMD__|$CHECK_CMD|" "$TEMPLATES/github/compforge-check.yml" | write_file "$wf"
  fi
}

# --- negative self-test ------------------------------------------------------
# The point: prove the installed mechanism can fail. A violation must exit
# non-zero naming the rule, and a compliant file must pass — otherwise the
# enforcement is a silent no-op and init refuses to report success.

selftest_feature() {
  local st="$TARGET/.compforge-selftest"
  rm -rf "$st"
  mkdir -p "$st/src/features/cf_a" "$st/src/features/cf_b" "$st/src/shared"

  printf 'export const util = 1;\n' >"$st/src/features/cf_b/util.ts"
  printf "import { util } from '../cf_b/util';\nexport const a = util;\n" >"$st/src/features/cf_a/index.ts"
  printf 'export const ok = 2;\n' >"$st/src/shared/ok.ts"

  # Same template, zones for the fixture features; imports resolve against the
  # target's node_modules because the config lives inside the target tree.
  python3 - "$TEMPLATES/react-vite-feature/eslint.compforge.config.js" "$st/eslint.selftest.config.js" <<'PY'
import sys
from pathlib import Path
template, out = Path(sys.argv[1]), Path(sys.argv[2])
BEGIN = "// BEGIN COMPFORGE GENERATED FEATURE ZONES (do not edit; re-run compforge init)"
END = "// END COMPFORGE GENERATED FEATURE ZONES"
indent = " " * 12
zone = (
    f"{indent}{{\n"
    f"{indent}  target: './src/features/cf_a',\n"
    f"{indent}  from: './src/features',\n"
    f"{indent}  except: ['./cf_a'],\n"
    f"{indent}}},"
)
text = template.read_text(encoding="utf-8")
head, rest = text.split(BEGIN, 1)
_, tail = rest.split(END, 1)
out.write_text(head + BEGIN + "\n" + zone + "\n" + indent + END + tail, encoding="utf-8")
PY

  local out rc=0
  out="$(cd "$st" && npx eslint --no-config-lookup --config eslint.selftest.config.js src 2>&1)" || rc=$?
  if [ "$rc" -eq 0 ] || ! printf '%s' "$out" | grep -q 'no-restricted-paths'; then
    red "SELF-TEST FAILED: a deliberate cross-feature import did not trip the zone rule."
    red "The enforcement would be a silent no-op. Raw output:"
    printf '%s\n' "$out"
    rm -rf "$st"
    exit 3
  fi

  rc=0
  out="$(cd "$st" && npx eslint --no-config-lookup --config eslint.selftest.config.js src/shared 2>&1)" || rc=$?
  if [ "$rc" -ne 0 ]; then
    red "SELF-TEST FAILED: a compliant file did not pass (config error, not a violation):"
    printf '%s\n' "$out"
    rm -rf "$st"
    exit 3
  fi

  rm -rf "$st"
  green "self-test passed: violation fails, compliant file passes."
}

selftest_fsd() {
  local st="$TARGET/.compforge-selftest"
  rm -rf "$st"
  mkdir -p "$st/src/features/cf-a/ui" "$st/src/features/cf-b/ui"
  printf 'export const B = 1;\n' >"$st/src/features/cf-b/ui/b.ts"
  printf 'export { B } from "../../cf-b/ui/b";\n' >"$st/src/features/cf-a/ui/a.ts"
  printf 'export {};\n' >"$st/src/features/cf-a/index.ts"
  printf 'export {};\n' >"$st/src/features/cf-b/index.ts"
  cp "$TEMPLATES/react-vite-fsd/steiger.config.ts" "$st/steiger.config.ts"

  local out rc=0
  out="$(cd "$st" && npx steiger src 2>&1)" || rc=$?
  if [ "$rc" -eq 0 ] || ! printf '%s' "$out" | grep -q 'forbidden-imports'; then
    red "SELF-TEST FAILED: a deliberate cross-feature import did not trip fsd/forbidden-imports."
    red "The enforcement would be a silent no-op (or steiger crashed). Raw output:"
    printf '%s\n' "$out"
    rm -rf "$st"
    exit 3
  fi

  rm -rf "$st"
  green "self-test passed: steiger fails on a cross-feature import."
}

# --- run ---------------------------------------------------------------------

cyan "compforge init → $TARGET ($STACK)"

case "$STACK" in
  react-vite-feature) init_feature ;;
  react-vite-fsd) init_fsd ;;
esac

install_workflow

if [ "${#MISSING_DEPS[@]}" -gt 0 ]; then
  yellow "missing devDependencies: ${MISSING_DEPS[*]}"
  yellow "install them, then re-run init to complete the self-test:"
  printf '\n  npm install -D %s\n\n' "${MISSING_DEPS[*]}"
  red "init incomplete: enforcement is not live until the self-test passes."
  exit 2
fi

if [ "$DRY_RUN" = 1 ]; then
  yellow "dry-run: skipping self-test."
  exit 0
fi

case "$STACK" in
  react-vite-feature) selftest_feature ;;
  react-vite-fsd) selftest_fsd ;;
esac

green "compforge init complete: zones installed, CI workflow ready, self-test green."
