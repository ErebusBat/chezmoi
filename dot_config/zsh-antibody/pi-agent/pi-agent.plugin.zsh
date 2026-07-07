if [[ -d ~/.pi ]]; then
  .launch-pi-agent() {
    # Export dir and make sure it exists
    export PI_CODING_AGENT_DIR=$1
    if [[ ! -d $PI_CODING_AGENT_DIR ]]; then
      echo "***FATAL: PI Agent Directory Not Found: $PI_CODING_AGENT_DIR"
      return -7
    fi

    # Unset OpenAI API Key so it doesn't auto-use it
    if [[ -n $OPENAI_API_KEY ]]; then
      unset OPENAI_API_KEY
    fi

    # Eat PI_CODING_AGENT_DIR
    shift

    # Info Display
    echo "Launching Pi ${PI_CODING_AGENT_DIR:t}"
    echo "  in $PWD"

    # Use correct node version, then launch pi
    nvm use $(< ~/.pi/.nvmrc) --silent >/dev/null && pi "${@}"
  }

  pi-personal() {
    .launch-pi-agent ~/.pi/agent-personal "${@}"
  }

  pi-work() {
    .launch-pi-agent ~/.pi/agent "${@}"
  }
fi

if command -v omp 2>&1 >/dev/null; then
  .launch-omp-agent() {
    # Export dir and make sure it exists
    export PI_CODING_AGENT_DIR=$1
    if [[ ! -d $PI_CODING_AGENT_DIR ]]; then
      echo "***FATAL: OMPI Agent Directory Not Found: $PI_CODING_AGENT_DIR"
      return -7
    fi

    # Unset OpenAI API Key so it doesn't auto-use it
    if [[ -n $OPENAI_API_KEY ]]; then
      unset OPENAI_API_KEY
    fi

    # Eat PI_CODING_AGENT_DIR
    shift

    # Info Display
    echo "Launching OmyPi ${PI_CODING_AGENT_DIR:t}"
    echo "  in $PWD"

    # Use correct node version, then launch pi
    # nvm use $(< ~/.pi/.nvmrc) --silent >/dev/null && pi "${@}"
    command omp "${@}"
  }

  omp-personal() {
    export FIRECRAWL_API_KEY=fc-884c9a9f5f254736bed1694090d9b4c1
    export BRAVE_API_KEY=BSAh8UzWZ7igfz9LmaFjJ5vtWUvUbV5
    .launch-omp-agent ~/.omp/agent-personal "${@}"
  }

  omp-work() {
    unset FIRECRAWL_API_KEY
    unset BRAVE_API_KEY
    .launch-omp-agent ~/.omp/agent-lshq "${@}"
  }
fi
