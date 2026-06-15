#!/usr/bin/env zsh
set -euo pipefail

# This normally doesn't need to be ran and probably
# only on bootstraps for newer homebrew versions.

brew trust --formula tinted-theming/tinted/tinty
brew trust --formula teamookla/speedtest/speedtest
brew trust felixkratz/formulae
brew trust anomalyco/tap
brew trust rbenv/tap
brew trust --formula common-fate/granted/granted
brew trust wez/wezterm
brew trust --cask nikitabobko/tap/aerospace
