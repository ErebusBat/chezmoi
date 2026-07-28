#!/bin/bash
set -euo pipefail

restic backup \
  --tag vital --tag auto \
  --exclude-caches \
  --exclude-larger-than 50M \
  --exclude-file $HOME/.restic/common-excludes.lst \
  --exclude-file $HOME/.restic/15m-excludes.lst \
  --exclude "**/.git/**/*" \
  "$HOME/.omp" \
  "$HOME/.agents/skills" \
  "$HOME/Documents/AI/wiki/llm-vimwiki" \
  "$HOME/Documents/Obsidian"
