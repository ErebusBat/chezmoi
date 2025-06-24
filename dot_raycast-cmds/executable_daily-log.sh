#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Daily Log
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Placeholder" }
# @raycast.packageName ErebusBat

# Documentation:
# @raycast.description Append Daily Log Entry
# @raycast.author Andrew Burns
~/bin/dlog $*
