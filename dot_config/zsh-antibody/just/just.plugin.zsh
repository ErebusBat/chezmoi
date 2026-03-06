if ! command -v just >/dev/null 2>&1; then
  return
fi

alias j='just'
alias jc='just --choose'

if [[ -o interactive ]]; then
  _just_load_completions() {
    source <(just --completions zsh)
    if (( $+functions[compdef] )); then
      compdef _just just j jc
    fi
    add-zsh-hook -d precmd _just_load_completions
    unfunction _just_load_completions
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _just_load_completions
fi
