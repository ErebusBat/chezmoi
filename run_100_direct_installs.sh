#!/usr/bin/env zsh
set -euo pipefail

# We use justfiles, make sure we have our tool
if ! command -v just 2>&1 >/dev/null; then
  echo "*** WARNING: 'just' not detected on this system yet, not running direct installs"
  exit 0
fi

function print_header() {
  printf "================================================================================\n"
  printf "=== Start $1\n"
  printf "================================================================================\n"
}

function print_footer() {
  printf "--- End $1\n"
  printf "--------------------------------------------------------------------------------\n"
}

################################################################################
### OhMyPi
if [[ -f ~/.omp/justfile && ! -x ~/.bun/bin/omp ]]; then
  print_header "OhMyPi"
  just -f ~/.omp/justfile install
  print_header "OhMyPi"
fi

################################################################################
### Herdr
if [[ -f ~/.config/herdr/justfile && ! -x ~/.local/bin/herdr ]]; then
  print_header "Herdr"
  just -f ~/.config/herdr/justfile install
  print_header "Herdr"
fi

# vim: set ft=zsh ts=2 sw=2 sts=2 et ai si sta:
