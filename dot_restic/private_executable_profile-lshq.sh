#!/bin/bash
# Restic environment variables for lshq repository
export RESTIC_REPOSITORY="sftp://rsyncnet/restic/lshq"
# export RESTIC_REPOSITORY="local:///tmp/lshq_restic"
export RESTIC_PASSWORD_FILE="$HOME/.restic/.lshq.key"
