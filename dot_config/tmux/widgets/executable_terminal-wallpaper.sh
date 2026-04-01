#!/usr/bin/env zsh
CONF_DIR=~/.config/wezterm
UNSAFE_GROUP=ah
UNSAFE_INDICATOR="🌸"

# If config dir is not there then no need to err out, just exit
if [[ ! -d $CONF_DIR ]]; then
  exit 0
fi

# show-config will return an non-zero EC if there are no valid wallpapers for the given
# group (i.e. it is disabled).  Therefore if we get a 0 EC we know that the group is ENABLED
cd $CONF_DIR
just show-config $UNSAFE_GROUP 2>1 >/dev/null
jec=$?
if [[ $jec -eq 0 ]]; then
  echo $UNSAFE_INDICATOR
fi
