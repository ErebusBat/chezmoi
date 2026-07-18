#!/usr/bin/env zsh
# set -euo pipefail
set -u

LOOP_SLEEP=15

function open-tunnel() {
  ssh -NT \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -R 192.168.14.9:1236:127.0.0.1:1235 \
    maze
  return $?
}

while [ 1 ]; do
  echo "[$(date)] Starting tunnel"

  local ec=125
  open-tunnel
  ec=$?

  echo "[$(date)] Tunnel exited: $ec; sleeping ${LOOP_SLEEP}s"
  sleep $LOOP_SLEEP
done
