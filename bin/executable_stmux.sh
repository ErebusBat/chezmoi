#!/bin/zsh
# This script is ran from tmux menu to setup sessions

# chezmoi status loop
if [[ -f ~/.config/tmux/init_chezmoi_secrets.sh ]]; then
  source ~/.config/tmux/init_chezmoi_secrets.sh

  if [[ -f $(which chezmoi) ]]; then
    echo "Current Dotfile Status:"
    chezmoi status
  fi
fi

echo "Starting Magic Mirror Chrome App..."
google-chrome --user-data-dir=/tmp/mmm-chrome --bwsi --app=http://mmm.erebusbat.net &

sessions=(
  left
  system
)
START_SESS=$1
[[ -z $START_SESS ]] && START_SESS=$sessions[1]

echo "Starting sessions... will switch to $START_SESS when done."
for s in $sessions; do
  tmuxp load -d $s
  sleep 5
done

if [[ -n $START_SESS ]]; then
  echo "Attaching to $START_SESS"
  # use tmpa script (opposed to `tmuxp load`) so we get fuzzy matching
  tmpa $START_SESS
fi
