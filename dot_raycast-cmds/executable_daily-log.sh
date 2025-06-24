#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Daily Log
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Entry Text" }
# @raycast.packageName ErebusBat

# Documentation:
# @raycast.description Append Daily Log Entry
# @raycast.author Andrew Burns
~/bin/dlog $*
