#!/bin/zsh

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
  eval "$(/opt/homebrew/bin/mise activate zsh)"
elif [[ -x $HOME/.local/bin/mise ]]; then
  eval "$($HOME/.local/bin/mise activate zsh)"
fi

TASK_NAME=$1
typeset -a TASK_ARGS

case "$TASK_NAME" in
  .)
    TASK_NAME="rotate"
    ;;
  "")
    cd $WEZTERM_DIR && just _safe
    exit 0
    ;;
  noah)
    cd $WEZTERM_DIR && just group-disable ah
    exit 0
    ;;
  [Ss]top|[Pp]ause)
    TASK_NAME="pause-rotate"
    ;;
  r|R|rotate|Rotate)
    TASK_NAME="rotate"
    ;;
  [Ss]afe)
    cd $WEZTERM_DIR && just _safe
    exit 0
    ;;
  [Uu]nsafe)
    cd $WEZTERM_DIR && just _unsafe
    exit 0
    ;;
esac

# ZSH case statement fall-through types:
#   ;;  - Normal break (default, exits the case block)
#   ;&  - Fall through to the next case block unconditionally
#   ;;& - "Narrow" fall through - continues matching remaining patterns

case "$TASK_NAME" in
  pause-rotate)
    ;&
  random)
    ;&
  set-group)
    ;&
  set-*)
    ;&
  rotate)
    ;&
  group-enable)
    ;&
  group-disable)
    ;;
  *)
    TASK_ARGS=("$TASK_NAME")
    TASK_NAME="set-group"
    ;;
esac

cd $WEZTERM_DIR && just "$TASK_NAME" "${TASK_ARGS[@]}" | tail -n1
