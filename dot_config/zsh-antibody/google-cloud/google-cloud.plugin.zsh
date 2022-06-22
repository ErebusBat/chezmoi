xPATHS=(
  /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
  /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
  ~/google-cloud-sdk/completion.zsh.inc
  ~/google-cloud-sdk/path.zsh.inc
)
for p in $xPATHS; do
  if [[ -f $p ]]; then
    source $p
  fi
done
unset xPATHS

alias gcomp='gcloud compute'
alias gssh='gcloud compute ssh'
alias gscp='gcloud compute scp'
alias ginst='gcloud compute instances'
alias gserial-out='gcloud compute instances get-serial-port-output'
alias gserial-tail='gcloud compute instances tail-serial-port-output'
