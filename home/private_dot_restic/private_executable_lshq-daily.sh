#!/bin/bash
set -euo pipefail

restic backup \
  --tag daily --tag auto \
  --exclude-caches \
  --exclude-file="$RESTIC_DIR/home-excludes.lst" \
  --exclude-file="$RESTIC_DIR/src-excludes.lst" \
  "$HOME"
