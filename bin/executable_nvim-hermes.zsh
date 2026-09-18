#!/usr/bin/env zsh
set -euo pipefail

# Use aburns' Neovim configuration, but run with Hermes' permissions.
# Plugins, state, caches and HOME stay separate from aburns' writable data.
: ${HERMES_USER:=hermes}
: ${HERMES_NVIM_BIN:=/usr/bin/nvim}
: ${HERMES_NVIM_CONFIG_HOME:=/home/aburns/.config}
: ${HERMES_NVIM_APPNAME:=nvim}

account=$(/usr/bin/getent passwd "$HERMES_USER") || {
  print -u2 -- "Unknown account: $HERMES_USER"
  exit 1
}
fields=("${(@s/:/)account}")
target_uid=$fields[3]
target_home=$fields[6]

# Explicit overrides avoid inheriting the caller's data/cache directories or
# attaching to an existing Neovim instance owned by a different user.
launch=(/usr/bin/env -u VIMINIT -u EXINIT -u VIM -u VIMRUNTIME
  -u NVIM -u NVIM_LISTEN_ADDRESS -u XDG_RUNTIME_DIR
  "HOME=$target_home" "USER=$HERMES_USER" "LOGNAME=$HERMES_USER"
  "XDG_CONFIG_HOME=$HERMES_NVIM_CONFIG_HOME"
  "XDG_DATA_HOME=$target_home/.local/share"
  "XDG_STATE_HOME=$target_home/.local/state"
  "XDG_CACHE_HOME=$target_home/.cache"
  "NVIM_APPNAME=$HERMES_NVIM_APPNAME"
  "$HERMES_NVIM_BIN")

if [[ $EUID == $target_uid ]]; then
  exec "${launch[@]}" "$@"
fi
exec /usr/bin/sudo -u "$HERMES_USER" -H -- "${launch[@]}" "$@"
