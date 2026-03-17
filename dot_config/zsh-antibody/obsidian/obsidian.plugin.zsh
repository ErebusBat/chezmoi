OBSIDIAN_BIN="/Applications/Obsidian.app/Contents/MacOS/Obsidian"

if [[ ! -x "$OBSIDIAN_BIN" ]]; then
  return
fi

export PATH="${OBSIDIAN_BIN:h}:$PATH"
unset OBSIDIAN_BIN
