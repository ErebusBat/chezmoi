#!/usr/bin/env zsh
set -euo pipefail

BYPASS_MARKER_FILE="NO_AUTO_PULL"

function pull_myserver() {
  local mys_path="$1"
  echo "*** INFO: Attempting to Pull latest changes from $mys_path"
  if [[ ! -d $mys_path ]]; then
    echo "*** FATAL: Path does not exist $mys_path"
    exit 1
  elif [[ -f "$mys_path/$BYPASS_MARKER_FILE" ]]; then
    echo "*** WARN: Found $mys_path/$BYPASS_MARKER_FILE; bypassing auto-update"
    exit 0
  elif ! command -v git >/dev/null 2>&1; then
    echo "*** FATAL: Could not find git on path"
    exit 2
  fi

  cd $mys_path
  git pull --autostash
}

PATH_CANDIDATES=(
  $HOME/src/erebusbat/myserver
  /myserver
)
for pc in $PATH_CANDIDATES; do
  # printf ">>$pc"
  # if [[ -d $pc ]]; then
  #   printf " (exists)"
  # fi
  # printf "<<\n"
  if [[ -d $pc ]]; then
    pull_myserver "$pc"
    echo "*** INFO: MyServer Auto update completed"
  fi
done

# vim: set ft=zsh ts=2 sw=2 sts=2 et ai si sta:
