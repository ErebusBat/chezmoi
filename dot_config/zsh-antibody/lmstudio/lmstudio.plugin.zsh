if [[ ! -x ~/.lmstudio/bin/lms ]]; then
  return
fi

alias lms=~/.lmstudio/bin/lms
alias lms-dict-up="just --justfile=$HOME/.lmstudio/justfile load-dictation"
alias lms-dict-down="just --justfile=$HOME/.lmstudio/justfile unload-dictation"
