#!/bin/zsh

# $HOME/bin/fltmux.zsh
# This script is ran from tmux menu to setup sessions

sessions=(
  fetlife-com
  fetlife-gcp
  system
  # fetlife-systems
)
START_SESS=fetlife-com

echo "Starting sessions... will switch to $START_SESS when done."
for s in $sessions; do
  tmuxp load -d $s
  sleep 5
done

# This uses window linking which isn't supported by tmuxp
# so we have to 1) create sessions above; 2) use raw tmux commands
echo "Setting up left hand monitor"
$HOME/bin/tmux-left

echo "tmux Startup Complete"

# Switch to startup session
if [[ -n $START_SESS ]]; then
  tmuxp load -y $START_SESS
fi
