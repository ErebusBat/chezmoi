LIBPQ_BIN=/opt/homebrew/opt/libpq/bin
if [[ ! -d $LIBPQ_BIN ]]; then
  return
fi
if [[ ! -x $LIBPQ_BIN/psql ]]; then
  return
fi

export PATH=$PATH:$LIBPQ_BIN
