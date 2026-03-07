if ! command -v wt >/dev/null 2>&1; then
  return
fi

if [[ -o interactive ]]; then
  _wt_load_completions() {
    if ! (( $+functions[compdef] )); then
      return
    fi

    eval "$(command wt config shell init zsh)"
    add-zsh-hook -d precmd _wt_load_completions
    unfunction _wt_load_completions
  }

  autoload -Uz add-zsh-hook
  if (( $+functions[compdef] )); then
    _wt_load_completions
  else
    add-zsh-hook precmd _wt_load_completions
  fi
fi
