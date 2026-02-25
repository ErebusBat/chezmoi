#!/bin/sh

prefix="🤖 "
mode="set"

while [ "$#" -gt 0 ]; do
  case "$1" in
    set|clear|toggle)
      mode="$1"
      ;;
    --prefix)
      shift
      prefix="$1"
      ;;
    --prefix=*)
      prefix="${1#--prefix=}"
      ;;
    -h|--help)
      printf '%s\n' "usage: set-window-prefix.sh [set|clear|toggle] [--prefix '🤖 ']"
      exit 0
      ;;
  esac
  shift
done

name="$(tmux display-message -p '#W')"

case "$name" in
  "$prefix"*)
    has_prefix=1
    ;;
  *)
    has_prefix=0
    ;;
esac

case "$mode" in
  set)
    if [ "$has_prefix" -eq 0 ]; then
      tmux rename-window -- "$prefix$name"
    fi
    ;;
  clear)
    if [ "$has_prefix" -eq 1 ]; then
      tmux rename-window -- "${name#"$prefix"}"
    fi
    ;;
  toggle)
    if [ "$has_prefix" -eq 1 ]; then
      tmux rename-window -- "${name#"$prefix"}"
    else
      tmux rename-window -- "$prefix$name"
    fi
    ;;
esac
