#!/usr/bin/env zsh
if [[ ! -f ~/src/pers/toggl/toggl_stats.rb ]]; then
  echo "ERR_NO_TOGGL"
  exit 1
fi

DO_TIMEBLOCKS=
if [[ $DO_TIMEBLOCKS ]]; then
  THEMIN=$(date +%M)
  if [[ $THEMIN -ge 45 ]]; then
    # echo "☒☒☒☐"
    echo "***_"
  elif [[ $THEMIN -ge 30 ]]; then
    # echo "☒☒☐☐"
    echo "**__"
  elif [[ $THEMIN -ge 15 ]]; then
    # echo "☒☐☐☐"
    echo "*___"
  else
    # echo "☐☐☐☐"
    echo "____"
    # echo "☒☒☒☒"
  fi
else
  cd ~/src/pers/toggl
  ./toggl_stats.rb $*
fi
exit 0

STATFILE=/tmp/toggl_left
# echo $(($(date +%s) - $(stat -t %s -f %m -- "$filename"))) seconds
[[ -z $1 ]] || TRY_UPDATE=1
THRESHOLD=$(( 15 * 60)) # 15 Minutes
THRESHOLD=120

if [[ ! -f $STATFILE ]]; then
  echo "UNK"
  exit 0
fi
STATFILE_AGE=$(($(date +%s) - $(stat -t %s -f %m -- "$STATFILE")))

SUFFIX=""
if [[ ! $STATFILE_AGE -lt $THRESHOLD ]]; then
  OUTPUT=$(head -n1 $STATFILE)
  if [[ $TRY_UPDATE -gt 0 ]]; then
    SUFFIX="${SUFFIX}?"
  else
    $HOME/bin/toggl --write-stats
    # Pass 1 to $1 so we don't recurse call ourselfs
    $0 1
    exit 0
  fi
fi

OUTPUT=$(head -n1 $STATFILE)
if [[ $OUTPUT =~ "stop" ]]; then
  SUFFIX=" ${SUFFIX}S"
  OUTPUT=$(awk '{print $1}' $STATFILE)
fi

echo "$OUTPUT$SUFFIX"
