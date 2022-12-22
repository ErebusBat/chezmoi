#!/bin/zsh

# Testing line, for color
# printf "#[fg=brightblack, bg=default]&"

chezmoi verify
if [[ $? -ne 0 ]]; then
  printf "#[fg=brightred, bg=default]CZ╳"
else
  printf "#[fg=brightblack, bg=default]CZ♥"
fi
