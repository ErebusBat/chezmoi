#!/bin/bash
# set -e

# Output Mode is normally `silent` `fullOutput` can be used for debugging
# https://github.com/raycast/script-commands/blob/master/documentation/OUTPUTMODES.md

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Sidecar Connectivity
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.argument1 { "type": "text", "placeholder": "Connect?  Y/N/tog", "optional": false }
# @raycast.packageName ErebusBat/uplift-desk/sidecar

# Documentation:
# @raycast.description Desk Handler
# @raycast.author ErebusBat

# Be sure that your environment is setup for any tools you may need/want to use
export PATH=$HOME/bin:$PATH

DEBUG=0
SHOULD_CONNECT=t

function log() {
  (( DEBUG <= 0 )) && return 0
  local msg=$1
  echo "[$(date)] $msg" >&2
}

function printl() {
  local msg=$1
  log "$1"

  # Used to output to Raycast
  printf "$msg\n"
}

function sc_connected_dev_name() {
  sidecarctl status --json | jq .connected.name
}

############################################################
### Arg Parsing
############################################################

# Need to decode $1 into $SHOULD_CONNECT
_arg=$(echo "$1" | tr '[:upper:]' '[:lower:]')
case "$_arg" in
  y|yes)          SHOULD_CONNECT=1 ;;
  true)           SHOULD_CONNECT=1 ;;
  1|on)           SHOULD_CONNECT=1 ;;
  c|con|connect)  SHOULD_CONNECT=1 ;;
  t|tog|toggle)   SHOULD_CONNECT=t ;;
  *)              SHOULD_CONNECT=t ;;  # Toggle
esac
log "DEBUG: arg=$_arg SHOULD_CONNECT=$SHOULD_CONNECT"

############################################################
### Main
############################################################

# Check toggle state first, then reuse code below
if [[ $SHOULD_CONNECT == "t" ]]; then
  connected_dev=$(sidecarctl status --json | jq .connected.name)
  log "INFO: Will toggle; connected_dev=$connected_dev"
  if [[ $connected_dev == "null" ]]; then
    SHOULD_CONNECT=1
  else
    SHOULD_CONNECT=0
  fi
fi

#  # Exit codes
#
#   Code │ Meaning
#  ──────┼────────────────────────────────────────────────────────────────────────────────
#    0   │ Success
#    2   │ Usage / argument error
#    3   │ No matching device (or no connected device for  disconnect )
#    4   │ Provider unavailable
#    5   │ Device was already connected on  connect 
#    6   │ Permission denied
#    10  │ Operation failed (e.g. Sidecar runtime failures, timeouts, connection refused)

if [[ $SHOULD_CONNECT -gt 0 ]]; then
  log "INFO: Attemping to connect to sidecar display in preference order..."

  res_s=$(sidecarctl connect \
    --device-name "Dad iPad Pro" \
    --device-name "LSHQ-ipad"
  )
  sc_ec=$?
  log "DEBUG: 'sidecarctl connect'.ec=$sc_ec"

  msg=
  case "$sc_ec" in
    5)   msg="Already connected to $(sc_connected_dev_name)" ;;
    6)   msg="Permission Denied!" ;;
    *)   msg="Sidecar Connected (ec=$sc_ec)" ;;
  esac

  printl "$msg"
else
  log "INFO: Disconnecting sidecar display"
  sidecarctl disconnect
  printl "Disconnected"
fi
