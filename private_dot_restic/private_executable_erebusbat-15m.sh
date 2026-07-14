#!/bin/bash
set -euo pipefail

restic backup \
  --tag obsidian --tag auto \
  --exclude-caches \
  "$HOME/.omp" \
  "$HOME/Documents/AI/wiki/llm-vimwiki" \
  "$HOME/Documents/Obsidian"
