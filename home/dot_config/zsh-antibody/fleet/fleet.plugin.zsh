if [[ ! -f "$HOME/.config/fleet/settings.sh" ]]; then
  return
fi

source "$HOME/.config/fleet/settings.sh"

if [[ -z ${FLEET_ROOT:-} || ! -r "$FLEET_ROOT/completions/_fleet" ]]; then
  return
fi

if [[ -o interactive ]]; then
  _fleet_load_completions() {
    if ! (( $+functions[compdef] )); then
      return
    fi

    source "$FLEET_ROOT/completions/_fleet"
    add-zsh-hook -d precmd _fleet_load_completions
    unfunction _fleet_load_completions
  }

  autoload -Uz add-zsh-hook
  if (( $+functions[compdef] )); then
    _fleet_load_completions
  else
    add-zsh-hook precmd _fleet_load_completions
  fi
fi
