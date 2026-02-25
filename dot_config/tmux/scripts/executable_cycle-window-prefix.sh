#!/bin/sh

prefix="🤖 "
sessions_arg=""

direction="$1"
case "$direction" in
  next|prev)
    shift
    ;;
  *)
    printf '%s\n' "usage: cycle-window-prefix.sh next|prev [--prefix '🤖 '] [--sessions 'Work,Personal']" >&2
    exit 2
    ;;
esac

invalid=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --prefix)
      shift
      if [ -z "$1" ]; then
        invalid=1
      else
        prefix="$1"
      fi
      ;;
    --prefix=*)
      prefix="${1#--prefix=}"
      ;;
    --sessions)
      shift
      if [ -z "$1" ]; then
        invalid=1
      else
        sessions_arg="$1"
      fi
      ;;
    --sessions=*)
      sessions_arg="${1#--sessions=}"
      ;;
    -h|--help)
      printf '%s\n' "usage: cycle-window-prefix.sh next|prev [--prefix '🤖 '] [--sessions 'Work,Personal']" >&2
      exit 0
      ;;
    *)
      invalid=1
      ;;
  esac
  shift
done

if [ "$invalid" -ne 0 ]; then
  printf '%s\n' "usage: cycle-window-prefix.sh next|prev [--prefix '🤖 '] [--sessions 'Work,Personal']" >&2
  exit 2
fi

current_session="$(tmux display-message -p '#S')"
current_index="$(tmux display-message -p '#I')"

sessions_order=""
if [ -z "$sessions_arg" ]; then
  sessions_order="$current_session"
else
  old_ifs="$IFS"
  IFS=','
  set -- $sessions_arg
  IFS="$old_ifs"
  for raw in "$@"; do
    raw="${raw#"${raw%%[![:space:]]*}"}"
    raw="${raw%"${raw##*[![:space:]]}"}"
    if [ -z "$raw" ]; then
      invalid=1
      break
    fi
    if [ -z "$sessions_order" ]; then
      sessions_order="$raw"
    else
      sessions_order="$sessions_order
$raw"
    fi
  done
fi

if [ "$invalid" -ne 0 ]; then
  printf '%s\n' "usage: cycle-window-prefix.sh next|prev [--prefix '🤖 '] [--sessions 'Work,Personal']" >&2
  exit 2
fi

candidates_file="$(mktemp)"
trap 'rm -f "$candidates_file"' EXIT

current_order=0
order=0

while IFS= read -r session; do
  if [ -z "$session" ]; then
    continue
  fi
  order=$((order + 1))
  if [ "$session" = "$current_session" ]; then
    current_order=$order
  fi
  indices="$(tmux list-windows -t "$session" -F '#{window_index}::#{window_name}' 2>/dev/null \
    | awk -F '::' -v p="$prefix" 'index($2, p) == 1 {print $1}' \
    | sort -n)"
  for idx in $indices; do
    printf '%s\n' "$order::$session::$idx" >> "$candidates_file"
  done
done <<EOF
$sessions_order
EOF

count="$(wc -l < "$candidates_file")"
if [ "$count" -lt 2 ]; then
  exit 0
fi

target_session=""
target_index=""

if [ "$current_order" -eq 0 ]; then
  case "$direction" in
    next)
      first="$(awk 'NR==1 {print; exit}' "$candidates_file")"
      rest="${first#*::}"
      session_part="${rest%%::*}"
      index_part="${rest#*::}"
      target_session="$session_part"
      target_index="$index_part"
      ;;
    prev)
      last="$(awk 'END {print}' "$candidates_file")"
      rest="${last#*::}"
      session_part="${rest%%::*}"
      index_part="${rest#*::}"
      target_session="$session_part"
      target_index="$index_part"
      ;;
  esac
else
  case "$direction" in
    next)
      while IFS= read -r entry; do
        order_part="${entry%%::*}"
        rest="${entry#*::}"
        session_part="${rest%%::*}"
        index_part="${rest#*::}"
        if [ "$order_part" -gt "$current_order" ] || { [ "$order_part" -eq "$current_order" ] && [ "$index_part" -gt "$current_index" ]; }; then
          target_session="$session_part"
          target_index="$index_part"
          break
        fi
      done < "$candidates_file"
      if [ -z "$target_session" ]; then
        first="$(awk 'NR==1 {print; exit}' "$candidates_file")"
        rest="${first#*::}"
        session_part="${rest%%::*}"
        index_part="${rest#*::}"
        target_session="$session_part"
        target_index="$index_part"
      fi
      ;;
    prev)
      last=""
      while IFS= read -r entry; do
        order_part="${entry%%::*}"
        rest="${entry#*::}"
        session_part="${rest%%::*}"
        index_part="${rest#*::}"
        if [ "$order_part" -lt "$current_order" ] || { [ "$order_part" -eq "$current_order" ] && [ "$index_part" -lt "$current_index" ]; }; then
          last="$entry"
        fi
      done < "$candidates_file"
      if [ -n "$last" ]; then
        rest="${last#*::}"
        session_part="${rest%%::*}"
        index_part="${rest#*::}"
        target_session="$session_part"
        target_index="$index_part"
      else
        last_entry="$(awk 'END {print}' "$candidates_file")"
        rest="${last_entry#*::}"
        session_part="${rest%%::*}"
        index_part="${rest#*::}"
        target_session="$session_part"
        target_index="$index_part"
      fi
      ;;
  esac
fi

if [ -n "$target_session" ] && [ -n "$target_index" ]; then
  tmux select-window -t "$target_session:$target_index"
fi
