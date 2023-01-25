#!/bin/zsh

# Getting API Rate Limits :/
exit 0

NO_PLAY_INDICATOR=1

TMUX_RIGHT_WIDTH=55 # This should match tmux status-right-length
# tmux right status is 25 wide w/o song
(( SONG_LIMIT = $TMUX_RIGHT_WIDTH - 25 ))

# Test to see if we should not run (i.e. for power saving)
if [[ -f /tmp/lowpower ]]; then
  exit 0
fi

if [[ ! -x $(which gospt) ]]; then
  exit 0
fi

# Testing line, for color
# printf "#[fg=brightblack, bg=default]&"

# Figure out what is actually running
nowplaying=$(gospt nowplaying)
if [[ $? -ne 0 ]]; then
  # printf "#[fg=brightred]gospt err"
  exit 0
fi
if [[ $SONG_LIMIT -gt 0 ]]; then
  nowplaying=$(echo "${nowplaying}" | cut -c1-$SONG_LIMIT)
  # nowplaying="${nowplaying}┅"
fi

# Seperator character + coloring for actual song
printf "#[fg=brightblack, bg=default]|#[fg=blue]"

# Actual output
if [[ $NO_PLAY_INDICATOR -eq 1 ]]; then
  printf "$(echo "${nowplaying}" | sed -E 's/^[⏸▶ ]+//g')"
else
  printf "${nowplaying}"
fi
