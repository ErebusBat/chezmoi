#!/bin/zsh
chezmoi verify
if [[ $? -ne 0 ]]; then
  printf "#[fg=colour1, bg=colour237]CZ╳"
else
  printf "#[fg=colour22, bg=colour237]CZ♥"
fi
