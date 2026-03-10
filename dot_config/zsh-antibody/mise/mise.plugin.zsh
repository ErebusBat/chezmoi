if [[ -n $__MISE_ACTIVATED ]]; then
  # Mise has already been loaded, don't do it again
  return
fi

# Find and load
if [[ -x /opt/homebrew/bin/mise ]]; then
  eval "$(/opt/homebrew/bin/mise activate)"
elif [[ -x ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate)"
fi

if [[ -n $MISE_SHELL ]]; then
  # We have mise! Do Things!
  alias mr='mise run'

  __MISE_ACTIVATED=1
fi
