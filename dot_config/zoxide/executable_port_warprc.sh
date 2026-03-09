#!/usr/bin/env bash
set -euo pipefail

warprc_path="${1:-$HOME/.warprc}"

if [[ ! -f "$warprc_path" ]]; then
  printf 'Error: file not found: %s\n' "$warprc_path" >&2
  exit 1
fi

awk -F: '{print $2}' "$warprc_path" |
while IFS= read -r d; do
  d="${d//\"/}"
  d="${d/#\~/$HOME}"

  [[ -z "$d" ]] && continue
  if [[ ! -d "$d" ]]; then
    printf "Skipping non-path: $d"
    continue
  fi

  printf 'Processing %s\n' "$d"
  zoxide add "$d"
done
