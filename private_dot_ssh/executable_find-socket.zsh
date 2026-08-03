#!/usr/bin/env zsh
set -euo pipefail

DEBUG=${DEBUG:-0}
FOUND_SOCKET=
CANDIDATES=()

function check-socket() {
  local sock=$1

  if [[ -z $sock ]] || [[ ! -S $sock ]]; then
    return 1
  fi

  if SSH_AUTH_SOCK=$sock ssh-add -l 2>&1 >/dev/null; then
    FOUND_SOCKET=$sock
  else
    return 1
  fi
}

function end-good() {
  if [[ -n $1 ]] && [[ -S $1 ]]; then
    FOUND_SOCKET=$1
  fi

  printf "*** Found: SSH_AUTH_SOCK=$FOUND_SOCKET\n" >&2
  printf "export SSH_AUTH_SOCK=$FOUND_SOCKET\n"
  exit 0
}

function dbug() {
  if [[ $DEBUG -le 0 ]]; then
    return 0
  fi
  printf "[$(date)] DEBUG: $*\n" >&2
}

### Add candidates
if [[ -n $SSH_AUTH_SOCK ]]; then
  dbug "Adding existing SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
  CANDIDATES+=($SSH_AUTH_SOCK)
fi

# Maze / Debian
CANDIDATES+=(/tmp/ssh-*/agent.*(N))
# macOS / Herdr
CANDIDATES+=(~/.local/share/wezterm/agent.*(N))
# Doormouse / Ubuntu 26
CANDIDATES+=(~/.ssh/agent/s.*(N))

dbug "Found ${#CANDIDATES} candidates: $CANDIDATES"

# Check them
for sock in $CANDIDATES; do
  dbug "---"
  dbug "Checking candidate: $sock"
  if check-socket $sock; then
    dbug "Checking candidate: $sock: SUCCESS!!!!"
    end-good $sock
  else
    dbug "Checking candidate: not valid"
  fi
done
dbug "Done with candidate loop"

# If we get here then there were no good sockets
printf "Could not find any valid SSH_AUTH_SOCK :(" >&2
exit 2
