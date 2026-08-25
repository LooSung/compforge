# Stack-specific delivery and TypeScript gates for compforge init.

init_feature() {
  generate_zones "$TEMPLATES/react-vite-feature/eslint.compforge.config.js" "$TARGET/eslint.compforge.config.js"
  install_eslint_entry
}

init_next() {
  generate_zones "$TEMPLATES/react-next-app/eslint.compforge.config.js" "$TARGET/eslint.compforge.config.js"
  install_eslint_entry
}

init_fsd() {
  if [ -f "$TARGET/steiger.config.ts" ]; then
    yellow "steiger.config.ts already exists — not touched. Compare against:"
    yellow "  $TEMPLATES/react-vite-fsd/steiger.config.ts"
  else
    write_file "$TARGET/steiger.config.ts" <"$TEMPLATES/react-vite-fsd/steiger.config.ts"
  fi

  write_file "$TARGET/eslint.compforge.config.js" <"$TEMPLATES/react-vite-fsd/eslint.compforge.config.js"
  install_eslint_config_entry

  require_dep steiger
  require_dep '@feature-sliced/steiger-plugin'
  CHECK_CMD="npx eslint --config eslint.compforge.config.js src && npx steiger src"
}

run_stack_init() {
  case "$STACK" in
    react-vite-feature) init_feature ;;
    react-vite-fsd) init_fsd ;;
    react-next-app) init_next ;;
  esac
}

install_agents_pointer() {
  python3 - "$TEMPLATES/agents/compforge-block.md" "$TARGET/AGENTS.md" "$STACK" "$CHECK_CMD" "$DRY_RUN" \
    "$AGENTS_BEGIN" "$AGENTS_END" <<'PY'
import sys
from pathlib import Path

template, agents, stack, check, dry = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3], sys.argv[4], sys.argv[5] == "1"
BEGIN, END = sys.argv[6], sys.argv[7]

block = (
    template.read_text(encoding="utf-8")
    .replace("__COMPFORGE_STACK__", stack)
    .replace("__COMPFORGE_CHECK_CMD__", check)
    .strip()
)

if not block.startswith(BEGIN) or not block.endswith(END):
    sys.exit(f"marker mismatch between {template} and init.sh; refusing to write {agents}.")

if agents.exists():
    text = agents.read_text(encoding="utf-8")
    if BEGIN in text and END in text:
        head, rest = text.split(BEGIN, 1)
        _, tail = rest.split(END, 1)
        body = head + block + tail
        action = ("update the Compforge block in", "updated the Compforge block in")
    else:
        body = text.rstrip() + "\n\n" + block + "\n"
        action = ("append the Compforge block to", "appended the Compforge block to")
else:
    body = "# Agent Instructions\n\n" + block + "\n"
    action = ("create", "created")

if dry:
    print(f"dry-run: would {action[0]} {agents}")
else:
    agents.write_text(body, encoding="utf-8")
    print(f"{action[1]} {agents}")
PY
}

write_lock() {
  local version commit
  version="$(pack_version)"
  commit="$(pack_commit)"

  if [ "$DRY_RUN" = 1 ]; then
    yellow "dry-run: would write $TARGET/$LOCK_NAME (compforge $version, stack $STACK)"
    return
  fi

  python3 - "$TARGET/$LOCK_NAME" "$version" "$commit" "$STACK" "$CHECK_CMD" <<'PY'
import json, sys, datetime
from pathlib import Path

lock, version, commit, stack, check = Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
lock.write_text(json.dumps({
    "compforge": {
        "version": version,
        "commit": commit,
        "source": "https://github.com/LooSung/compforge",
    },
    "installedAt": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
    "stack": stack,
    "checkCommand": check,
}, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {lock}")
PY
}

install_workflow() {
  local wf="$TARGET/.github/workflows/compforge-check.yml"
  if [ -f "$wf" ]; then
    yellow "$wf already exists — not touched."
  else
    python3 - "$TEMPLATES/github/compforge-check.yml" "$wf" "$CHECK_CMD" "$DRY_RUN" <<'PY'
import sys
from pathlib import Path

src, dest, cmd, dry = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3], sys.argv[4] == "1"
text = src.read_text(encoding="utf-8").replace("__COMPFORGE_CHECK_CMD__", cmd)
if dry:
    print(f"dry-run: would write {dest}")
else:
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(text, encoding="utf-8")
    print(f"wrote {dest}")
PY
  fi
}

install_review_workflow() {
  local wf="$TARGET/.github/workflows/compforge-architecture-review.yml"
  if [ -f "$wf" ]; then
    yellow "$wf already exists — not touched."
  else
    write_file "$wf" <"$TEMPLATES/github/compforge-architecture-review.yml"
  fi
}

require_strict_tsconfig() {
  python3 - "$TARGET" <<'PY'
import json, re, sys
from pathlib import Path

root = Path(sys.argv[1])
tsconfig = root / "tsconfig.json"
if not tsconfig.is_file():
    sys.exit("REFUSED: no tsconfig.json. Compforge requires TypeScript with compilerOptions.strict set to true.")

text = tsconfig.read_text(encoding="utf-8")
refused = (
    "REFUSED: TypeScript strict: true is a Compforge Hard Rule. "
    "Set compilerOptions.strict to true in tsconfig.json "
    "(init does not rewrite it, and does not follow extends)."
)
try:
    data = json.loads(text)
except json.JSONDecodeError:
    if re.search(r'"strict"\s*:\s*true\b', text) is None:
        sys.exit(refused)
else:
    if (data.get("compilerOptions") or {}).get("strict") is not True:
        sys.exit(refused)
PY
}

hint_tsc_if_missing() {
  if python3 - "$TARGET/package.json" <<'PY'
import json, sys
scripts = json.load(open(sys.argv[1])).get("scripts") or {}
sys.exit(0 if any("tsc --noEmit" in str(value) for value in scripts.values()) else 1)
PY
  then
    return
  fi
  yellow "No tsc --noEmit script found. Compforge does not rewrite package.json. Add:"
  printf '\n  "typecheck": "tsc --noEmit"\n\n'
}
