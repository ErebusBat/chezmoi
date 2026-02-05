if ! command -v aws >/dev/null 2>&1; then
  return
fi

#######################
# AWS Specific Commands
#######################


##########################
# assume Specific Commands
##########################
if ! command -v assume >/dev/null 2>&1; then
  return
fi
alias assume=". assume"
