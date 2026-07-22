#!/usr/bin/env zsh
set -euo pipefail

TRUSTED_CASKS=(
  manaflow-ai/cmux/cmux
  nikitabobko/tap/aerospace
)

TAPS_FULL_TRUST=(
  ### Official Taps
  # Opencode
  anomalyco/tap
  can1357/tap
  atlassian/acli
  garethgeorge/backrest-tap
  lightspeed-hospitality/lsk-tools
  manaflow-ai/cmux

  ### OSS Well Known Taps
  # openclaw/tap
  osx-cross/arm
  osx-cross/avr
  qmk/qmk
  rbenv/tap
  wezterm/wezterm
  # SketchyBar + JankyBorders
  derailed/k9s
)

FORMULA_TO_TRUST=(
  common-fate/granted/granted
  nikitabobko/tap/aerospace
  tinted-theming/tinted/tinty
  felixkratz/formulae/borders

  ### Offical Formula
  teamookla/speedtest/speedtest

  ### Misc
  crambl/tap/mdns-scanner
  xo/xo/usql
  yetidevworks/yscan/yscan        # Network scanner
  psviderski/tap/uncloud          # docker pussh
  lablup/tap/all-smi

  # liam-deacon/tap/codex-usage
  # liam-deacon/tap/latest-version
  # liam-deacon/tap/telegram-cli
  # opgginc/tap/opencode-bar
  # steipete/tap/blackbar
  # steipete/tap/codexbar
  # steipete/tap/repobar
  # steipete/tap/trimmy
)

UNTRUSTED_TAPS=(
  # Not that it is untrusted, we just trust the formula above
  # felixkratz/formulae

  # Deprecated / renamed formulae
  psviderski/tap/docker-pussh
)

function brew() {
  local cmd=${argv[1]}
  local msg=${argv[-1]}
  local -a args=("${(@)argv[2,-2]}")

  echo "*** INFO: $msg" >&2
  echo "> brew $cmd $args[@]" >&2
  command brew $cmd "$args[@]"
}


##################################################
# UNTRUST
# We have to process untrust first in case we are
# trusting specific formula
##################################################
brew untrust "${UNTRUSTED_TAPS[@]}" "UNTRUSTING TAPS"

##################################################
# TRUST
##################################################
brew trust "$TAPS_FULL_TRUST[@]" "Adding taps to homebrew trusted list"

# echo "*** INFO: Adding casks to homebrew trusted list:" >&2
# echo "> brew trust --cask $TRUSTED_CASKS[@]" >&2
brew trust --cask  "$TRUSTED_CASKS[@]" "Adding casks to homebrew trusted list"

echo "*** INFO: Adding formulas to homebrew trusted list:" >&2
# echo "x> brew trust --formula $FORMULA_TO_TRUST[@]" >&2
brew trust --formula  "$FORMULA_TO_TRUST[@]" "Adding formulas to homebrew trusted list"
