#!/bin/bash

# This should be done automatically, but if we do this then we can run this script directly
if [[ -z $RESTIC_REPOSITORY ]]; then
  source ~/.restic/profile-openclaw.sh
fi

# Setup failure settings AFTER the above check or we will get an
# ubnound variable failure on the check
set -euo pipefail

# restic is provided by mise on dart6p
if ! command -v restic &> /dev/null; then
    source ~/.config/zsh-antibody/mise/mise.plugin.zsh
fi

## Should we exclude the cron tag?
TAG_ARG="--tag=cron"
if [[ "${1:-}" == "--no-cron" ]]; then
  TAG_ARG=""
fi

# Run the backup
restic backup \
  --exclude-caches $TAG_ARG \
  ~/src/erebusbat/myserver/batbot ~/.openclaw
