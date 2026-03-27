#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/sketchybar"

FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.color=0xff003547 label.shadow.drawing=on icon.shadow.drawing=on background.border_width=2
else
  sketchybar --set $NAME background.color=0x44FFFFFF label.shadow.drawing=off icon.shadow.drawing=off background.border_width=0
fi

apps=$(aerospace list-windows --workspace "$1" 2>/dev/null | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
if [ "${apps}" != "" ]; then
  icon_strip=" "
  while read -r app; do
    icon_strip+="$($CONFIG_DIR/plugins/icon_map_fn.sh "$app") "
  done <<<"${apps}"
else
  icon_strip=""
fi
sketchybar --set $NAME label="$icon_strip"
