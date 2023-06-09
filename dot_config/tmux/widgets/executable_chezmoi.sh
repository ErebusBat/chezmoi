#!/bin/zsh

# Test to see if we should not run (i.e. for power saving)
if [[ -f /tmp/lowpower ]]; then
  exit 0
fi

# Testing line, for color
# printf "#[fg=brightblack, bg=default]&"

chezmoi verify
if [[ $? -ne 0 ]]; then
  printf "#[fg=brightred, bg=default]CZ╳"
else
  printf "#[fg=brightblack, bg=default]CZ♥"
fi
