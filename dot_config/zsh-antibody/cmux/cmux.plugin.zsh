# vim: set ft=zsh ts=2 sw=2 sts=2 et ai si sta:

# cmux-notify is implemented as a standalone script at ~/bin/cmux-notify,
# which handles both local and `cmux ssh` remote sessions.

if [[ -z $CMUX_WORKSPACE_ID ]]; then
  return 0
fi

# alias cssh='cmux ssh -A'
alias cmmd='cmux markdown open'

function cssh() {
  if [[ -x ~/.ssh/cmux-ssh ]]; then
    ~/.ssh/cmux-ssh "${@}"
  elif [[ $# -eq 0 ]]; then
    cmux ssh --help
  elif [[ $# -eq 1 ]]; then
    cmux ssh -A --name $1 $1
  else
    cmux ssh -A "${@}"
  fi
}
