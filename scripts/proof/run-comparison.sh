#!/usr/bin/env bash
#
# Run the reproducible control-versus-Compforge comparison.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
STARTER="${PROOF_STARTER:-examples/todo-react-feature}"
STARTER_DEPTH="$(printf '%s' "$STARTER" | awk -F/ '{print NF}')"
MODEL="${PROOF_MODEL:-}"
RUN_ID="${PROOF_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
OUTPUT_BASE="${PROOF_OUTPUT_BASE:-${TMPDIR:-/tmp}/compforge-proof-runs}"
OUTPUT_BASE="$(python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$OUTPUT_BASE")"
OUTPUT_ROOT="$OUTPUT_BASE/$RUN_ID"
SKIP_CHECK="${PROOF_SKIP_CHECK:-0}"

TASK='Add search to the todo list. Match on the title, case-insensitive, and combine with the existing status filter. Keep the query in the URL so a filtered view survives reload and can be shared. Show how many todos match, and show a distinct empty state when the query matches nothing. Add a "complete all matches" action that marks every currently matching todo completed; a todo that is already completed must stay completed. The search input needs an accessible label, and the match count must be announced to assistive technology. Add tests for the matching logic and for the new behavior. Do not change unrelated behavior.'

if [ -z "$MODEL" ]; then
  printf 'PROOF_MODEL is required so both runs use an explicit model.\n' >&2
  exit 2
fi

if [ "$MODEL" = "auto" ]; then
  printf 'PROOF_MODEL=auto is invalid: both runs must pin one model ID.\n' >&2
  exit 2
fi

case "$OUTPUT_BASE/" in
  "$PACK_DIR/"*)
    printf 'Proof workspaces must be outside the Compforge repository.\n' >&2
    printf 'Choose an external PROOF_OUTPUT_BASE (default: system temp).\n' >&2
    exit 2
    ;;
esac

if ! git -C "$PACK_DIR" cat-file -e "HEAD:$STARTER" 2>/dev/null; then
  printf 'PROOF_STARTER "%s" is not committed at HEAD.\n' "$STARTER" >&2
  printf 'The starter is archived from the recorded commit, so it must be tracked.\n' >&2
  exit 2
fi

if ! command -v cursor-agent >/dev/null 2>&1; then
  printf 'cursor-agent is required.\n' >&2
  exit 2
fi

if ! cursor-agent status >/dev/null 2>&1; then
  printf 'Cursor Agent is not authenticated. Run: cursor-agent login\n' >&2
  exit 2
fi

if [ "$SKIP_CHECK" != "1" ] && ! command -v npm >/dev/null 2>&1; then
  printf 'npm is required, or set PROOF_SKIP_CHECK=1.\n' >&2
  exit 2
fi

# The starter teaches Compforge in its prose: skill paths, ladder rungs, and the
# name itself. Left in place, the control reads the methodology off the source
# and the comparison measures nothing. Both arms get the same scrubbed tree.
neutralize_starter() {
  local workspace="$1"

  python3 - "$workspace" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
term = re.compile(r"skills/|ladder|rung|compforge", re.IGNORECASE)

(root / "README.md").unlink(missing_ok=True)

for path in sorted(root.rglob("*")):
    if not path.is_file() or path.suffix not in {".ts", ".tsx", ".js", ".mjs", ".cjs"}:
        continue
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    kept = [
        line
        for line in lines
        if not (line.lstrip().startswith("//") and term.search(line))
    ]
    if len(kept) != len(lines):
        path.write_text("".join(kept), encoding="utf-8")

index = root / "index.html"
if index.exists():
    index.write_text(
        re.sub(r"<title>.*?</title>", "<title>Todos</title>", index.read_text(encoding="utf-8")),
        encoding="utf-8",
    )
PY

  if grep -rilE 'compforge|ladder|[^a-z]rung|skills/' "$workspace" >/dev/null 2>&1; then
    printf 'INVALID: starter still references Compforge methodology after scrubbing.\n' >&2
    grep -rinE 'compforge|ladder|[^a-z]rung|skills/' "$workspace" >&2
    exit 3
  fi
}

prepare_workspace() {
  local name="$1"
  local workspace="$OUTPUT_ROOT/$name/workspace"

  mkdir -p "$workspace"
  # Archive from the recorded commit, not the working tree: the starter must
  # match the source commit in metadata, and node_modules must stay out.
  git -C "$PACK_DIR" archive HEAD "$STARTER" \
    | tar -x -C "$workspace" --strip-components="$STARTER_DEPTH"
  neutralize_starter "$workspace"

  printf 'node_modules/\ndist/\n' >"$workspace/.gitignore"
  if [ "$name" = "treatment" ]; then
    mkdir -p "$workspace/.cursor/skills"
    cp -R "$PACK_DIR/skills" "$workspace/.cursor/skills/compforge"
  fi

  git -C "$workspace" init -q
  git -C "$workspace" add .
  git -C "$workspace" \
    -c user.name=Compforge \
    -c user.email=proof@compforge.local \
    commit -q -m "Proof baseline"
}

run_agent() {
  local name="$1"
  local prompt="$2"
  shift 2
  local workspace="$OUTPUT_ROOT/$name/workspace"

  cursor-agent \
    --print \
    --trust \
    --force \
    --sandbox enabled \
    --model "$MODEL" \
    --workspace "$workspace" \
    "$@" \
    "$prompt" \
    >"$OUTPUT_ROOT/$name/agent-output.txt" 2>&1

  git -C "$workspace" add -N . >/dev/null
  git -C "$workspace" diff --stat >"$OUTPUT_ROOT/$name/diff-stat.txt"
  git -C "$workspace" diff --no-ext-diff >"$OUTPUT_ROOT/$name/changes.patch"
}

run_checks() {
  local name="$1"
  local workspace="$OUTPUT_ROOT/$name/workspace"
  local result=0

  if [ "$SKIP_CHECK" = "1" ]; then
    printf 'skipped\n' >"$OUTPUT_ROOT/$name/check-output.txt"
    printf 'skipped\n' >"$OUTPUT_ROOT/$name/check-exit-code.txt"
    return
  fi

  (
    cd "$workspace"
    npm ci
    npm run check
  ) >"$OUTPUT_ROOT/$name/check-output.txt" 2>&1 || result=$?

  printf '%s\n' "$result" >"$OUTPUT_ROOT/$name/check-exit-code.txt"
}

evaluate() {
  local name="$1"
  local workspace="$OUTPUT_ROOT/$name/workspace"
  local result=0

  python3 "$SCRIPT_DIR/evaluate-run.py" "$workspace" \
    >"$OUTPUT_ROOT/$name/evaluation.json" || result=$?
  printf '%s\n' "$result" >"$OUTPUT_ROOT/$name/evaluation-exit-code.txt"
}

validate_control() {
  if [ -d "$OUTPUT_ROOT/control/workspace/.craft" ]; then
    printf 'INVALID: control created .craft; Compforge instructions contaminated it.\n' >&2
    printf 'Disable user-level Compforge skills or use a clean OS profile, then retry.\n' >&2
    exit 3
  fi
}

validate_treatment() {
  if [ ! -d "$OUTPUT_ROOT/treatment/workspace/.craft" ]; then
    printf 'INVALID: treatment did not create .craft; skill load is unproven.\n' >&2
    exit 3
  fi
}

write_metadata() {
  {
    printf 'run_id=%s\n' "$RUN_ID"
    printf 'model=%s\n' "$MODEL"
    printf 'cursor_agent_version=%s\n' "$(cursor-agent --version)"
    printf 'source_commit=%s\n' "$(git -C "$PACK_DIR" rev-parse HEAD)"
    printf 'starter=%s\n' "$STARTER"
    printf 'starter_neutralized=README.md removed; methodology comments and page title scrubbed\n'
    printf 'treatment_delivery=project-local .cursor/skills/compforge\n'
    printf 'checks_run=%s\n' "$([ "$SKIP_CHECK" = "1" ] && printf skipped || printf 'npm ci && npm run check')"
    printf 'task=%s\n' "$TASK"
  } >"$OUTPUT_ROOT/metadata.txt"
}

mkdir -p "$OUTPUT_ROOT"
write_metadata
prepare_workspace control
prepare_workspace treatment

run_agent control "$TASK"
validate_control
run_agent treatment \
  "Use the project-local Compforge Craft skill for this request. Follow its Assumptions, Component Contract, continuity, and verification gates. $TASK"
validate_treatment

run_checks control
run_checks treatment
evaluate control
evaluate treatment

printf 'Proof artifacts: %s\n' "$OUTPUT_ROOT"
printf 'Inspect both evaluation.json and check-output.txt files before publishing.\n'
