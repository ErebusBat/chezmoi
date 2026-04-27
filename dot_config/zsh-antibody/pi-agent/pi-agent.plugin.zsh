if [[ ! -d ~/.pi ]]; then
  return
fi

.launch-pi-agent() {
  # Export dir and make sure it exists
  export PI_CODING_AGENT_DIR=$1
  if [[ ! -d $PI_CODING_AGENT_DIR ]]; then
    echo "***FATAL: PI Agent Directory Not Found: $PI_CODING_AGENT_DIR"
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
