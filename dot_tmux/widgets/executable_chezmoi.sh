#!/bin/zsh
exit 0

# If we have a 1Password helper, then source it
if [[ -x ~/.tmux/op_auth.sh ]]; then
  eval $(~/.tmux/op_auth.sh RO)
fi

chezmoi verify
if [[ $? -ne 0 ]]; then
  printf "#[fg=colour1, bg=colour237]CZ╳"
else
  printf "#[fg=colour22, bg=colour237]CZ♥"
fi
