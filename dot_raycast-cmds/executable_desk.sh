#!/bin/bash

# Output Mode is normally `silent` `fullOutput` can be used for debugging
# https://github.com/raycast/script-commands/blob/master/documentation/OUTPUTMODES.md

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Desk Management Scripts
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.argument1 { "type": "text", "placeholder": "At Desk?  Y/N" }
# @raycast.packageName ErebusBat/uplift-desk

# Documentation:
# @raycast.description Desk Handler
# @raycast.author ErebusBat

# Be sure that your environment is setup for any tools you may need/want to use
export PATH=$HOME/bin:$PATH

SHOULD_CONNECT=0
# Need to decode $1 into $SHOULD_CONNECT
_arg=$(echo "$1" | tr '[:upper:]' '[:lower:]')
case "$_arg" in
  y|yes|true|t|1|on) SHOULD_CONNECT=1 ;;
  *)                 SHOULD_CONNECT=0 ;;
esac

if [[ $SHOULD_CONNECT -gt 0 ]]; then
  sidecarctl connect --device-name LSHQ-ipad
  aerospace enable on
  echo "Setup for Desk Work"
else
  # Eject SeaBack if it is mounted
  if [ -d "/Volumes/SeaBack" ]; then
    diskutil eject "/Volumes/SeaBack" >/dev/null 2>&1 || true
  fi
  aerospace enable off
  sidecarctl disconnect
  echo "Disabled Desk Only Items"
fi
