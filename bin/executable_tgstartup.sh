#!/bin/zsh

# TractionGuest startup script
#
# Starts apps / sessions after a cold boot
# Will not launch a terminal as it assumes you will be launching a terminal to execute this script.  This also allows for easily switching terminal emulators.

APPS=(
  /Applications/Fantastical.app
  /Applications/Firefox.app
  /Applications/Google\ Chrome.app
  /Applications/Obsidian.app
  /Applications/Slack.app
  /Applications/Todoist.app

  /Applications/Synergy.app
  /System/Applications/Messages.app
  /Applications/Messenger.app
)

# APPS=()
for app in $APPS; do
  echo "[$(date)] Launching ${app:r:t}"
  open $app
done

# Startup Tmux
if [[ -x ~/bin/tgtmux.zsh ]]; then
  echo "Starting tmux...."
  ~/bin/tgtmux.zsh
fi
