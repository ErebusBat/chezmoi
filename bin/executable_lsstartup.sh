#!/bin/zsh
# vim: set ft=zsh ts=2 sw=2 sts=2 et ai si sta:

# TractionGuest startup script
if [[ -f ~/.config/tmux/init_chezmoi_secrets.sh ]]; then
  source ~/.config/tmux/init_chezmoi_secrets.sh
fi

# Starts apps / sessions after a cold boot
# Will not launch a terminal as it assumes you will be launching a terminal to execute this script.  This also allows for easily switching terminal emulators.

  # ~/Applications/Restart\ OrbStack.app
APPS=(
  #-- Productivity
  /Applications/Obsidian.app
  /Applications/Fantastical.app
  /Applications/Todoist.app
  /Applications/Due.app
  /Applications/1Password.app

  #-- Web
  /Applications/Google\ Chrome.app

  #-- Communications
  /Applications/Granola.app
  /Applications/Slack.app
  /System/Applications/Messages.app
  /Applications/Spotify.app
  /Applications/Telegram.app
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
    # open -na "Google Chrome" --args --profile-directory="Default"
    # open -na "Google Chrome" --args --profile-directory="Profile 1"
  else
    echo "[$(date)] ***ERROR Launching Chrome - Profile $profile_name not found (dir=$profile_dir)"
  fi
}
open_chrome_profile "LightspeedHQ" "Default"
open_chrome_profile "ErebusBat@gmail.com" "Profile 1"

# Terminal apps - With Options
# open /Applications/Alacritty.app --args -e dlog-tail 1

# Startup Tmux
if [[ -x ~/bin/lstmux.sh ]]; then
  echo "Starting tmux...."
  ~/bin/lstmux.sh
else
  echo "No tmux sessions available, use 'tmpa' to start one"
fi
