if [[ -n $MISE_SHELL ]]; then
  # Mise has already been loaded, don't do it again
  return
fi

# Find and load
if [[ -x /opt/homebrew/bin/mise ]]; then
  eval "$(/opt/homebrew/bin/mise activate)"
elif [[ -x ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate)"
elif [[ -x /usr/local/bin/mise ]]; then
  eval "$(/usr/local/bin/mise activate)"
fi

if [[ -n $MISE_SHELL ]]; then
  # Refresh mise when changing directories, not before every prompt.
  autoload -Uz add-zsh-hook
  add-zsh-hook -d precmd _mise_hook_precmd 2>/dev/null

  # We have mise! Do Things!

  alias mr='mise run'
  alias mx='mise exec'
fi
