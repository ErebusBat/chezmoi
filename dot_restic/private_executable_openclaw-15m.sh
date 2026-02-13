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


restic backup \
  --exclude-caches --tag=cron \
  ~/src/erebusbat/myserver/batbot ~/.openclaw
