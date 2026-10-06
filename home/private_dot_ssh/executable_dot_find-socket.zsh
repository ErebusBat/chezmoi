#!/usr/bin/env zsh
set -euo pipefail

info() {
  printf 'reload-ssh-agent[INFO]: %s\n' "$1" >&2
}
warn() {
  printf 'reload-ssh-agent[WARN]: %s\n' "$1" >&2
}
error() {
  printf 'reload-ssh-agent[ ERR]: %s\n' "$1" >&2
}
dbug() {
  printf 'reload-ssh-agent[DBUG]: %s\n' "$1" >&2
}
fatal() {
  local theec=${2:-1}
  printf 'reload-ssh-agent[FATAL]: %s\n' "$1" >&2
  printf '%s\n' 'false'
  exit $theec
}

function test-ssh-sock() {
  local sock_path=$1

  # Never emit a path that could inject into the eval'd export line.
  case "$sock_path" in
    *[!A-Za-z0-9_./-]*)
      error "Unsafe socket path: $sock_path"
      return 1
      ;;
  esac

  if [[ ! -S $sock_path ]]; then
    error "Not a socket: $sock_path"
    return 1
  fi

  # ssh-add -l exit codes: 0 = agent has identities, 1 = agent reachable but
  # holds no identities, 2 = cannot connect. Only >=2 means the agent is dead.
  local theec=0
  SSH_AUTH_SOCK=$sock_path command ssh-add -l >/dev/null 2>&1 || theec=$?
  if (( theec >= 2 )); then
    error "Agent not answering on: $sock_path (ssh-add exit $theec)"
    return 1
  fi
  return 0
}

socket=''
SOCKET_CANDIDATES=()
os=$(uname -s 2>/dev/null) || fatal 'unable to determine the operating system'

case "$os" in
  Darwin)
    socket=$(/bin/launchctl getenv SSH_AUTH_SOCK 2>/dev/null) || socket=''

    if [[ ! -S ${socket:-} && -n ${SSH_AUTH_SOCK:-} && -S $SSH_AUTH_SOCK ]]; then
      socket=$SSH_AUTH_SOCK
    fi

    if [[ -n $socket ]]; then
      SOCKET_CANDIDATES+=("$socket")
    fi
    ;;
  Linux)
    # Prefer the inherited SSH_AUTH_SOCK when it points at a socket; the probe
    # below still rejects it if the agent behind it is dead (stale sockets are
    # the common case after ssh -A disconnects).
    if [[ -n ${SSH_AUTH_SOCK:-} && -S $SSH_AUTH_SOCK ]]; then
      SOCKET_CANDIDATES+=("$SSH_AUTH_SOCK")
    fi

    if command -v systemctl >/dev/null 2>&1; then
      systemctl_sock=$(systemctl --user show-environment 2>/dev/null | sed -n 's/^SSH_AUTH_SOCK=//p' | head -n 1) || systemctl_sock=''
      if [[ -n $systemctl_sock && -S $systemctl_sock ]]; then
        SOCKET_CANDIDATES+=("$systemctl_sock")
      fi
    fi

    if [[ -n ${XDG_RUNTIME_DIR:-} ]]; then
      for candidate in \
        "$XDG_RUNTIME_DIR/ssh-agent.socket" \
        "$XDG_RUNTIME_DIR/ssh-agent" \
        "$XDG_RUNTIME_DIR/keyring/ssh" \
        "$XDG_RUNTIME_DIR/gcr/ssh" \
        "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
      do
        if [[ -S $candidate ]]; then
          SOCKET_CANDIDATES+=("$candidate")
        fi
      done
    fi

    SOCKET_CANDIDATES+=(/tmp/ssh*/agent.*(N))
    ;;
  *)
    fatal "I don't know how to handle $os"
    ;;
esac

# Deduplicate while preserving probe order (e.g. SSH_AUTH_SOCK often equals the
# systemctl value).
SOCKET_CANDIDATES=(${(u)SOCKET_CANDIDATES[@]})

if (( ${#SOCKET_CANDIDATES[@]} == 0 )); then
  fatal "Couldn't find any candidate sockets for $os" 2
fi

for sk in "${SOCKET_CANDIDATES[@]}"; do
  if test-ssh-sock "$sk"; then
    info "Using SSH agent socket: $sk"
    printf 'export SSH_AUTH_SOCK=%s\n' "$sk"
    exit 0
  fi
done

fatal "No working SSH agent socket found" 7
