#!/bin/zsh
# vim: set ft=zsh ts=2 sw=2 sts=2 et ai si sta:

# TractionGuest startup script
if [[ -f ~/.config/tmux/init_chezmoi_secrets.sh ]]; then
  source ~/.config/tmux/init_chezmoi_secrets.sh
fi

# Starts apps / sessions after a cold boot
# Will not launch a terminal as it assumes you will be launching a terminal to execute this script.  This also allows for easily switching terminal emulators.

APPS=(
  # /Applications/OrbStack.app
  ~/Applications/Restart\ OrbStack.app

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
  open -g $app
done

# Terminal apps - With Options
open /Applications/Alacritty.app --args -e dlog-tail 1

# Startup Tmux
if [[ -x ~/bin/tgtmux.zsh ]]; then
  echo "Starting tmux...."
  ~/bin/tgtmux.zsh
fi
