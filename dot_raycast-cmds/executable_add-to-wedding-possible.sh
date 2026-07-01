#!/bin/bash

# Output Mode is normally `silent` `fullOutput` can be used for debugging
# https://github.com/raycast/script-commands/blob/master/documentation/OUTPUTMODES.md

# Required parameters:
# @raycast.schemaVersion 0
# @raycast.title Add to Wedding Possible
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 💍
# @raycast.packageName ErebusBat/add-to-wedding-possible

# Documentation:
# @raycast.description Adds the currently playing song (in spotify) to the wedding possible playlist.
# @raycast.author ErebusBat

# Be sure that your environment is setup for any tools you may need/want to use
export PATH=$HOME/bin:$PATH

# Make sure that mise is there and versioning works
if command -v mise &> /dev/null; then
  eval $(mise activate --shims)
fi

cd $HOME/bin

mise x -- ./spotify-add-wedding-possible
