#!/usr/bin/env zsh
RAYCAST_AI_PROVIDERS=providers.yaml

function ls_providers() {
  local provider="$1"
  if [[ -n $provider ]]; then
    provider="$provider" yq eval '.providers[] | select(.id == strenv(provider)) | .id as $pid | .models[] | $pid + "/" + .id' "$RAYCAST_AI_PROVIDERS"
  else
    yq eval '.providers[] | .id as $pid | .models[] | $pid + "/" + .id' "$RAYCAST_AI_PROVIDERS"
  fi
}
