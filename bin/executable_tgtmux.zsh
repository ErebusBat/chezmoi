#!/bin/zsh
# $HOME/bin/tgtmux.zsh
# This script is ran from tmux menu to setup sessions

# Authenticate with 1Password so that our
if [[ -x ~/.tmux/op_auth.sh ]]; then
  eval $(~/.tmux/op_auth.sh)
fi

sessions=(
  guest-server
  system
)
START_SESS=$1
[[ -z $START_SESS ]] && START_SESS=guest-server

echo "Starting sessions... will switch to $START_SESS when done."
for s in $sessions; do
  tmuxp load -d $s
  sleep 5
done

# echo "Starting FetLife VPN Connection"
# nmcli con up FetLife

# echo "Updating Toggl status"
# toggl

if [[ -n $START_SESS ]]; then
  echo "Attaching to $START_SESS"
  # use tmpa script (opposed to `tmuxp load`) so we get fuzzy matching
  tmpa $START_SESS
fi
