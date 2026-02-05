export OPENCLAW_PATH=$HOME/src/erebusbat/myserver/batbot
if [[ ! -f $OPENCLAW_PATH/docker-compose.yml ]]; then
  exit 0
fi

openclaw() {
  docker compose -f $OPENCLAW_PATH/docker-compose.yml \
    exec gateway openclaw "$@"
}

# Load OpenClaw completion (only in interactive shells)
# This is broke af AND very very slow
# if [[ -o interactive ]] && command -v openclaw &>/dev/null; then
#   source <(openclaw completion --shell zsh)
# fi

