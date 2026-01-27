# if [[ -d /opt/homebrew/opt/python@3.13/libexec/bin ]]; then
#   export PATH=/opt/homebrew/opt/python@3.13/libexec/bin:$PATH
# fi
if [[ ! -x $(which pyenv) ]]; then return 0; fi

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
