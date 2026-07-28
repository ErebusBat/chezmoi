#!/bin/bash
set -euo pipefail

restic backup \
  --tag 15m --tag auto \
  --exclude-caches \
  --exclude-larger-than 50M \
  --exclude-file $HOME/.restic/common-excludes.lst \
  --exclude-file $HOME/.restic/15m-excludes.lst \
  --exclude "**/.git/**/*" \
  "$HOME/.agents/skills" \
  "$HOME/.omp" \
  "$HOME/.pi" \
  "$HOME/Documents/meetings" \
  "$HOME/Library/Application Support/OpenOats" \
  "$HOME/src"

if [[ -f ~/.restic/lshq-docs.sh ]]; then
  ~/.restic/backup lshq docs
fi
