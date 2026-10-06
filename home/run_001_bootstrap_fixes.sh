#!/usr/bin/env zsh
dir_path=~/.config/bin
file_path=$dir_path/config.json
if [[ ! -d $dir_path ]]; then
  mkdir -p $dir_path
fi
if [[ ! -f $file_path ]]; then
  touch $file_path
fi
