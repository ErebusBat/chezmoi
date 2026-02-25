alias assume="source assume"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# lskt-onboard: fzf
source <(fzf --zsh)

# lskt-onboard: kubectl-krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# lskt-onboard: brew shellenv - cache output to avoid ~50ms fork on every startup
_brew_shellenv_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/brew-shellenv.zsh"
if [[ ! -f "$_brew_shellenv_cache" || /opt/homebrew/bin/brew -nt "$_brew_shellenv_cache" ]]; then
  mkdir -p "${_brew_shellenv_cache:h}"
  /opt/homebrew/bin/brew shellenv >| "$_brew_shellenv_cache"
fi
source "$_brew_shellenv_cache"
unset _brew_shellenv_cache

# lskt-onboard: pyenv -- lazy-load to avoid ~212ms fork on every startup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

_pyenv_load() {
  unfunction pyenv 2>/dev/null
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  pyenv "$@"
}
if (( $+commands[pyenv] )); then
  function pyenv() { _pyenv_load "$@" }
fi

