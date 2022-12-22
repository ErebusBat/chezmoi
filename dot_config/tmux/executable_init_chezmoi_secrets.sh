#!/bin/zsh

# Used to init chezmoi secrets store upon tmux invokation
# so that the chezmoi widget functions

echo "================================================================================"
echo "Dotfiles Status:"
chezmoi status
echo "================================================================================"
