# TERM workaround
if [[ -n "$SSH_CONNECTION" ]] || [[ -n "$SSH_CLIENT" ]]; then
  if [[ $TERM == "xterm-ghostty" ]]; then
    export TERM=xterm-256color
  fi
fi

if [[ ! -d $GHOSTTY_RESOURCES_DIR ]]; then return 0; fi

source ${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration
