#!/bin/zsh
setopt +o nomatch
SOURCE_FOLDER=$HOME/Downloads/to_paperless
CONSUME_FOLDER=/Volumes/paperless_consume
CONSUME_REMOTE_PATH=smb://nas.erebusbat.net/paperless_consume

if [[ ! -d $CONSUME_FOLDER ]]; then
  echo "*** ERROR: Paperless Consume Folder not mounted?\n"
  echo "    Would you like to try to mount it now? (yes to mount)"
  read ANSWER
  if [[ $ANSWER == "yes" ]]; then
    echo -n "***  INFO: Attempting to mount"
    open $CONSUME_REMOTE_PATH

    for i in {1..10}; do
      echo -n "."
      if [[ -d $CONSUME_FOLDER ]]; then
        echo -n " MOUNTED!\n"
        break
      fi
      sleep 1
    done
  fi

  # Check to see if it was mounted
  if [[ -d $CONSUME_FOLDER ]]; then
    # Okay
  else
    echo "*** FATAL: Mount and try again"
    exit 1
  fi
fi

FILE_TYPES_TO_MOVE=(pdf png jpg)
for ext in $FILE_TYPES_TO_MOVE; do
  echo "*** MOVING *.$ext Files to Paperless Consume"
  mv -v $SOURCE_FOLDER/*.$ext $CONSUME_FOLDER/
done
exit 0

