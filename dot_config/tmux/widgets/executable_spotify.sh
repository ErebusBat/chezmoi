#!/bin/zsh
##
## Prerequisite Checks
##

# Getting API Rate Limits :/
# exit 0

# Test to see if we should not run (i.e. for power saving)
if [[ -f /tmp/lowpower ]]; then
  exit 0
fi

# Make sure we have the gospt app installed
if [[ ! -x $(which gospt) ]]; then
  exit 0
fi

##
## Default Settings
##
RATE_LIMIT_RUN_ONLY_EVERY_SECS=10
RATE_LIMIT_GRACE_SECS=2 # Time to add to 'now' when writing timestamp file
NO_PLAY_INDICATOR=1
HIDE_WHEN_PAUSED=1
RATE_LIMITED=0
BO_HOUR_START=17
BO_HOUR_END=9

TMUX_RIGHT_WIDTH=55 # This should match tmux status-right-length
# tmux right status is 25 wide w/o song
(( SONG_LIMIT = $TMUX_RIGHT_WIDTH - 25 ))

# Now see if there are settings
USER_SETTINGS_PATH=~/.config/tmux/widgets/spotify.conf.sh
if [[ -f $USER_SETTINGS_PATH ]]; then
  # echo "Sourcing user settings"
  source $USER_SETTINGS_PATH
fi

if [[ $RATE_LIMIT_RUN_ONLY_EVERY_SECS -gt 0 ]]; then
  # echo "Checking Rate Limit" >&2
  RATE_LIMIT_FILE_PATH=/tmp/tmux-spotify.stamp
  NOW_TS=$(date +%s)
  if [[ -f $RATE_LIMIT_FILE_PATH ]]; then
    # echo "Loading TS from file..."
    LAST_WRITE_TS=$(cat $RATE_LIMIT_FILE_PATH)
  else
    LAST_WRITE_TS=$NOW_TS
  fi

  [[ -z $LAST_WRITE_TS ]] && LAST_WRITE_TS=0

  # echo "LW: $LAST_WRITE_TS"
  # echo " N: $NOW_TS"

  # ((DELTA = $LAST_WRITE_TS - $NOW_TS))
  ((DELTA = $NOW_TS - $LAST_WRITE_TS ))
  # echo " D: $DELTA"

  if [[ $DELTA -le 0 || $DELTA -ge $RATE_LIMIT_RUN_ONLY_EVERY_SECS ]]; then
    # echo "$DELTA >= $RATE_LIMIT_RUN_ONLY_EVERY_SECS" >&2

    # Write timestamp file
    (( WRITE_TS = $NOW_TS + $RATE_LIMIT_GRACE_SECS ))
    # echo "WT: $WRITE_TS"
    echo "$WRITE_TS" > $RATE_LIMIT_FILE_PATH
  else
    # echo "$DELTA <= $RATE_LIMIT_RUN_ONLY_EVERY_SECS" >&2
    RATE_LIMITED=1
  fi
fi


# Don't actually query betwen 18:00-07:00
HOUR=$(date +%H)
if [[ $HOUR -ge $BO_HOUR_START || $HOUR -le $BO_HOUR_END ]]; then
  echo "Blackout Period Active; HOUR=${HOUR}, S=${BO_HOUR_START} E=${BO_HOUR_END}" >&2
  exit 0
fi

SONG_CACHE_FILE=/tmp/tmux-spotify.cache
# [[ -f $SONG_CACHE_FILE ]] || RATE_LIMITED=0

if [[ $RATE_LIMITED -ge 1 && -f $SONG_CACHE_FILE ]]; then
  echo "Rate Limited" >&2
else
  # Not rate limited, so run actual command
  gospt nowplaying > $SONG_CACHE_FILE
fi

# Testing line, for color
# printf "#[fg=brightblack, bg=default]&"

# Figure out what is actually running
nowplaying=$(cat $SONG_CACHE_FILE)
# if [[ $? -ne 0 ]]; then
  # printf "#[fg=brightred]gospt err"
  # exit 0
# fi


IS_PAUSED=0
grep '⏸' /tmp/tmux-spotify.cache > /dev/null 2>&1                                                                                                78% 192.168.68.101 🍎
if [[ $? -eq 0 ]]; then
  IS_PAUSED=1
fi
if [[ $HIDE_WHEN_PAUSED -ge 1 && $IS_PAUSED -ge 1 ]]; then
  printf '⏸'
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
