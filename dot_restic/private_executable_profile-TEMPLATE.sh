#!/bin/bash
# Restic environment variables for PROFILE_NAME repository
#
# Copy this file to profile-YOURNAME.sh and edit the values below

export RESTIC_REPOSITORY="protocol://server/path/to/repo"
export RESTIC_PASSWORD_FILE="$HOME/.restic/.YOURNAME.key"

# Optional: Additional restic environment variables
# export RESTIC_COMPRESSION=auto
# export AWS_ACCESS_KEY_ID="your-key"
# export AWS_SECRET_ACCESS_KEY="your-secret"
