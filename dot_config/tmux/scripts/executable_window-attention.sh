#!/bin/sh

set -e

usage() {
  echo "Usage: $0 set|clear [-t target]"
}

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

action="$1"
shift

target=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -t|--target)
      target="$2"
      shift 2
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [ -z "$target" ] && [ -n "$TMUX_PANE" ]; then
  target=$(tmux display-message -p -t "$TMUX_PANE" "#{window_id}")
fi

if [ -z "$target" ]; then
  target=":"
fi

case "$action" in
  set)
    tmux set -w -t "$target" window-status-style "fg=white,bg=red"
    ;;
  clear)
    tmux set -w -t "$target" window-status-style default
    ;;
  *)
    usage
    exit 1
    ;;
esac
