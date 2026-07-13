#!/bin/bash
set -euo pipefail

restic backup \
  --tag obsidian --tag auto \
  --exclude-caches \
  "$HOME/Documents/AI/wiki/llm-vimwiki" \
  "$HOME/Documents/Obsidian"
