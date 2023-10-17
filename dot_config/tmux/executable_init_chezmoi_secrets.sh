#!/bin/zsh
# vim: set ft=zsh ts=2 sw=2 sts=2 et ai si sta:

if [[ ! -f $(which chezmoi) ]]; then
  exit -
fi

echo "Current Dotfile Status:"
chezmoi status
echo ""
