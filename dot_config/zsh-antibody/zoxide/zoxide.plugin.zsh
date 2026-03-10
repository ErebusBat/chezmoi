if ! command -v zoxide >/dev/null 2>&1; then
  return
fi

export _ZO_DATA_DIR=$HOME/.config/zoxide
eval "$(zoxide init --cmd=z zsh)"
eval "$(zoxide init --cmd=cd zsh)"
alias wd=cd

