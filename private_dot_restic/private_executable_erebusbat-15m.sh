#!/bin/bash
set -euo pipefail

restic backup \
  --tag obsidian --tag auto \
  --exclude-caches \
  "$HOME/Documents/Obsidian"
