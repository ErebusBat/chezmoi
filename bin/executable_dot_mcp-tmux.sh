#!/bin/bash
# vim: set ft=bash ts=2 sw=2 sts=2 et ai si sta:

# Load NVM First
source ~/.nvm/nvm.sh
nvm use 22 >&2

exec npx -y tmux-mcp
