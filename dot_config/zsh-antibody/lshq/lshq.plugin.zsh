alias assume="source assume"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
# lskt-onboard: fzf
source <(fzf --zsh)
# lskt-onboard: kubectl-krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# lskt-onboard: pyenv -- begin
eval "$(/opt/homebrew/bin/brew shellenv)"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# lskt-onboard: pyenv -- end
# lskt-onboard: pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"
