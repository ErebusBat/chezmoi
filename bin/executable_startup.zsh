#!/bin/zsh
# vim: set ft=zsh ts=2 sw=2 sts=2 et ai si sta:

################################################################################
# SSH Idtentity Setup
################################################################################
for key in ~/.ssh/id_*; do
  if [[ $key =~ '\.pub$' ]]; then
    continue
  fi

  ssh-add $key
done
echo -n "\n"

################################################################################
# Application Startup
################################################################################
# Starts apps / sessions after a cold boot
# Will not launch a terminal as it assumes you will be launching a terminal to execute this script.  This also allows for easily switching terminal emulators.
APPS=(
  # ~/Applications/Restart\ OrbStack.app

  /Applications/Fantastical.app
  /Applications/Todoist.app
  /Applications/Due.app
  # /Applications/Firefox.app
  /Applications/Safari.app
  /Applications/Google\ Chrome.app
  /Applications/Obsidian.app
  # /Applications/Slack.app

  /System/Applications/Messages.app
  /Applications/Messenger.app
  /Applications/Spotify.app
  /Applications/Discord.app
)

# APPS=()
for app in $APPS; do
  echo "[$(date)] Launching ${app:r:t}"
  open -g $app
done

# Terminal apps - With Options
# open /Applications/Alacritty.app --args -e dlog-tail 1

################################################################################
# TMUX Sessions
################################################################################
if [[ -x ~/bin/tmux-sessions-start.zsh ]]; then
  ~/bin/tmux-sessions-start.zsh
fi
