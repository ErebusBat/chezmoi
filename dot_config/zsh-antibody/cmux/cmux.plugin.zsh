if [[ -z $CMUX_WORKSPACE_ID ]]; then
  # Define a no-op if we don't have cmux
  function cmux-notify() {}
  return 0
fi

alias cssh='cmux ssh'
alias cmmd='cmux markdown open'

function cmux-notify() {
  local title="👀 Notification"
  local body=${1:-Task Completed}
  local msg=${2:-${PWD:t}/}

  if [[ -z $CMUX_SURFACE_ID ]]; then
    # Interesting, we had CMUX when we were sourced, but do not right now.
    return 0
  fi

  if ! command -v cmux 2>&1 >/dev/null; then
    # Even curiouser, we had Cmux when we were sourced, and we have a surface ID, but we do not have the command.
    echo "*** WARN⁉️: cmux not available?!?"
    return 0
  fi

  cmux notify \
    --title "$title" \
    --subtitle "$msg" \
    --body "$body" \
    --surface $CMUX_SURFACE_ID
}
