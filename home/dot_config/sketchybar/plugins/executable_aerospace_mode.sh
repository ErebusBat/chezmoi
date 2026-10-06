#!/bin/sh

# Writes the current AeroSpace binding mode to a state file so that
# aerospace.sh can recolor the focused workspace when not in 'main' mode.
# Triggered by the aerospace_mode_change event (AEROSPACE_MODE is passed
# as a sketchybar event variable, which sketchybar injects into $AEROSPACE_MODE).

MODE_FILE="/tmp/sketchybar-aerospace-mode"
mode="${AEROSPACE_MODE:-main}"
printf '%s' "$mode" > "$MODE_FILE"

# Immediately re-highlight the focused workspace with the new color.
FOCUSED_WS_FILE="/tmp/sketchybar-aerospace-focused-workspace"
focused=""
if [ -f "$FOCUSED_WS_FILE" ]; then
  focused="$(cat "$FOCUSED_WS_FILE" 2>/dev/null || printf '')"
fi

if [ -n "$focused" ]; then
  ws_encoded="$(printf '%s' "$focused" | python3 -c 'import binascii,sys; d=sys.stdin.buffer.read(); print(binascii.hexlify(d).decode() or "00")')"
  ws_item="aerospace.ws.$ws_encoded"

  if [ "$mode" = "main" ] || [ -z "$mode" ]; then
    bg_color="0xff89b4fa"
    label_color="0xff11111b"
  else
    bg_color="0xffF38BA8"
    label_color="0xff11111b"
  fi

  sketchybar --set "$ws_item" \
    background.drawing=on \
    background.color="$bg_color" \
    label.color="$label_color"
fi
