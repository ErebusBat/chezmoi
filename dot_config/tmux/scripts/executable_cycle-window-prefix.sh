#!/bin/sh

prefix="🤖 "

direction="$1"
case "$direction" in
  next|prev)
    shift
    ;;
  *)
    printf '%s\n' "usage: cycle-window-prefix.sh next|prev [--prefix '🤖 ']" >&2
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
    -h|--help)
      printf '%s\n' "usage: cycle-window-prefix.sh next|prev [--prefix '🤖 ']" >&2
      exit 0
      ;;
    *)
      invalid=1
      ;;
  esac
  shift
done

if [ "$invalid" -ne 0 ]; then
  printf '%s\n' "usage: cycle-window-prefix.sh next|prev [--prefix '🤖 ']" >&2
  exit 2
fi

session="$(tmux display-message -p '#S')"
current_index="$(tmux display-message -p '#I')"

indices="$(tmux list-windows -t "$session" -F '#{window_index}::#{window_name}' \
  | awk -F '::' -v p="$prefix" 'index($2, p) == 1 {print $1}' \
  | sort -n)"

set -- $indices
count=$#
if [ "$count" -lt 2 ]; then
  exit 0
fi

target=""
case "$direction" in
  next)
    for idx in "$@"; do
      if [ "$idx" -gt "$current_index" ]; then
        target="$idx"
        break
      fi
    done
    if [ -z "$target" ]; then
      target="$1"
    fi
    ;;
  prev)
    last=""
    for idx in "$@"; do
      if [ "$idx" -lt "$current_index" ]; then
        target="$idx"
      fi
      last="$idx"
    done
    if [ -z "$target" ]; then
      target="$last"
    fi
    ;;
esac

if [ -n "$target" ]; then
  tmux select-window -t "$session:$target"
fi
