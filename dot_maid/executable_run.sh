#!/bin/zsh
MAID_DIR=~/.maid

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
maid clean --noop

log "Complete"
