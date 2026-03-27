#!/bin/sh

fixture_populated_focus_monitor_first() {
  FIX_MONITORS_JSON='[{"monitor-id":1},{"monitor-id":2}]'
  FIX_WORKSPACES_JSON='[{"workspace":"1"},{"workspace":"2"},{"workspace":"3"}]'
  FIX_FOCUSED_WORKSPACE='3'
  FIX_WINDOWS_ROWS="$(
    printf '101%s1%s1\n' "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM"
    printf '201%s3%s2\n' "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM"
    printf '202%s3%s2\n' "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM"
  )"
}

fixture_focused_workspace_synthetic() {
  FIX_MONITORS_JSON='[{"monitor-id":1},{"monitor-id":2}]'
  FIX_WORKSPACES_JSON='[{"workspace":"1"},{"workspace":"2"},{"workspace":"4"}]'
  FIX_FOCUSED_WORKSPACE='4'
  FIX_WINDOWS_ROWS="$(
    printf '101%s1%s1\n' "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM"
  )"
}

fixture_malformed_windows_rows_filtered() {
  FIX_MONITORS_JSON='[{"monitor-id":1},{"monitor-id":2}]'
  FIX_WORKSPACES_JSON='[{"workspace":"1"},{"workspace":"2"},{"workspace":"3"}]'
  FIX_FOCUSED_WORKSPACE='1'
  FIX_WINDOWS_ROWS="$(
    printf '101%s1%s1\n' "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM"
    printf 'malformed-without-delimiters\n'
    printf '102%s2\n' "$WINDOWS_ROW_DELIM"
    printf '103%s2%s2%sextra\n' "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM"
    printf 'abc%s2%s2\n' "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM"
    printf '104%s3%snot-a-monitor\n' "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM"
    printf '105%s%s2\n' "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM"
    printf '106%s2%s2\n' "$WINDOWS_ROW_DELIM" "$WINDOWS_ROW_DELIM"
  )"
}
