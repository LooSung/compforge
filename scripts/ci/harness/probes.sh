# Shared activation assertions for harness smoke tests.

cleanup() {
  local path
  set +u
  for path in "${TEMP_DIRS[@]}"; do
    rm -rf "$path"
  done
  set -u
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    red "FAIL missing command: $1"
    exit 1
  }
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

assert_claude_candidate() {
  local output="$1"
  local expected_root="$2"
  assert_positive "$output" || return 1
  grep -Fxq "COMPFORGE_PLUGIN_ROOT=$expected_root" "$output" ||
    {
      probe_failure "Claude probe did not load the candidate plugin root" "$output"
      return 1
    }
  green "PASS Claude candidate plugin root"
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
