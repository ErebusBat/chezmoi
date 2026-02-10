#!/bin/bash
source ~/.restic/lshq-env.sh

backup() {
  if [[ -z $1 ]]; then
    echo "ERROR: Specify a folder to backup"
    return 1
  elif [[ ! -d $1 ]]; then
    echo "ERROR: Specify a folder to backup"
    return 1
  fi
  restic backup --exclude-file ~/.restic/src-excludes.lst $*
}
