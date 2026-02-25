if ! command -v opencode >/dev/null 2>&1; then
  return
fi

alias oc="opencode"

# Load opencode completions (only in interactive shells)
# Defer until after compinit has run by using a precmd hook
if [[ -o interactive ]]; then
  _opencode_load_completions() {
    source <(opencode completion)
    add-zsh-hook -d precmd _opencode_load_completions
    unfunction _opencode_load_completions
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _opencode_load_completions
fi
