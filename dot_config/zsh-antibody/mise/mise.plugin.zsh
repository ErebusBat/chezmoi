if [[ -x /opt/homebrew/bin/mise ]]; then
  eval "$(/opt/homebrew/bin/mise activate)"
elif [[ -x ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate)"
fi
