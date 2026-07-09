#!/bin/bash
set -euo pipefail

restic backup \
  --tag docs \
  --exclude-caches \
  --exclude-file="$RESTIC_DIR/src-excludes.lst" \
  "$HOME/src/lshq/docs"

~/bin/dlog "💾 lshq/docs"
