#!/bin/bash
set -euo pipefail

restic backup \
  --tag 15m --tag auto \
  --exclude-caches \
  --exclude-larger-than 50M \
  --exclude-file $HOME/.restic/common-excludes.lst \
  --exclude-file $HOME/.restic/15m-excludes.lst \
  --exclude "**/.git/**/*" \
  "$HOME/Documents/meetings" \
  "$HOME/.pi" \
  "$HOME/src" \
  "$HOME/Library/Application Support/OpenOats"
