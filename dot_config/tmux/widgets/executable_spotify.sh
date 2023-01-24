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

# Seperator character + coloring for actual song
printf "#[fg=brightblack, bg=default]|#[fg=blue]"

nowplaying=$(gospt nowplaying)

if [[ $NO_PLAY_INDICATOR -eq 1 ]]; then
  printf "$(echo "${nowplaying}" | sed -E 's/^[⏸▶ ]+//g')"
else
  printf "${nowplaying}"
fi
