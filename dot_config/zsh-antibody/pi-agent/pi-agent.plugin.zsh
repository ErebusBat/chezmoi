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
  # .launch-omp-agent() {
  #   # Export dir and make sure it exists
  #   export PI_CODING_AGENT_DIR=$1
  #   if [[ ! -d $PI_CODING_AGENT_DIR ]]; then
  #     echo "***FATAL: OMPI Agent Directory Not Found: $PI_CODING_AGENT_DIR"
  #     return -7
  #   fi
  #
  #   # Unset OpenAI API Key so it doesn't auto-use it
  #   if [[ -n $OPENAI_API_KEY ]]; then
  #     unset OPENAI_API_KEY
  #   fi
  #
  #   # Eat PI_CODING_AGENT_DIR
  #   shift
  #
  #   # Info Display
  #   echo "Launching OmyPi ${PI_CODING_AGENT_DIR:t}"
  #   echo "  in $PWD"
  #
  #   # Use correct node version, then launch pi
  #   # nvm use $(< ~/.pi/.nvmrc) --silent >/dev/null && pi "${@}"
  #   command omp "${@}"
  # }

  omp-personal() {
    if [[ -f ~/.config/erebusbat/agent-personal-api-keys.sh ]]; then
      source ~/.config/erebusbat/agent-personal-api-keys.sh
    fi
    command omp --profile=personal "${@}"
  }

  omp-work() {
    unset FIRECRAWL_API_KEY
    unset BRAVE_API_KEY
    command omp --profile=upserve "${@}"
  }
fi
