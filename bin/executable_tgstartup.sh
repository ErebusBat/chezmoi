#!/bin/zsh
# vim: set ft=zsh ts=2 sw=2 sts=2 et ai si sta:

# TractionGuest startup script
if [[ -f $(which chezmoi) ]]; then
  echo "Current Dotfile Status:"
  chezmoi status
fi

# Starts apps / sessions after a cold boot
# Will not launch a terminal as it assumes you will be launching a terminal to execute this script.  This also allows for easily switching terminal emulators.

APPS=(
  /Applications/OrbStack.app

  /Applications/Fantastical.app
  /Applications/Firefox.app
  /Applications/Safari.app
  /Applications/Google\ Chrome.app
  /Applications/Obsidian.app
  /Applications/Slack.app
  /Applications/Todoist.app

  /System/Applications/Messages.app
  /Applications/Messenger.app
  /Applications/Spotify.app
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
