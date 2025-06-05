#!/bin/zsh
mv -v direct/bin_config.json-Mac-*.json direct/bin_config.json-$(hostname -s).json
git add direct
