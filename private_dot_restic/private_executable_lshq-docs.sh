#!/bin/bash
set -euo pipefail

restic backup \
  --tag docs \
  --exclude-caches \
  --exclude-file="$RESTIC_DIR/src-excludes.lst" \
  "$HOME/src/lshq/docs" \
  "$HOME/Documents/AI/wiki/upserve"

# This is not routing correctly
# ~/bin/dlog "💾 lshq/docs"
