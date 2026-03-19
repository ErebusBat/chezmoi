#!/bin/bash
set -euo pipefail

restic backup \
  --tag 15m --tag auto \
  --exclude-caches \
  "$HOME/Documents/meetings" \
  "$HOME/Library/Application Support/OpenOats"
