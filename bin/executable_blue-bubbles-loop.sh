#!/usr/bin/env zsh
# set -euo pipefail
set -u

LOOP_SLEEP=15

# The bluebubbles tunnel goes to `maze`, which is only reachable through the
# home sshuttle tunnel. Gate on an end-to-end probe of maze's sshd through
# the tunnel instead of blindly retrying ssh while the tunnel is down.
# (sshuttle on macOS uses pf rules, not kernel routes, so route-table checks
# do not work as a health signal.)
MAZE_TS_IP=100.92.65.146  # maze.erebusbat.net (Tailscale)

function home-tunnel-up() {
  nc -z -G 5 $MAZE_TS_IP 22 >/dev/null 2>&1
}

function wait-for-home-tunnel() {
  while ! home-tunnel-up; do
    echo "[$(date)] home-ssh-tunnel not up; waiting 10s"
    sleep 10
  done
}

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
  wait-for-home-tunnel
  echo "[$(date)] Starting tunnel"

  local ec=125
  open-tunnel
  ec=$?

  echo "[$(date)] Tunnel exited: $ec; sleeping ${LOOP_SLEEP}s"
  sleep $LOOP_SLEEP
done
