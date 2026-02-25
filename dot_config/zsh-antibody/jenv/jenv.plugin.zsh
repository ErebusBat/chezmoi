if [[ ! -x $(which jenv) ]]; then return 0; fi

# Add jenv shims to PATH immediately without running the slow `jenv init -`
export PATH="$HOME/.jenv/shims:$HOME/.jenv/bin:$PATH"
export JENV_LOADED=1

# Lazy-load full jenv init (hooks, completions) on first use
_jenv_load() {
  unfunction jenv 2>/dev/null
  eval "$(jenv init -)"
  jenv "$@"
}
jenv() { _jenv_load "$@" }
