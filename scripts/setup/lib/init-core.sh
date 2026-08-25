# Shared stack detection and generated-file helpers for compforge init.

pack_version() {
  python3 - "$PACK_DIR/.claude-plugin/plugin.json" <<'PY'
import json, sys
print(json.load(open(sys.argv[1])).get("version", "unknown"))
PY
}

pack_commit() {
  git -C "$PACK_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown'
}

have_dep() {
  python3 - "$TARGET/package.json" "$1" <<'PY'
import json, sys
pkg = json.load(open(sys.argv[1]))
deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}
sys.exit(0 if sys.argv[2] in deps else 1)
PY
}

detect_stack() {
  local fsd=0 feature=0

  if have_dep next || compgen -G "$TARGET/next.config.*" >/dev/null 2>&1; then
    printf 'react-next-app'
    return
  fi

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

resolve_stack() {
  if [ -n "$STACK" ]; then
    case "$STACK" in
      react-vite-feature|react-vite-fsd|react-next-app) return ;;
      *) red "unknown stack: $STACK"; exit 2 ;;
    esac
  fi

  STACK="$(detect_stack)"
  if [ -z "$STACK" ]; then
    red "cannot detect the stack from $TARGET (no next dependency, no features/, no FSD layers)."
    red "Pass --stack react-vite-feature | react-vite-fsd | react-next-app; do not guess."
    exit 2
  fi
  cyan "detected stack: $STACK"
}

write_file() {
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

generate_zones() {
  python3 - "$1" "$2" "$TARGET" "$DRY_RUN" <<'PY'
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
}

install_eslint_config_entry() {
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
  require_dep typescript-eslint
}

install_eslint_entry() {
  install_eslint_config_entry
  require_dep eslint-plugin-import
  CHECK_CMD="npx eslint --config eslint.compforge.config.js src"
}
