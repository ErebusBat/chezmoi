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

~/bin/tg-markdown | pbcopy

# To show text in Raycast
pbpaste
