if ! command -v just >/dev/null 2>&1; then
  return
fi

# Aliases
alias j='just'
alias jc='just --choose'
alias jls='just --list'
alias jl=jls

# TAB Completions
if [[ -o interactive ]]; then
  _just_load_completions() {
    source <(just --completions zsh)
    if (( $+functions[compdef] )); then
      local _just_completer=${_comps[just]-}
      if [[ -n $_just_completer ]]; then
        compdef "$_just_completer" just j jc
      fi
    fi
    add-zsh-hook -d precmd _just_load_completions
    unfunction _just_load_completions
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _just_load_completions
fi
