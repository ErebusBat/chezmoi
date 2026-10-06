if [[ -n $MISE_SHELL ]]; then
  # Mise has already been loaded, don't do it again
  return
fi

# Interactive terminal sessions need mise's directory-change hooks. Shells
# without a terminal (for example, Oh My Pi commands) only need its shims.
typeset -a mise_activation_flags=()
[[ -t 0 && -t 1 ]] || mise_activation_flags=(--shims)

# Find and load
if [[ -x /opt/homebrew/bin/mise ]]; then
  eval "$(/opt/homebrew/bin/mise activate zsh "${mise_activation_flags[@]}")"
elif [[ -x ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate zsh "${mise_activation_flags[@]}")"
elif [[ -x /usr/local/bin/mise ]]; then
  eval "$(/usr/local/bin/mise activate zsh "${mise_activation_flags[@]}")"
fi
unset mise_activation_flags

if [[ -n $MISE_SHELL ]]; then
  # Refresh mise when changing directories, not before every prompt.
  autoload -Uz add-zsh-hook
  add-zsh-hook -d precmd _mise_hook_precmd 2>/dev/null

  # We have mise! Do Things!

  alias mr='mise run'
  alias mx='mise exec'
fi
