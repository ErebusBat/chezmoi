#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Markdown Tool
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📝
# @raycast.packageName ErebusBat

# Documentation:
# @raycast.description Transform Clipboard with Markdown Tool
# @raycast.author Andrew Burns

NEW_TOOLPATH=~/go/bin/markdown-tool

USE_NEWTOOL=
[[ -x $NEW_TOOLPATH ]] && USE_NEWTOOL=yes
# USE_NEWTOOL= # Override

# Use the new version, if availble
if [[ $USE_NEWTOOL ]]; then
  echo "Using New Tool" >&2
  $NEW_TOOLPATH | pbcopy
else
  ~/bin/tg-markdown | pbcopy
fi

# To show text in Raycast
pbpaste
