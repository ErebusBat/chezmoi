alias assume="source assume"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

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

lshq_link_common() {
  if [[ -L ./.AAB && ! -e ./.AAB ]]; then
    local broken_target
    broken_target=$(readlink ./.AAB 2>/dev/null)
    printf '\033[33m⚠️ Broken symlink found: ./.AAB -> %s. Recreating...\033[0m\n' "${broken_target:-unknown}" >&2
    rm -f ./.AAB
  fi

  if [[ -e ./.AAB ]]; then
    echo "❌ ./.AAB already exists. Listing and dumping current contents:"
    ls -l ./.AAB 2>/dev/null
    cat ./.AAB 2>/dev/null
    return 1
  fi

  ln -s -n ~/src/lshq/AAB_COMMON ./.AAB
  ls -l ./.AAB 2>/dev/null
}

lshq_link_sprint() {
  if [[ -L ./.AAB && ! -e ./.AAB ]]; then
    local broken_target
    broken_target=$(readlink ./.AAB 2>/dev/null)
    printf '\033[33m⚠️ Broken symlink found: ./.AAB -> %s. Recreating...\033[0m\n' "${broken_target:-unknown}" >&2
    rm -f ./.AAB
  fi

  if [[ -e ./.AAB ]]; then
    echo "❌ ./.AAB already exists. Listing and dumping current contents:"
    ls -l ./.AAB 2>/dev/null
    cat ./.AAB 2>/dev/null
    return 1
  fi

  local -a matches
  local year
  year=$(date +%y)
  matches=(~/src/lshq/AAB_SPRINT_${year}*(N))
  if (( ${#matches[@]} == 0 )); then
    echo "No sprint files found in ~/src/lshq for ${year}"
    return 1
  fi

  local target
  target=${matches[-1]}
  ln -s -n "$target" ./.AAB
  ls -l ./.AAB 2>/dev/null
}

### Jenkins
if command -v jenkins &>/dev/null; then
  alias jtw='jenkins trigger --watch'
  alias jw='jenkins watch'
  alias jo='jenkins open'
fi
