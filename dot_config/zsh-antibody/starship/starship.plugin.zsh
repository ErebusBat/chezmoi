# See https://starship.rs/guide/
_starship_path_context() {
  case "${PWD:A}" in
    "${HOME:A}/src/lshq"|"${HOME:A}/src/lshq"/*)
      export STARSHIP_K8S=1
      ;;
    *)
      unset STARSHIP_K8S
      ;;
  esac
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _starship_path_context
_starship_path_context

if [[ -x /opt/homebrew/bin/starship ]]; then
  eval "$( /opt/homebrew/bin/starship init zsh)"
else
  # starship_path=$(mise which starship)
  # echo "Attempting to use $starship_path"
  # eval "$( $starship_path init zsh)"
  eval "$( starship init zsh)"
fi
