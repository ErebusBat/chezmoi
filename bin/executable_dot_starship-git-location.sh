#!/bin/bash

set -euo pipefail

truncate_middle() {
  local text="$1"
  local max_len="$2"

  if (( ${#text} <= max_len )); then
    printf "%s" "$text"
    return
  fi

  if (( max_len < 7 )); then
    max_len=7
  fi

  local left_len=$(( (max_len - 3) / 2 ))
  local right_len=$(( max_len - 3 - left_len ))
  printf "%s...%s" "${text:0:left_len}" "${text: -right_len}"
}

MAX_LEN="${STARSHIP_GIT_LOCATION_MAX:-28}"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_dir="$(git rev-parse --git-dir 2>/dev/null)"
  common_dir="$(git rev-parse --git-common-dir 2>/dev/null)"

  if [[ "$git_dir" != "$common_dir" ]]; then
    raw_name="$(basename "$(dirname "$common_dir")")"
    label="$(truncate_middle "$raw_name" "$MAX_LEN")"
    printf "󰙅 %s" "$label"
  else
    branch="$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)"
    label="$(truncate_middle "$branch" "$MAX_LEN")"
    printf " %s" "$label"
  fi
elif git rev-parse --is-inside-git-dir >/dev/null 2>&1; then
  branch="$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)"
  label="$(truncate_middle "$branch" "$MAX_LEN")"
  printf " %s" "$label"
else
  exit 1
fi
