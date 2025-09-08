#!/bin/zsh
TERM_THEME_SYNC_SCRIPT=$HOME/bin/sync_terminal_theme_to_system.sh

if [[ ! -d /Applications/Raycast.app ]]; then
  echo "***FATAL: Raycast does not appear to be installed!"
  exit 1
fi

# Use Raycast to toggle from lgiht / dark
open raycast://extensions/raycast/system/toggle-system-appearance

# Wait for it to apply; then sync terminal theme
if [[ -x $TERM_THEME_SYNC_SCRIPT ]]; then
  sleep 1
  $TERM_THEME_SYNC_SCRIPT
else
  echo "*** WARN: Could not find script to sync terminal appearance!"
fi
