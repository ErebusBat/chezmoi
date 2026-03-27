#!/bin/sh

# Displays the current AeroSpace binding mode when it's not 'main'.
# Triggered by the aerospace_mode_change event, which passes AEROSPACE_MODE.

mode="${AEROSPACE_MODE:-main}"

if [ "$mode" = "main" ] || [ -z "$mode" ]; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on label="[$mode]"
fi
