#!/bin/zsh
SESSION_FILE=/tmp/.op_session.$UID

RO=

if [[ $1 == "1" ]]; then
  if [[ -f $SESSION_FILE ]]; then
    rm -f $SESSION_FILE
  fi
elif [[ $1 == "RO" ]]; then
  RO=1
fi

# If file exists just eval it
if [[ -s $SESSION_FILE ]]; then
  cat $SESSION_FILE
elif [[ -n $RO ]]; then
  echo "RO Flag specified and session file non existant"
else
  EC=1
  while [[ $EC -ne 0 ]]; do
    echo "EC=$EC" >&2
    if [[ -f $SESSION_FILE ]]; then
      echo "removing $SESSION_FILE" >&2
      rm -f $SESSION_FILE
    fi

    op signin -f > $SESSION_FILE
    EC=$?
    echo "after EC=$EC" >&2
    cat $SESSION_FILE >&2
    echo "^^^ file" >&2
    chown $USER $SESSION_FILE
    chmod 400 $SESSION_FILE
  done
    cat $SESSION_FILE >&2
  cat $SESSION_FILE
fi

