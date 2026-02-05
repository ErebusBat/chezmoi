export OPENCLAW_PATH=$HOME/src/erebusbat/myserver/batbot
if [[ ! -f $OPENCLAW_PATH/docker-compose.yml ]]; then
  echo "NO OPENCLAW"
  exit 0
fi

echo "OPENCLAW FOUND!"

openclaw() {
  docker compose -f /docker-compose.yml \
    exec gateway openclaw "$@"
}

# Load OpenClaw completion (only in interactive shells)
if [[ -o interactive ]] && command -v openclaw &>/dev/null; then
  source <(openclaw completion --shell zsh)
fi

