#!/bin/bash
set -euo pipefail

restic backup \
  --tag hourly --tag auto \
  --exclude-caches \
  --exclude-file="$RESTIC_DIR/src-excludes.lst" \
  "$HOME/src/lshq/"
