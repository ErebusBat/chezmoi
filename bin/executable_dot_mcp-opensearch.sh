#!/bin/bash
# vim: set ft=bash ts=2 sw=2 sts=2 et ai si sta:

set -e

# Load NVM First
if [[ ! -r ~/.nvm/nvm.sh ]]; then
  echo "*** FATAL: Missing NVM: ~/.nvm/nvm.sh" >&2
  exit 1
fi

source ~/.nvm/nvm.sh
nvm use 22 >&2

os_env=$1
if [[ $# -gt 0 ]]; then
  shift
fi
AWS_REGION=${AWS_REGION:=us-east-1}
AWS_PROFILE=${AWS_PROFILE:=lsu/ops/poweruser/us-east-1}
OPENSEARCH_URL=
if [[ $os_env == "production" ]]; then
  OPENSEARCH_URL="https://logs.internal.upserve.com"
elif [[ $os_env == "staging" ]]; then
  OPENSEARCH_URL="https://logs.internal.staging.upserve.com"
else
  echo "*** FATAL: Unknown Env: $os_env" >&2
  exit 1
fi

# Setup env for actual MCP
export AWS_REGION
export AWS_PROFILE
export OPENSEARCH_URL

# Launch / replace the shell process
exec uvx opensearch-mcp-server-py "$@"
