#!/bin/bash
source ~/.restic/.restic-env

# Restic will not expand ~
export RESTIC_REPOSITORY="sftp://rsyncnet/restic/openclaw"
export RESTIC_PASSWORD_FILE="$HOME/.restic/.erebusbat.key"
