#!/bin/zsh
# This script is ran from tmux menu to setup sessions

sessions=(
  system
  left
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
