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
  # /Applications/Messenger.app
  # /Applications/Discord.app
  /Applications/Telegram.app
  /Applications/Obsidian.app
  /Applications/Spotify.app
  /Applications/Slack.app
  /Applications/1Password.app
  /Applications/Granola.app
  /Applications/Visual Studio Code.app

  # /Applications/Google\ Chrome.app
  # See Below for opening Chrome with the correct profiles

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

####################
### Chrome
####################
# Here is a small script you can run if you need to know which profile is which:
# for dir in ~/Library/Application\ Support/Google/Chrome/Profile*; do
#   name=$(jq -r '.profile.name' "$dir/Preferences" 2>/dev/null)
#   email=$(jq -r '.account_info[0].email // empty' "$dir/Preferences" 2>/dev/null)
#   icon=$(jq -r '.profile.avatar_icon' "$dir/Preferences" 2>/dev/null)
#   echo "$(basename "$dir") => name: \"$name\" email: \"$email\" icon: \"$icon\""
# done
function open_chrome_profile() {
  profile_name=$1
  profile_dir=$2
  if [[ -d "$HOME/Library/Application Support/Google/Chrome/$profile_dir" ]]; then
    echo "[$(date)] Launching Chrome - $profile_name"
    open -na "Google Chrome" --args --profile-directory="$profile_dir"
  else
    echo "[$(date)] ***ERROR Launching Chrome - Profile $profile_name not found (dir=$profile_dir)"
  fi
}
# open -na "Google Chrome" --args --profile-directory="Default"
# open -na "Google Chrome" --args --profile-directory="Profile 1"
open_chrome_profile "ErebusBat@gmail.com" "Default"
open_chrome_profile "CompanyCam" "Profile 1"

# Terminal apps - With Options
# open /Applications/Alacritty.app --args -e dlog-tail 1

################################################################################
# TMUX Sessions
################################################################################
if [[ -x ~/bin/tmux-sessions-start.zsh ]]; then
  ~/bin/tmux-sessions-start.zsh
fi
