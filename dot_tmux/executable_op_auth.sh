#!/bin/zsh
SESSION_FILE=/tmp/.op_session.$UID

FORCE=$1

if [[ -n $FORCE ]]; then
  if [[ -f $SESSION_FILE ]]; then
    rm -f $SESSION_FILE
  fi
fi

# If file exists just eval it
if [[ -f $SESSION_FILE ]]; then
  cat $SESSION_FILE
else
  EC=1
  while [[ $EC -ne 0 ]]; do
    if [[ -f $SESSION_FILE ]]; then
      rm -f $SESSION_FILE
    fi

    op signin -f > $SESSION_FILE
    EC=$?
    chown $USER $SESSION_FILE
    chmod 400 $SESSION_FILE
  done
fi

