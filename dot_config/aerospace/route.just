# Shared helpers for "capture before -> launch -> move new window" workflows.

_state-file := '/tmp/aerospace-route-before.txt'

[private]
_capture-before app_name:
    @aerospace list-windows --all --format '%{window-id}|%{app-name}' \
      | awk -F'|' '$2=="{{app_name}}"{print $1}' \
      | sort -n > {{_state-file}}

[private]
[script("/bin/bash")]
_move-to-workspace app_name workspace:
  set -euo pipefail

  state_file='{{_state-file}}'

  if [[ ! -f "$state_file" ]]; then
    echo "ERROR: Missing state file: $state_file"
    exit 1
  fi

  cleanup() {
    rm -f "$state_file"
  }
  trap cleanup EXIT

  new_id=""
  for _ in {1..40}; do
    sleep 0.25

    after="$({
      aerospace list-windows --all --format '%{window-id}|%{app-name}' \
        | awk -F'|' '$2=="{{app_name}}"{print $1}' \
        | sort -n
    })"

    new_id="$({
      comm -13 "$state_file" <(printf '%s\n' "$after") | tail -n 1
    })"

    if [[ -n "$new_id" ]]; then
      break
    fi
  done

  if [[ -z "$new_id" ]]; then
    echo "ERROR: No new {{app_name}} window detected before timeout"
    exit 1
  fi

  aerospace move-node-to-workspace --window-id "$new_id" "{{workspace}}"
