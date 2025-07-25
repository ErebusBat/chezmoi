#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Daily Log
# @raycast.mode silent
# change mode to fullOutput for debugging

# Optional parameters:
# @raycast.icon ✏️
# @raycast.argument1 { "type": "text", "placeholder": "Entry Text" }
# @raycast.packageName ErebusBat

# Documentation:
# @raycast.description Append Daily Log Entry
# @raycast.author Andrew Burns
export PATH=$HOME/bin:$PATH
~/bin/dlog $*
