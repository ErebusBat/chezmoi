#!/bin/sh
set -eu

LOG_FILE="${LOG_FILE:-/tmp/sketchybar-aerospace.log}"
STATE_FILE="${STATE_FILE:-/tmp/sketchybar-aerospace-items.state}"
LAST_TS_FILE="${LAST_TS_FILE:-/tmp/sketchybar-aerospace-last-refresh.ts}"
REFRESH_LOCK_DIR="${LOCK_DIR:-/tmp/sketchybar-aerospace-refresh.lock}"
DEBOUNCE_MS=60
WINDOWS_ROW_DELIM="$(printf '\037')"
REFRESH_LOCK_TOKEN=""
REFRESH_TMP_FILES=""
CMD_TIMEOUT_SECS="${AEROSPACE_CMD_TIMEOUT_SECS:-2}"
LAST_FULL_TS_FILE="/tmp/sketchybar-aerospace-last-full-refresh.ts"
FOCUSED_WS_FILE="/tmp/sketchybar-aerospace-focused-workspace"
FULL_REFRESH_INTERVAL_MS=3000

LOCK_STALE_CHECK_SCRIPT_NAME="aerospace.sh"

now_ms() {
  python3 -c 'import time; print(int(time.time() * 1000))'
}

log() {
  [ "${AEROSPACE_WS_DEBUG:-0}" = "1" ] || return 0
  level="$1"
  shift
  msg="$*"

  if [ -f "$LOG_FILE" ] && [ "$(wc -c < "$LOG_FILE")" -gt 262144 ]; then
    : > "$LOG_FILE"
  fi

  printf '%s [%s] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$level" "$msg" >> "$LOG_FILE"
}

register_tmp_file() {
  tmp_file="$1"
  REFRESH_TMP_FILES="${REFRESH_TMP_FILES}${tmp_file}
"
}

make_temp_file() {
  pattern="$1"
  tmp_file="$(mktemp "$pattern")" || return 1
  register_tmp_file "$tmp_file"
  printf '%s\n' "$tmp_file"
}

run_cmd() {
  out_file="$(mktemp /tmp/sketchybar-aerospace-cmd-out.XXXXXX)"
  err_file="$(mktemp /tmp/sketchybar-aerospace-cmd-err.XXXXXX)"

  timeout_secs="$CMD_TIMEOUT_SECS"
  case "$timeout_secs" in
    ''|*[!0-9.]*) timeout_secs='2' ;;
  esac
  if [ "$timeout_secs" = '0' ] || [ "$timeout_secs" = '0.0' ]; then
    timeout_secs='2'
  fi

  if python3 - "$out_file" "$err_file" "$timeout_secs" "$@" <<'PY'
import subprocess
import sys

out_path = sys.argv[1]
err_path = sys.argv[2]
timeout_secs = float(sys.argv[3])
command = sys.argv[4:]

try:
    with open(out_path, "wb") as out_f, open(err_path, "wb") as err_f:
        completed = subprocess.run(command, stdout=out_f, stderr=err_f, timeout=timeout_secs, check=False)
    raise SystemExit(completed.returncode)
except subprocess.TimeoutExpired:
    with open(err_path, "ab") as err_f:
        err_f.write(f"command timed out after {timeout_secs}s\n".encode("utf-8"))
    raise SystemExit(124)
except Exception as exc:  # pragma: no cover
    with open(err_path, "ab") as err_f:
        err_f.write(f"command launch failed: {exc}\n".encode("utf-8"))
    raise SystemExit(125)
PY
  then
    cat "$out_file"
    rm -f "$out_file" "$err_file"
    return 0
  fi

  status="$?"
  stderr_line="$(tr '\n\r' '  ' < "$err_file")"
  if [ "$status" -eq 124 ]; then
    log WARN "command timed out timeout=${timeout_secs}s cmd=[$*] stderr=[$stderr_line]"
  fi
  log ERROR "command failed exit=$status cmd=[$*] stderr=[$stderr_line]"
  rm -f "$out_file" "$err_file"
  return "$status"
}

workspace_item_id() {
  printf '%s' "$1" | python3 -c 'import binascii,sys; d=sys.stdin.buffer.read(); print(binascii.hexlify(d).decode() or "00")'
}

escape_single_quotes() {
  printf '%s' "$1" | python3 -c "import sys; s=sys.stdin.read(); sys.stdout.write(s.replace(\"'\", \"'\\\\''\"))"
}

normalize_windows_rows_file() {
  input_file="$1"
  output_file="$2"

  : > "$output_file"

  while IFS= read -r row || [ -n "$row" ]; do
    [ -z "$row" ] && continue

    win_id="${row%%"$WINDOWS_ROW_DELIM"*}"
    if [ "$row" = "$win_id" ]; then
      log WARN "dropping malformed windows row (missing first delimiter): $row"
      continue
    fi

    rest="${row#*"$WINDOWS_ROW_DELIM"}"
    ws_name="${rest%%"$WINDOWS_ROW_DELIM"*}"
    if [ "$rest" = "$ws_name" ]; then
      log WARN "dropping malformed windows row (missing second delimiter): $row"
      continue
    fi

    mon_id="${rest#*"$WINDOWS_ROW_DELIM"}"
    if [ "${mon_id#*"$WINDOWS_ROW_DELIM"}" != "$mon_id" ]; then
      log WARN "dropping malformed windows row (too many delimiters): $row"
      continue
    fi

    if [ -z "$win_id" ] || [ -z "$ws_name" ] || [ -z "$mon_id" ]; then
      log WARN "dropping malformed windows row (empty field): $row"
      continue
    fi

    case "$win_id" in
      ''|*[!0-9]*)
        log WARN "dropping malformed windows row (window-id): $row"
        continue
        ;;
    esac

    case "$mon_id" in
      ''|*[!0-9]*)
        log WARN "dropping malformed windows row (monitor-id): $row"
        continue
        ;;
    esac

    printf '%s%s%s%s%s\n' "$win_id" "$WINDOWS_ROW_DELIM" "$ws_name" "$WINDOWS_ROW_DELIM" "$mon_id" >> "$output_file"
  done < "$input_file"
}

build_workspace_model() {
  monitors_json="$1"
  workspaces_json="$2"
  focused_workspace="$3"
  clean_rows_file="$4"

  MONITORS_JSON="$monitors_json" \
  WORKSPACES_JSON="$workspaces_json" \
  FOCUSED_WORKSPACE="$focused_workspace" \
  WINDOWS_ROW_DELIM="$WINDOWS_ROW_DELIM" \
  CLEAN_ROWS_FILE="$clean_rows_file" \
  python3 - <<'PY'
import json
import os

monitors = json.loads(os.environ.get("MONITORS_JSON", "[]"))
workspaces = json.loads(os.environ.get("WORKSPACES_JSON", "[]"))
focused_workspace = os.environ.get("FOCUSED_WORKSPACE", "")
rows_path = os.environ.get("CLEAN_ROWS_FILE", "")
row_delim = os.environ.get("WINDOWS_ROW_DELIM", "")

monitor_order_seed = []
for m in monitors:
    mid = str(m.get("monitor-id", ""))
    if mid and mid not in monitor_order_seed:
        monitor_order_seed.append(mid)

workspace_order = []
for w in workspaces:
    name = str(w.get("workspace", ""))
    if name and name not in workspace_order:
        workspace_order.append(name)

workspace_monitor = {}
workspace_counts = {}
if rows_path:
    with open(rows_path, "r", encoding="utf-8") as f:
        for raw in f:
            line = raw.rstrip("\n")
            if not line:
                continue
            parts = line.split(row_delim)
            if len(parts) != 3:
                continue
            _wid, ws, mid = parts
            workspace_counts[ws] = workspace_counts.get(ws, 0) + 1
            if ws not in workspace_monitor:
                workspace_monitor[ws] = mid

populated_workspaces = set(workspace_counts.keys())
has_populated = bool(populated_workspaces)

focused_monitor = ""
if focused_workspace and focused_workspace in workspace_monitor:
    focused_monitor = workspace_monitor[focused_workspace]
elif monitor_order_seed:
    focused_monitor = monitor_order_seed[0]

group_items = []
for ws in workspace_order:
    if ws in populated_workspaces:
        mid = workspace_monitor.get(ws, focused_monitor)
        if mid:
            group_items.append((mid, ws))

if focused_workspace and focused_workspace not in populated_workspaces and focused_monitor:
    already = False
    for _mid, ws in group_items:
        if ws == focused_workspace:
            already = True
            break
    if not already:
        group_items.append((focused_monitor, focused_workspace))

groups = {}
monitor_seen = []
for mid, ws in group_items:
    groups.setdefault(mid, []).append(ws)
    if mid not in monitor_seen:
        monitor_seen.append(mid)

monitor_order = []
for mid in monitor_order_seed:
    if mid in groups and mid not in monitor_order:
        monitor_order.append(mid)
for mid in monitor_seen:
    if mid in groups and mid not in monitor_order:
        monitor_order.append(mid)

result = {
    "focused_workspace": focused_workspace,
    "focused_monitor": focused_monitor,
    "has_populated": has_populated,
    "monitor_order": monitor_order,
    "groups": groups,
}

print(json.dumps(result))
PY
}

build_workspace_model_from_rows() {
  monitors_json="$1"
  workspaces_json="$2"
  focused_workspace="$3"
  windows_rows_raw="$4"

  raw_rows_file="$(make_temp_file /tmp/sketchybar-aerospace-rows-raw.XXXXXX)"
  clean_rows_file="$(make_temp_file /tmp/sketchybar-aerospace-rows-clean.XXXXXX)"

  printf '%s\n' "$windows_rows_raw" > "$raw_rows_file"
  normalize_windows_rows_file "$raw_rows_file" "$clean_rows_file"
  build_workspace_model "$monitors_json" "$workspaces_json" "$focused_workspace" "$clean_rows_file"
}

should_debounce() {
  now="$(now_ms)"
  last="0"

  if [ -f "$LAST_TS_FILE" ]; then
    last="$(cat "$LAST_TS_FILE" 2>/dev/null || printf '0')"
    case "$last" in
      ''|*[!0-9]*) last="0" ;;
    esac
  fi

  delta=$((now - last))

  if [ "$delta" -lt "$DEBOUNCE_MS" ]; then
    log INFO "debounce skip delta_ms=$delta"
    return 0
  fi

  printf '%s' "$now" > "$LAST_TS_FILE"

  return 1
}

acquire_refresh_lock() {
  token_source=""
  if command -v uuidgen >/dev/null 2>&1; then
    token_source="$(uuidgen 2>/dev/null || printf '')"
  fi
  if [ -z "$token_source" ]; then
    token_source="$(date '+%s')-$$"
  fi
  lock_token="${token_source}-$$"

  if mkdir "$REFRESH_LOCK_DIR" 2>/dev/null; then
    printf '%s\n' "$$" > "$REFRESH_LOCK_DIR/pid"
    printf '%s\n' "$lock_token" > "$REFRESH_LOCK_DIR/token"
    REFRESH_LOCK_TOKEN="$lock_token"
    return 0
  fi

  lock_pid=""
  existing_token=""
  if [ -f "$REFRESH_LOCK_DIR/pid" ]; then
    lock_pid="$(cat "$REFRESH_LOCK_DIR/pid" 2>/dev/null || printf '')"
  fi
  if [ -f "$REFRESH_LOCK_DIR/token" ]; then
    existing_token="$(cat "$REFRESH_LOCK_DIR/token" 2>/dev/null || printf '')"
  fi

  case "$lock_pid" in
    ''|*[!0-9]*)
      rm -f "$REFRESH_LOCK_DIR/pid" 2>/dev/null || true
      rm -f "$REFRESH_LOCK_DIR/token" 2>/dev/null || true
      rmdir "$REFRESH_LOCK_DIR" 2>/dev/null || true
      ;;
    *)
      if [ -z "$existing_token" ]; then
        rm -f "$REFRESH_LOCK_DIR/pid" 2>/dev/null || true
        rm -f "$REFRESH_LOCK_DIR/token" 2>/dev/null || true
        rmdir "$REFRESH_LOCK_DIR" 2>/dev/null || true
      elif ! kill -0 "$lock_pid" 2>/dev/null; then
        rm -f "$REFRESH_LOCK_DIR/pid" 2>/dev/null || true
        rm -f "$REFRESH_LOCK_DIR/token" 2>/dev/null || true
        rmdir "$REFRESH_LOCK_DIR" 2>/dev/null || true
      elif ! ps -p "$lock_pid" -o command= 2>/dev/null | grep -F -- "$LOCK_STALE_CHECK_SCRIPT_NAME" >/dev/null 2>&1; then
        log WARN "stale lock suspected pid=$lock_pid token=$existing_token; reclaiming"
        rm -f "$REFRESH_LOCK_DIR/pid" 2>/dev/null || true
        rm -f "$REFRESH_LOCK_DIR/token" 2>/dev/null || true
        rmdir "$REFRESH_LOCK_DIR" 2>/dev/null || true
      else
        log INFO "refresh skip lock-held pid=$lock_pid token=$existing_token"
        return 1
      fi
      ;;
  esac

  if mkdir "$REFRESH_LOCK_DIR" 2>/dev/null; then
    printf '%s\n' "$$" > "$REFRESH_LOCK_DIR/pid"
    printf '%s\n' "$lock_token" > "$REFRESH_LOCK_DIR/token"
    REFRESH_LOCK_TOKEN="$lock_token"
    return 0
  fi

  log INFO "refresh skip lock-contention"
  return 1
}

release_refresh_lock() {
  if [ -n "$REFRESH_LOCK_TOKEN" ] && [ -f "$REFRESH_LOCK_DIR/token" ]; then
    current_token="$(cat "$REFRESH_LOCK_DIR/token" 2>/dev/null || printf '')"
    if [ "$current_token" != "$REFRESH_LOCK_TOKEN" ]; then
      log WARN "skip lock release due to token mismatch expected=$REFRESH_LOCK_TOKEN got=$current_token"
      return 0
    fi
  fi

  rm -f "$REFRESH_LOCK_DIR/pid" 2>/dev/null || true
  rm -f "$REFRESH_LOCK_DIR/token" 2>/dev/null || true
  rmdir "$REFRESH_LOCK_DIR" 2>/dev/null || true
  REFRESH_LOCK_TOKEN=""
}

cleanup_temp_files() {
  [ -n "$REFRESH_TMP_FILES" ] || return 0

  printf '%s' "$REFRESH_TMP_FILES" | while IFS= read -r tmp_file || [ -n "$tmp_file" ]; do
    [ -n "$tmp_file" ] || continue
    rm -f "$tmp_file" 2>/dev/null || true
  done

  REFRESH_TMP_FILES=""
}

refresh_cleanup() {
  cleanup_temp_files
  release_refresh_lock
  trap - EXIT INT TERM HUP
}

check_dependencies() {
  missing=""

  for dep in python3 aerospace sketchybar; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing="$missing $dep"
    fi
  done

  if [ -z "$missing" ]; then
    return 0
  fi

  missing="${missing# }"

  case "$missing" in
    *sketchybar*)
      log ERROR "missing required dependency: $missing"
      return 1
      ;;
    *)
      log WARN "missing dependency; degraded mode: $missing"
      apply_degraded
      return 2
      ;;
  esac
}

apply_degraded() {
  log WARN "entering degraded mode"
  if ! command -v sketchybar >/dev/null 2>&1; then
    log ERROR "cannot enter degraded mode: sketchybar not found"
    return 1
  fi
  sketchybar --set aerospace.root label.drawing=on label="WS: unavailable"
}

item_exists() {
  sketchybar --query "$1" >/dev/null 2>&1
}

set_workspace_style() {
  ws_name="$1"
  focused_flag="$2"
  ws_encoded="$(workspace_item_id "$ws_name")"
  ws_item="aerospace.ws.$ws_encoded"

  if ! item_exists "$ws_item"; then
    return 0
  fi

  ws_label="$ws_name"
  ws_bg_draw="off"
  ws_label_color="0xffcdd6f4"
  ws_bg_color="0x00000000"

  if [ "$focused_flag" = "1" ]; then
    ws_label=">$ws_name<"
    ws_bg_draw="on"
    ws_label_color="0xff11111b"
    ws_bg_color="0xff89b4fa"
  fi

  sketchybar --set "$ws_item" \
    label="$ws_label" \
    label.color="$ws_label_color" \
    background.drawing="$ws_bg_draw" \
    background.color="$ws_bg_color"
}

quick_refresh_focus_only() {
  focused_workspace="$1"
  prev_workspace=""

  if [ -f "$FOCUSED_WS_FILE" ]; then
    prev_workspace="$(cat "$FOCUSED_WS_FILE" 2>/dev/null || printf '')"
  fi

  if [ -n "$prev_workspace" ] && [ "$prev_workspace" != "$focused_workspace" ]; then
    set_workspace_style "$prev_workspace" 0
  fi

  if [ -n "$focused_workspace" ]; then
    set_workspace_style "$focused_workspace" 1
  fi

  printf '%s' "$focused_workspace" > "$FOCUSED_WS_FILE"
  printf '%s' "$(now_ms)" > "$LAST_TS_FILE"
}

refresh() {
  REFRESH_TMP_FILES=""

  if [ "${FORCE_DEGRADED:-0}" = "1" ] || [ "${AEROSPACE_FORCE_DEGRADED:-0}" = "1" ]; then
    log WARN "forcing degraded mode via env"
    apply_degraded
    return 0
  fi

  trap 'cleanup_temp_files; trap - EXIT INT TERM HUP' EXIT INT TERM HUP

  dep_status=0
  check_dependencies || dep_status="$?"
  if [ "$dep_status" -ne 0 ]; then
    case "$dep_status" in
      1) return 1 ;;
      2) return 0 ;;
      *) return 0 ;;
    esac
  fi

  if should_debounce; then
    return 0
  fi

  focused_workspace_fast="$(run_cmd aerospace list-workspaces --focused --format '%{workspace}' 2>/dev/null || printf '')"
  now_fast="$(now_ms)"
  last_full="0"
  if [ -f "$LAST_FULL_TS_FILE" ]; then
    last_full="$(cat "$LAST_FULL_TS_FILE" 2>/dev/null || printf '0')"
    case "$last_full" in
      ''|*[!0-9]*) last_full="0" ;;
    esac
  fi

  if [ -n "$focused_workspace_fast" ] && [ $((now_fast - last_full)) -lt "$FULL_REFRESH_INTERVAL_MS" ]; then
    quick_refresh_focus_only "$focused_workspace_fast"
    return 0
  fi

  monitors_json="$(run_cmd aerospace list-monitors --json)" || {
    apply_degraded
    return 0
  }
  workspaces_json="$(run_cmd aerospace list-workspaces --all --json)" || {
    apply_degraded
    return 0
  }
  focused_workspace_json="$(run_cmd aerospace list-workspaces --focused --json)" || {
    apply_degraded
    return 0
  }
  windows_rows_format="%{window-id}${WINDOWS_ROW_DELIM}%{workspace}${WINDOWS_ROW_DELIM}%{monitor-id}"
  windows_rows_raw="$(run_cmd aerospace list-windows --all --format "$windows_rows_format")" || {
    apply_degraded
    return 0
  }

  if ! focused_workspace="$(printf '%s' "$focused_workspace_json" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d[0].get("workspace", "") if d else "")')"; then
    log WARN "failed to parse focused workspace json; degraded fallback"
    apply_degraded
    return 0
  fi

  model_file="$(make_temp_file /tmp/sketchybar-aerospace-model.XXXXXX)"
  monitor_order_file="$(make_temp_file /tmp/sketchybar-aerospace-monitor-order.XXXXXX)"
  new_items_file="$(make_temp_file /tmp/sketchybar-aerospace-new-items.XXXXXX)"
  old_items_file="$(make_temp_file /tmp/sketchybar-aerospace-old-items.XXXXXX)"

  if ! build_workspace_model_from_rows "$monitors_json" "$workspaces_json" "$focused_workspace" "$windows_rows_raw" > "$model_file"
  then
    log WARN "failed to build workspace model; degraded fallback"
    apply_degraded
    return 0
  fi

if [ -f "$STATE_FILE" ]; then
    cp "$STATE_FILE" "$old_items_file"
  else
    : > "$old_items_file"
  fi

  : > "$new_items_file"

  if ! has_populated="$(python3 -c 'import json,sys; print("1" if json.load(sys.stdin).get("has_populated") else "0")' < "$model_file")"; then
    log WARN "failed to parse model has_populated; degraded fallback"
    apply_degraded
    return 0
  fi
  if ! python3 -c 'import json,sys; d=json.load(sys.stdin); print("\n".join(d.get("monitor_order", [])))' < "$model_file" > "$monitor_order_file"; then
    log WARN "failed to parse model monitor_order; degraded fallback"
    apply_degraded
    return 0
  fi
  if ! focused_monitor="$(python3 -c 'import json,sys; print(str(json.load(sys.stdin).get("focused_monitor", "")))' < "$model_file")"; then
    log WARN "failed to parse model focused_monitor; degraded fallback"
    apply_degraded
    return 0
  fi
  if ! focused_workspace_model="$(python3 -c 'import json,sys; print(str(json.load(sys.stdin).get("focused_workspace", "")))' < "$model_file")"; then
    log WARN "failed to parse model focused_workspace; degraded fallback"
    apply_degraded
    return 0
  fi

  set --
  op_count=0

  if [ "$has_populated" = "1" ]; then
    set -- "$@" --set aerospace.root label.drawing=off label=""
  else
    set -- "$@" --set aerospace.root label.drawing=on label="WS: none"
  fi
  op_count=$((op_count + 1))

  divider_index=0
  monitor_count="$(python3 -c 'import sys; print(sum(1 for l in sys.stdin if l.strip()))' < "$monitor_order_file")"
  monitor_idx=0

  while IFS= read -r mon || [ -n "$mon" ]; do
    [ -z "$mon" ] && continue
    monitor_idx=$((monitor_idx + 1))

    mon_item="aerospace.mon.$mon"
    printf '%s\n' "$mon_item" >> "$new_items_file"

    ws_file="$(make_temp_file /tmp/sketchybar-aerospace-ws-list.XXXXXX)"
    if ! python3 -c 'import json,sys; d=json.load(sys.stdin); m=sys.argv[1]; print("\n".join(d.get("groups", {}).get(m, [])))' "$mon" < "$model_file" > "$ws_file"; then
      log WARN "failed to parse monitor workspace list monitor=$mon; degraded fallback"
      apply_degraded
      return 0
    fi

    while IFS= read -r ws || [ -n "$ws" ]; do
      [ -z "$ws" ] && continue
      ws_encoded="$(workspace_item_id "$ws")"
      ws_item="aerospace.ws.$ws_encoded"
      printf '%s\n' "$ws_item" >> "$new_items_file"
    done < "$ws_file"
    rm -f "$ws_file"

    if [ "$monitor_idx" -lt "$monitor_count" ]; then
      divider_index=$((divider_index + 1))
      divider_item="aerospace.divider.$divider_index"
      printf '%s\n' "$divider_item" >> "$new_items_file"
    fi
  done < "$monitor_order_file"

  reorder_needed=0
  if ! cmp -s "$old_items_file" "$new_items_file"; then
    reorder_needed=1
  fi

  if [ "$reorder_needed" -eq 1 ]; then
    while IFS= read -r old_item || [ -n "$old_item" ]; do
      [ -z "$old_item" ] && continue
      set -- "$@" --remove "$old_item"
      op_count=$((op_count + 1))
    done < "$old_items_file"
  else
    while IFS= read -r old_item || [ -n "$old_item" ]; do
      [ -z "$old_item" ] && continue
      if ! grep -Fx -- "$old_item" "$new_items_file" >/dev/null 2>&1; then
        set -- "$@" --remove "$old_item"
        op_count=$((op_count + 1))
      fi
    done < "$old_items_file"
  fi

  monitor_count="$(python3 -c 'import sys; print(sum(1 for l in sys.stdin if l.strip()))' < "$monitor_order_file")"
  monitor_idx=0
  divider_index=0

  while IFS= read -r mon || [ -n "$mon" ]; do
    [ -z "$mon" ] && continue
    monitor_idx=$((monitor_idx + 1))

    mon_item="aerospace.mon.$mon"
    mon_label="M$mon:"
    if [ "$mon" = "$focused_monitor" ]; then
      mon_label="*M$mon:"
    fi

    add_monitor=1
    if [ "$reorder_needed" -eq 0 ] && grep -Fx -- "$mon_item" "$old_items_file" >/dev/null 2>&1; then
      add_monitor=0
    fi
    if [ "$add_monitor" -eq 1 ]; then
      set -- "$@" --add item "$mon_item" left
      op_count=$((op_count + 1))
    fi

    set -- "$@" --set "$mon_item" \
      icon.drawing=off \
      label.drawing=on \
      label="$mon_label" \
      label.color=0xff89b4fa \
      label.padding_right=4 \
      background.drawing=off
    op_count=$((op_count + 1))

    ws_file="$(make_temp_file /tmp/sketchybar-aerospace-ws-render.XXXXXX)"
    if ! python3 -c 'import json,sys; d=json.load(sys.stdin); m=sys.argv[1]; print("\n".join(d.get("groups", {}).get(m, [])))' "$mon" < "$model_file" > "$ws_file"; then
      log WARN "failed to parse monitor workspace render list monitor=$mon; degraded fallback"
      apply_degraded
      return 0
    fi

    while IFS= read -r ws || [ -n "$ws" ]; do
      [ -z "$ws" ] && continue

      ws_encoded="$(workspace_item_id "$ws")"
      ws_item="aerospace.ws.$ws_encoded"

      add_ws=1
      if [ "$reorder_needed" -eq 0 ] && grep -Fx -- "$ws_item" "$old_items_file" >/dev/null 2>&1; then
        add_ws=0
      fi
      if [ "$add_ws" -eq 1 ]; then
        set -- "$@" --add item "$ws_item" left
        op_count=$((op_count + 1))
      fi

      escaped_ws="$(escape_single_quotes "$ws")"
      click_script="aerospace workspace '$escaped_ws' && sketchybar --trigger aerospace_workspace_change"

      ws_label="$ws"
      if [ "$ws" = "$focused_workspace_model" ]; then
        ws_label=">$ws<"
      fi

      ws_bg_draw="off"
      ws_label_color="0xffcdd6f4"
      ws_bg_color="0x00000000"
      if [ "$ws" = "$focused_workspace_model" ]; then
        ws_bg_draw="on"
        ws_label_color="0xff11111b"
        ws_bg_color="0xff89b4fa"
      fi

      set -- "$@" --set "$ws_item" \
        icon.drawing=off \
        label.drawing=on \
        label="$ws_label" \
        click_script="$click_script" \
        label.color="$ws_label_color" \
        background.drawing="$ws_bg_draw" \
        background.color="$ws_bg_color" \
        background.corner_radius=4
      op_count=$((op_count + 1))
    done < "$ws_file"
    rm -f "$ws_file"

    if [ "$monitor_idx" -lt "$monitor_count" ]; then
      divider_index=$((divider_index + 1))
      divider_item="aerospace.divider.$divider_index"

      add_divider=1
      if [ "$reorder_needed" -eq 0 ] && grep -Fx -- "$divider_item" "$old_items_file" >/dev/null 2>&1; then
        add_divider=0
      fi
      if [ "$add_divider" -eq 1 ]; then
        set -- "$@" --add item "$divider_item" left
        op_count=$((op_count + 1))
      fi

      set -- "$@" --set "$divider_item" \
        icon.drawing=off \
        label.drawing=on \
        label="|" \
        label.color=0xff6c7086 \
        background.drawing=off
      op_count=$((op_count + 1))
    fi
  done < "$monitor_order_file"

  log INFO "applying single sketchybar batch op_count=$op_count"
  sketchybar "$@"

  cp "$new_items_file" "$STATE_FILE"
  printf '%s' "$(now_ms)" > "$LAST_FULL_TS_FILE"
  printf '%s' "$focused_workspace_model" > "$FOCUSED_WS_FILE"

  cleanup_temp_files
  trap - EXIT INT TERM HUP
}

if [ "${AEROSPACE_SOURCE_ONLY:-0}" = "1" ]; then
  case "${1:-}" in
    --escape-single-quotes)
      escape_single_quotes "${2:-}"
      ;;
    --build-model)
      build_workspace_model_from_rows "${MONITORS_JSON:-[]}" "${WORKSPACES_JSON:-[]}" "${FOCUSED_WORKSPACE:-}" "${WINDOWS_ROWS_RAW:-}"
      ;;
    *)
      ;;
  esac
  exit 0
fi

case "${1:---refresh}" in
  --refresh) refresh ;;
  *) refresh ;;
esac
