#!/usr/bin/env zsh
#
# Schedule this (every 6h) script with:
#   0 */6 * * * /home/aburns/git/.cron.sh >> /tmp/git-mirror-sync.log 2>&1
#
set -euo pipefail
MISE_BIN_PATH=$HOME/.local/bin/mise

# Make sure that we're in the script directory
cd ${0:h}

echo "################################################################################"
echo "# Git Mirror Sync Start $(hostname) @ $(date)"
echo "################################################################################"

if [[ ! -x $MISE_BIN_PATH ]]; then
  echo "*** FATAL: Could not find mise @ $MISE_BIN_PATH"
  exit 1
fi

$MISE_BIN_PATH x just -- just mirror-fetch-all

echo "### Mirror Sync End $(hostname) @ $(date) #####################"
echo "\n"
