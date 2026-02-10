#!/bin/bash
set -euo pipefail

# Manual backup: Comprehensive backup for explicit user invocation
# Full home directory with verbose output, run before system changes

exec restic backup \
  --tag manual \
  --verbose \
  --exclude-caches \
  --exclude-file="$RESTIC_DIR/home-excludes.lst" \
  --exclude-file="$RESTIC_DIR/src-excludes.lst" \
  "$HOME"
