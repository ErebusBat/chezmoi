#!/bin/zsh
# vim: set ft=zsh ts=2 sw=2 sts=2 et ai si sta:

# Move this active terminal window to workspace P before launching anything else
if command -v aerospace-mv-focused-win-to-workspace >/dev/null 2>&1; then
  aerospace-mv-focused-win-to-workspace P
fi

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
  /Applications/Docker.app

  #-- Web
  /Applications/Google\ Chrome.app

  #-- Communications
  /Applications/OpenOats.app
  /Applications/Slack.app
  /System/Applications/Messages.app
  /Applications/Spotify.app
  /Applications/AyuGram.app
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
# We use the justfile in aerospace to make sure they go to the correct workspace
# open_chrome_profile "LightspeedHQ" "Default"
# open_chrome_profile "ErebusBat@gmail.com" "Profile 1"
cd ~/.config/aerospace && just startup-chrome

# Terminal apps - With Options
# open /Applications/Alacritty.app --args -e dlog-tail 1

# Startup Tmux
if [[ -x ~/bin/lstmux.sh ]]; then
  echo "Starting tmux...."
  ~/bin/lstmux.sh
else
  echo "No tmux sessions available, use 'tmpa' to start one"
fi

# Let this window be used for dlog-tail
# Remember that we moved it to the [P]roductivity workspace above
echo "Press ENTER to start dlog-tail"
read
clear
dlog-tail 2
