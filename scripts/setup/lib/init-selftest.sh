# Negative self-tests and verify mode for compforge init.

selftest_pointer() {
  python3 - "$TARGET/AGENTS.md" "$AGENTS_BEGIN" "$AGENTS_END" <<'PY'
import sys
from pathlib import Path

agents = Path(sys.argv[1])
BEGIN, END = sys.argv[2], sys.argv[3]

if not agents.exists():
    sys.exit(f"SELF-TEST FAILED: {agents} is missing; the constitution pointer was not delivered.")

text = agents.read_text(encoding="utf-8")
if BEGIN not in text or END not in text:
    sys.exit(f"SELF-TEST FAILED: no Compforge marker block in {agents}.")

block = text.split(BEGIN, 1)[1].split(END, 1)[0]
if "__COMPFORGE_" in block:
    sys.exit("SELF-TEST FAILED: an unsubstituted placeholder is left in the block; agents would read a template.")
for needed in ("$COMPFORGE_HOME", "skills/workflow/craft.md", "skills/principles/hard-rules.md"):
    if needed not in block:
        sys.exit(f"SELF-TEST FAILED: the block does not point at {needed}.")
PY
  green "self-test passed: AGENTS.md points at the pack and carries no placeholders."
}

selftest_eslint() {
  local template="$1" zone_kind="$2" build="$3"
  local st="$TARGET/.compforge-selftest"
  rm -rf "$st"
  "$build" "$st"

  python3 - "$template" "$st/eslint.selftest.config.js" "$zone_kind" <<'PY'
import sys
from pathlib import Path
template, out, kind = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
BEGIN = "// BEGIN COMPFORGE GENERATED FEATURE ZONES (do not edit; re-run compforge init)"
END = "// END COMPFORGE GENERATED FEATURE ZONES"
indent = " " * 12
zone = (
    f"{indent}{{\n"
    f"{indent}  target: './src/features/cf_a',\n"
    f"{indent}  from: './src/features',\n"
    f"{indent}  except: ['./cf_a'],\n"
    f"{indent}}},"
) if kind == "cross-feature" else ""
text = template.read_text(encoding="utf-8")
head, rest = text.split(BEGIN, 1)
_, tail = rest.split(END, 1)
out.write_text(head + BEGIN + "\n" + (zone + "\n" if zone else "") + indent + END + tail, encoding="utf-8")
PY

  local out rc=0
  out="$(cd "$st" && npx eslint --no-config-lookup --config eslint.selftest.config.js src 2>&1)" || rc=$?
  if [ "$rc" -eq 0 ] || ! printf '%s' "$out" | grep -q 'no-restricted-paths'; then
    red "SELF-TEST FAILED: a deliberate violation did not trip the zone rule."
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
}

fixture_cross_feature() {
  mkdir -p "$1/src/features/cf_a" "$1/src/features/cf_b" "$1/src/shared"
  printf 'export const util = 1;\n' >"$1/src/features/cf_b/util.ts"
  printf "import { util } from '../cf_b/util';\nexport const a = util;\n" >"$1/src/features/cf_a/index.ts"
  printf 'export const ok = 2;\n' >"$1/src/shared/ok.ts"
}

fixture_server_leak() {
  mkdir -p "$1/src/features/cf_a" "$1/src/server" "$1/src/shared"
  printf 'export const secret = 1;\n' >"$1/src/server/secret.ts"
  printf "import { secret } from '../../server/secret';\nexport const a = secret;\n" >"$1/src/features/cf_a/index.ts"
  printf 'export const ok = 2;\n' >"$1/src/shared/ok.ts"
}

selftest_no_explicit_any() {
  local template="$1"
  local st="$TARGET/.compforge-selftest-any"
  rm -rf "$st"
  mkdir -p "$st/src"
  printf 'export const bad: any = 1;\n' >"$st/src/bad.ts"
  printf 'export const ok: number = 1;\n' >"$st/src/ok.ts"
  cp "$template" "$st/eslint.selftest.config.js"

  local out rc=0
  out="$(cd "$st" && npx eslint --no-config-lookup --config eslint.selftest.config.js src/bad.ts 2>&1)" || rc=$?
  if [ "$rc" -eq 0 ] || ! printf '%s' "$out" | grep -q 'no-explicit-any'; then
    red "SELF-TEST FAILED: a deliberate \`any\` did not trip no-explicit-any."
    red "The enforcement would be a silent no-op. Raw output:"
    printf '%s\n' "$out"
    rm -rf "$st"
    exit 3
  fi

  rc=0
  out="$(cd "$st" && npx eslint --no-config-lookup --config eslint.selftest.config.js src/ok.ts 2>&1)" || rc=$?
  if [ "$rc" -ne 0 ]; then
    red "SELF-TEST FAILED: a file without \`any\` did not pass (config error, not a violation):"
    printf '%s\n' "$out"
    rm -rf "$st"
    exit 3
  fi

  rm -rf "$st"
}

selftest_feature() {
  selftest_eslint "$TEMPLATES/react-vite-feature/eslint.compforge.config.js" cross-feature fixture_cross_feature
  selftest_no_explicit_any "$TEMPLATES/react-vite-feature/eslint.compforge.config.js"
  green "self-test passed: a cross-feature import fails, a compliant file passes, \`any\` fails."
}

selftest_next() {
  local tpl="$TEMPLATES/react-next-app/eslint.compforge.config.js"
  selftest_eslint "$tpl" cross-feature fixture_cross_feature
  selftest_eslint "$tpl" server fixture_server_leak
  selftest_no_explicit_any "$tpl"
  green "self-test passed: cross-feature and server-only imports both fail, compliant files pass, \`any\` fails."
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
  selftest_no_explicit_any "$TEMPLATES/react-vite-fsd/eslint.compforge.config.js"
  green "self-test passed: steiger fails on a cross-feature import, \`any\` fails."
}

run_selftests() {
  selftest_pointer
  case "$STACK" in
    react-vite-feature) selftest_feature ;;
    react-vite-fsd) selftest_fsd ;;
    react-next-app) selftest_next ;;
  esac
}

run_verify() {
  local lock="$TARGET/$LOCK_NAME"
  cyan "compforge verify → $TARGET"

  if [ ! -f "$lock" ]; then
    red "no $LOCK_NAME in $TARGET — run compforge init first."
    exit 2
  fi

  STACK="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["stack"])' "$lock")"
  CHECK_CMD="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["checkCommand"])' "$lock")"
  local locked_version detected
  locked_version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["compforge"]["version"])' "$lock")"

  cyan "locked: compforge $locked_version, stack $STACK"

  detected="$(detect_stack)"
  if [ -n "$detected" ] && [ "$detected" != "$STACK" ]; then
    red "DRIFT: the project now looks like '$detected' but the lock says '$STACK'."
    red "Re-run compforge init so the delivered zones match the project."
    exit 3
  fi

  local installed
  installed="$(pack_version)"
  if [ "$installed" != "$locked_version" ]; then
    yellow "pack version drift: installed $installed, locked $locked_version. Re-run init to re-pin."
  fi

  require_strict_tsconfig
  run_selftests
  green "compforge verify complete: pointer intact, strict tsconfig present, guard still fails on a violation."
}
