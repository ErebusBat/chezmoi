#!/bin/zsh

chezmoi verify
if [[ $? -ne 0 ]]; then
  printf "#[fg=brightred, bg=default]CZ╳"
else
  printf "#[fg=black, bg=default]CZ♥"
fi
