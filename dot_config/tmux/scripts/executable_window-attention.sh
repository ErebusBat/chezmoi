#!/bin/sh

usage() {
  echo "Usage: $0 set|clear [-t target]"
}

can_use_tmux() {
  if [[ -z "$TMUX_PANE" ]]; then
    return 1
  fi
  local tmux_socket="${TMUX%%,*}"
  if [[ -n "$tmux_socket" && ! -S "$tmux_socket" ]]; then
    return 1
  fi
  if ! tmux has-session >/dev/null 2>&1; then
    return 1
  fi
}

if ! can_use_tmux; then
  exit 0
fi

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
    tmux set -w -t "$target" window-status-style "fg=default,bg=red"
    ;;
  clear)
    tmux set -w -t "$target" window-status-style default
    ;;
  *)
    usage
    exit 1
    ;;
esac
