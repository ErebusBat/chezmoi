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
  ####################
  ### Top Screen
  ####################
  /Applications/Safari.app
  /System/Applications/Messages.app
  /Applications/Messenger.app
  # /Applications/Discord.app
  /Applications/Telegram.app
  /Applications/Obsidian.app
  /Applications/Spotify.app
  /Applications/Slack.app
  /Applications/1Password.app

  ####################
  ### Bottom Screen
  ####################
  #-- Pos 1
  #-- Pos 2
  /Applications/Google\ Chrome.app
  # /Applications/Firefox.app
  #-- Pos 3
  #-- Pos 4
  #-- Pos 5
  #-- Pos 6

  ####################
  ### Laptop Screen
  ####################
  #-- Pos 1
  /Applications/Todoist.app
  #-- Pos 2
  /Applications/Fantastical.app
  #-- Pos 3
  /Applications/Due.app
  #-- Pos 4
  #-- Pos 5
  #-- Pos 6

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
