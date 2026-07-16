# cmux-notify is implemented as a standalone script at ~/bin/cmux-notify,
# which handles both local and `cmux ssh` remote sessions.

if [[ -z $CMUX_WORKSPACE_ID ]]; then
  return 0
fi

# alias cssh='cmux ssh -A'
alias cmmd='cmux markdown open'

function cssh() {
    if [[ $# -eq 0 ]]; then
      cmux ssh --help
    elif [[ $# -eq 1 ]]; then
      cmux ssh -A --name $1 $1
    else
      cmux ssh -A "${@}"
    fi
}
