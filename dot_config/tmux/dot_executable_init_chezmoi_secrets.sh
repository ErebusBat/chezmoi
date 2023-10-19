#!/bin/zsh
if [[ -x $(which chezmoi) ]]; then
  echo "Current Dotfile Status:"
  chezmoi status
  echo ""
fi
