#!/bin/zsh

#
# This is intended to be called from cron:
# */5 * * * * zsh -c '~/.maid/run.sh' 2>1 >/tmp/maid.log

MAID_DIR=$HOME/.maid

function log() {
  echo "[$(date)] $*"
}
log "Starting in $MAID_DIR"

# export HOME=/home/user
if [ -d $HOME/.rbenv ]; then
  log "Setting up rbenv"
  export PATH="$HOME/.rbenv/shims:$PATH:/opt/homebrew/bin"
  eval "$(rbenv init -)"
fi

cd $MAID_DIR

log "Starting maid"
maid clean --force

log "Complete"
