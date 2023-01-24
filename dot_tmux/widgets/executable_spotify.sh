#!/bin/zsh

NO_PLAY_INDICATOR=1
SONG_LIMIT=999

# Test to see if we should not run (i.e. for power saving)
if [[ -f /tmp/lowpower ]]; then
  exit 0
fi

if [[ ! -x $(which gospt) ]]; then
  exit 0
fi

# Testing line, for color
# printf "#[fg=brightblack, bg=default]&"

if [[ $NO_PLAY_INDICATOR -eq 1 ]]; then
  printf "$(gospt nowplaying | cut -c5-${SONG_LIMIT})"
else
  printf "$(gospt nowplaying)"
fi
