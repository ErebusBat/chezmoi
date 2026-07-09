# cmux-notify is implemented as a standalone script at ~/bin/cmux-notify,
# which handles both local and `cmux ssh` remote sessions.

if [[ -z $CMUX_WORKSPACE_ID ]]; then
  return 0
fi

alias cssh='cmux ssh'
alias cmmd='cmux markdown open'
