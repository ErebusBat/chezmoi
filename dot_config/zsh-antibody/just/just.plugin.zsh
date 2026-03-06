if ! command -v just >/dev/null 2>&1; then
  return
fi

alias j='just'
alias jc='just --choose'

