#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
PLUGIN_FILE="$ROOT_DIR/plugins/aerospace.sh"
FIXTURES_FILE="$ROOT_DIR/tests/aerospace/parser_fixtures.sh"

WINDOWS_ROW_DELIM="$(printf '\037')"

assert_eq() {
  expected="$1"
  actual="$2"
  message="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'FAIL: %s\n' "$message"
    printf '  expected: %s\n' "$expected"
    printf '  actual:   %s\n' "$actual"
    exit 1
  fi
}

assert_file_unchanged() {
  expected_file="$1"
  actual_file="$2"
  message="$3"

  if ! cmp -s "$expected_file" "$actual_file"; then
    printf 'FAIL: %s\n' "$message"
    printf '  expected file: %s\n' "$expected_file"
    printf '  actual file:   %s\n' "$actual_file"
    exit 1
  fi
}

build_model_json() {
  MONITORS_JSON="$1" \
  WORKSPACES_JSON="$2" \
  FOCUSED_WORKSPACE="$3" \
  WINDOWS_ROWS_RAW="$4" \
  WINDOWS_ROW_DELIM="$WINDOWS_ROW_DELIM" \
  AEROSPACE_SOURCE_ONLY=1 \
  sh "$PLUGIN_FILE" --build-model
}

model_value() {
  key="$1"
  python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get(sys.argv[1], ""))' "$key"
}

model_groups_line() {
  python3 -c 'import json,sys; d=json.load(sys.stdin); groups=d.get("groups", {}); order=d.get("monitor_order", []); print("|".join(f"{mid}:{",".join(groups.get(mid, []))}" for mid in order))'
}

model_monitor_order_csv() {
  python3 -c 'import json,sys; d=json.load(sys.stdin); print(",".join(d.get("monitor_order", [])))'
}

test_populated_grouping_and_monitor_order() {
  fixture_populated_focus_monitor_first

  model="$(build_model_json "$FIX_MONITORS_JSON" "$FIX_WORKSPACES_JSON" "$FIX_FOCUSED_WORKSPACE" "$FIX_WINDOWS_ROWS")"

  groups_line="$(printf '%s' "$model" | model_groups_line)"
  order_csv="$(printf '%s' "$model" | model_monitor_order_csv)"

  assert_eq '1:1|2:3' "$groups_line" 'only populated workspaces grouped by monitor in monitor-id order'
  assert_eq '1,2' "$order_csv" 'monitor order is stable M1,M2,...'
}

test_focused_workspace_synthetic_when_empty() {
  fixture_focused_workspace_synthetic

  model="$(build_model_json "$FIX_MONITORS_JSON" "$FIX_WORKSPACES_JSON" "$FIX_FOCUSED_WORKSPACE" "$FIX_WINDOWS_ROWS")"

  groups_line="$(printf '%s' "$model" | model_groups_line)"
  assert_eq '1:1,4' "$groups_line" 'focused workspace is synthesized when empty'
}

test_escape_single_quotes_helper() {
  escaped="$(AEROSPACE_SOURCE_ONLY=1 sh "$PLUGIN_FILE" --escape-single-quotes "o'reilly's")"
  assert_eq "o'\\''reilly'\\''s" "$escaped" 'single-quote escaping helper output is correct'
}

test_malformed_windows_rows_are_dropped() {
  fixture_malformed_windows_rows_filtered

  model="$(build_model_json "$FIX_MONITORS_JSON" "$FIX_WORKSPACES_JSON" "$FIX_FOCUSED_WORKSPACE" "$FIX_WINDOWS_ROWS")"

  groups_line="$(printf '%s' "$model" | model_groups_line)"
  order_csv="$(printf '%s' "$model" | model_monitor_order_csv)"

  assert_eq '1:1|2:2' "$groups_line" 'malformed rows are dropped and valid rows remain'
  assert_eq '1,2' "$order_csv" 'monitor order remains stable after malformed row filtering'
}

test_forced_degraded_keeps_prior_state() {
  tmp_dir="$(mktemp -d /tmp/sketchybar-aerospace-test.XXXXXX)"
  bin_dir="$tmp_dir/bin"
  mkdir -p "$bin_dir"

  state_file="$tmp_dir/state.txt"
  baseline_file="$tmp_dir/state-baseline.txt"
  log_file="$tmp_dir/log.txt"
  last_ts_file="$tmp_dir/last.ts"
  lock_dir="$tmp_dir/refresh.lock"

  printf 'aerospace.mon.1\naerospace.ws.31\n' > "$state_file"
  cp "$state_file" "$baseline_file"

  cat > "$bin_dir/sketchybar" <<'EOF'
#!/bin/sh
exit 0
EOF
  chmod +x "$bin_dir/sketchybar"

  PATH="$bin_dir:$PATH" \
  FORCE_DEGRADED=1 \
  LOG_FILE="$log_file" \
  STATE_FILE="$state_file" \
  LAST_TS_FILE="$last_ts_file" \
  LOCK_DIR="$lock_dir" \
  sh "$PLUGIN_FILE" --refresh

  assert_file_unchanged "$baseline_file" "$state_file" 'forced degraded refresh preserves prior state file'
  rm -rf "$tmp_dir"
}

. "$FIXTURES_FILE"

test_populated_grouping_and_monitor_order
test_focused_workspace_synthetic_when_empty
test_escape_single_quotes_helper
test_malformed_windows_rows_are_dropped
test_forced_degraded_keeps_prior_state

printf 'ok - parser tests passed\n'
