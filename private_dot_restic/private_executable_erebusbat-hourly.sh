#!/bin/bash
set -euo pipefail

restic backup \
  --tag hourly --tag auto \
  --exclude-caches \
  --exclude-file="$RESTIC_DIR/src-excludes.lst" \
  "$HOME/src/erebusbat/" \
  "$HOME/.local/share/mcp-memory-service/db/backups"
