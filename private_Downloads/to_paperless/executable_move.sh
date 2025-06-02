#!/bin/zsh
setopt +o nomatch
SOURCE_FOLDER=$HOME/Downloads/to_paperless
CONSUME_FOLDER=/Volumes/paperless_consume

if [[ ! -d $CONSUME_FOLDER ]]; then
  echo "*** ERROR: Paperless Consume Folder not mounted?"
  exit 1
fi

echo "*** MOVING Files to Paperless Consume"
mv -v $SOURCE_FOLDER/*.{pdf,png,jpg} $CONSUME_FOLDER/
