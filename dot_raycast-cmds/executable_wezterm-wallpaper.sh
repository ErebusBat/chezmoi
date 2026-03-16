#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Terminal Wallpaper
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌈
# @raycast.argument1 { "type": "text", "placeholder": "Task Name", "optional": true }
# @raycast.packageName ErebusBat/wezterm-wallpaper

# Documentation:
# @raycast.description Switch WezTerm Wallpaper
# @raycast.author ErebusBat

# Be sure that your environment is setup for any tools you may need/want to use
export PATH=$HOME/bin:$PATH
WEZTERM_DIR=$HOME/.config/wezterm

if [[ -x /opt/homebrew/bin/mise ]]; then
  eval "$(/opt/homebrew/bin/mise activate bash)"
elif [[ -x $HOME/.local/bin/mise ]]; then
  eval "$($HOME/.local/bin/mise activate bash)"
fi

TASK_NAME=$1

# if [[ -z $TASK_NAME || $TASK_NAME == "." ]]; then
if [[ -z $TASK_NAME ]]; then
  cd $WEZTERM_DIR && just _safe
  exit 0
fi

case "$TASK_NAME" in
  [Ss]afe)
    TASK_NAME="disable-ah-common"
    ;;
  [Uu]nsafe)
    TASK_NAME="enable-ah-common"
    ;;
esac

if [[ $TASK_NAME != random && $TASK_NAME != set-* && $TASK_NAME != enable-ah-common && $TASK_NAME != disable-ah-common ]]; then
  TASK_NAME="set-$TASK_NAME"
fi

cd $WEZTERM_DIR && just $TASK_NAME
