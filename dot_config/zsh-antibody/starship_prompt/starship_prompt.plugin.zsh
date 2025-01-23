# See https://starship.rs/guide/
if [[ -x /opt/homebrew/bin/starship ]]; then
  eval "$( /opt/homebrew/bin/starship init zsh)"
else
  eval "$( starship init zsh)"
fi
