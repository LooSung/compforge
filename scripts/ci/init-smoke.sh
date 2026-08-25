#!/usr/bin/env bash
#
# compforge init smoke — prove the delivered guard is alive on every stack.
#
# For each reference example this checks, in a throwaway copy:
#   1. stack detection matches the expected value (Next used to be reported as
#      react-vite-feature, which silently dropped the src/server boundary);
#   2. init delivers the AGENTS.md pointer, the lock, and the zones, and the
#      negative self-test passes;
#   3. --verify re-runs that self-test from the lock;
#   4. re-running init does not duplicate the pointer block, and hand-written
#      AGENTS.md content survives;
#   5. lock/stack drift is refused;
#   6. the self-test itself can fail — a pack whose template lost the
#      src/server zones must be rejected, not reported green;
#   7. a tsconfig with strict: false is refused;
#   8. a pack whose FSD template lost no-explicit-any is refused.
#
# Usage:
#   ./scripts/ci/init-smoke.sh [example-name ...]
#
# Requires the example's node_modules (npm ci) for the lint-based self-tests.

set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INIT="$PACK_DIR/scripts/setup/init.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cyan() { printf "\033[36m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*"; }

fail() { red "FAIL: $*"; exit 1; }

expected_stack() {
  case "$1" in
    todo-react-feature) printf 'react-vite-feature' ;;
    todo-react-fsd) printf 'react-vite-fsd' ;;
    todo-react-next) printf 'react-next-app' ;;
    *) printf '' ;;
  esac
}

# A throwaway copy so the reference example is never mutated. node_modules is
# linked, not copied: the self-tests shell out to the example's own eslint.
stage_example() { # $1 = example name -> prints the staged path
  local name="$1" src="$PACK_DIR/examples/$1" dst
  [ -d "$src" ] || fail "no such example: $src"
  [ -d "$src/node_modules" ] || fail "$src/node_modules missing — run npm ci in the example first."

  # A fresh directory per call: reusing one would let an earlier case's install
  # (and its deliberate drift) leak into the next.
  dst="$(mktemp -d "$WORK/$name.XXXXXX")"
  tar -C "$src" --exclude node_modules --exclude .next --exclude '*.tsbuildinfo' -cf - . | tar -C "$dst" -xf -
  ln -s "$src/node_modules" "$dst/node_modules"
  printf '%s' "$dst"
}

marker_count() {
  grep -c 'BEGIN COMPFORGE (generated' "$1/AGENTS.md" || true
}

smoke_one() {
  local name="$1" want target detected
  want="$(expected_stack "$name")"
  [ -n "$want" ] || fail "unknown example: $name"

  cyan "==> $name (expect $want)"
  target="$(stage_example "$name")"

  # 1. detection — the regression that motivated the Next stack.
  # Capture the full dry-run: `head` in a pipefail pipeline would SIGPIPE
  # init once it had one line, and abort the smoke.
  local dry_out
  dry_out="$("$INIT" --dry-run "$target" 2>&1)" \
    || fail "$name: dry-run failed"$'\n'"$dry_out"
  detected="$(printf '%s\n' "$dry_out" | sed -n 's/^.*detected stack: \([a-z-]*\).*$/\1/p')"
  detected="${detected%%$'\n'*}"
  [ "$detected" = "$want" ] || fail "$name detected as '$detected', expected '$want'"

  # 2. install + negative self-test.
  "$INIT" "$target" >"$WORK/$name.init.log" 2>&1 \
    || { cat "$WORK/$name.init.log"; fail "$name: init did not complete"; }
  grep -q 'self-test passed: AGENTS.md points at the pack' "$WORK/$name.init.log" \
    || fail "$name: pointer self-test did not run"
  [ -f "$target/AGENTS.md" ] || fail "$name: no AGENTS.md delivered"
  [ -f "$target/compforge-lock.json" ] || fail "$name: no compforge-lock.json delivered"
  grep -q "\"stack\": \"$want\"" "$target/compforge-lock.json" \
    || fail "$name: lock does not record stack $want"
  python3 - "$target/compforge-lock.json" <<'PY' \
    || fail "$name: lock advertises the unsupported standalone compforge CLI"
import json, sys
d = json.load(open(sys.argv[1]))
raise SystemExit("verifyCommand" in d)
PY
  if [ "$want" = "react-vite-fsd" ]; then
    [ -f "$target/eslint.compforge.config.js" ] \
      || fail "$name: FSD init did not deliver eslint.compforge.config.js"
    grep -q 'eslint.compforge.config.js' "$target/compforge-lock.json" \
      || fail "$name: FSD lock checkCommand does not run eslint"
  fi

  # 3. verify re-runs the self-test from the lock.
  "$INIT" --verify "$target" >"$WORK/$name.verify.log" 2>&1 \
    || { cat "$WORK/$name.verify.log"; fail "$name: --verify failed on a fresh install"; }

  # 4. idempotent re-run, and hand-written content survives.
  printf '# House rules\n\nKeep this line.\n' >"$target/AGENTS.md"
  "$INIT" "$target" >/dev/null 2>&1 || fail "$name: re-run failed"
  "$INIT" "$target" >/dev/null 2>&1 || fail "$name: second re-run failed"
  grep -q 'Keep this line.' "$target/AGENTS.md" || fail "$name: hand-written AGENTS.md content was lost"
  [ "$(marker_count "$target")" = "1" ] || fail "$name: pointer block duplicated on re-run"

  # 5. drift is refused rather than reported green.
  python3 - "$target/compforge-lock.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
d["stack"] = "react-vite-fsd" if d["stack"] != "react-vite-fsd" else "react-vite-feature"
json.dump(d, open(p, "w"), indent=2)
PY
  if "$INIT" --verify "$target" >/dev/null 2>&1; then
    fail "$name: --verify passed despite a stack/lock mismatch"
  fi

  green "ok: $name"
}

# 6. A pack whose Next template lost the server zones must be refused. This is
# the negative test on the negative test: without it a dropped boundary would
# still print "self-test passed".
smoke_broken_pack() {
  local broken="$WORK/broken-pack" target
  mkdir -p "$broken"
  tar -C "$PACK_DIR" --exclude examples --exclude .git --exclude node_modules -cf - . | tar -C "$broken" -xf -

  python3 - "$broken/templates/react-next-app/eslint.compforge.config.js" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
text = p.read_text(encoding="utf-8")
start = text.index("            {\n              target: './src/features',\n              from: './src/server',")
end = text.index("// BEGIN COMPFORGE GENERATED FEATURE ZONES")
p.write_text(text[:start] + "            " + text[end:], encoding="utf-8")
PY

  cyan "==> broken pack (server zones removed) must be refused"
  target="$(stage_example todo-react-next)"
  if "$broken/scripts/setup/init.sh" "$target" >"$WORK/broken.log" 2>&1; then
    cat "$WORK/broken.log"
    fail "init reported success with the src/server boundary removed"
  fi
  grep -q 'SELF-TEST FAILED' "$WORK/broken.log" \
    || { cat "$WORK/broken.log"; fail "init failed for some reason other than the self-test"; }
  green "ok: a dropped boundary is caught, not reported green"
}

# 7. strict: false must be refused. Init does not rewrite tsconfig.json.
smoke_strict_refused() {
  local target
  cyan "==> tsconfig strict: false must be refused"
  target="$(stage_example todo-react-feature)"
  python3 - "$target/tsconfig.json" <<'PY'
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text(encoding="utf-8"))
data["compilerOptions"]["strict"] = False
p.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
  if "$INIT" "$target" >"$WORK/strict.log" 2>&1; then
    cat "$WORK/strict.log"
    fail "init reported success with compilerOptions.strict set to false"
  fi
  grep -q 'REFUSED: TypeScript strict' "$WORK/strict.log" \
    || { cat "$WORK/strict.log"; fail "init failed for some reason other than strict: true"; }
  green "ok: a missing strict flag is caught, not reported green"
}

# 8. A pack whose FSD template lost no-explicit-any must be refused.
smoke_broken_fsd_any() {
  local broken="$WORK/broken-fsd-any" target
  mkdir -p "$broken"
  tar -C "$PACK_DIR" --exclude examples --exclude .git --exclude node_modules -cf - . | tar -C "$broken" -xf -

  python3 - "$broken/templates/react-vite-fsd/eslint.compforge.config.js" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
p.write_text(
    p.read_text(encoding="utf-8").replace("'@typescript-eslint/no-explicit-any': 'error'", ""),
    encoding="utf-8",
)
PY

  cyan "==> broken pack (FSD no-explicit-any removed) must be refused"
  target="$(stage_example todo-react-fsd)"
  if "$broken/scripts/setup/init.sh" "$target" >"$WORK/broken-fsd-any.log" 2>&1; then
    cat "$WORK/broken-fsd-any.log"
    fail "init reported success with no-explicit-any removed from the FSD template"
  fi
  grep -q 'SELF-TEST FAILED' "$WORK/broken-fsd-any.log" \
    || { cat "$WORK/broken-fsd-any.log"; fail "init failed for some reason other than the any self-test"; }
  green "ok: a dropped any rule is caught, not reported green"
}

examples=("$@")
if [ "${#examples[@]}" -eq 0 ]; then
  examples=(todo-react-feature todo-react-fsd todo-react-next)
fi

for example in "${examples[@]}"; do
  smoke_one "$example"
done

for example in "${examples[@]}"; do
  if [ "$example" = "todo-react-next" ]; then
    smoke_broken_pack
  fi
  if [ "$example" = "todo-react-fsd" ]; then
    smoke_broken_fsd_any
  fi
  if [ "$example" = "todo-react-feature" ]; then
    smoke_strict_refused
  fi
done

green "==> init smoke passed"
