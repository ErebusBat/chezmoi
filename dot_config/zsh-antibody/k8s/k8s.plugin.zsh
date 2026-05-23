if [[ `which kubectl` =~ 'not found' ]]; then return 0; fi

# source <(kubectl completion zsh)
alias k8=$(which kubectl)
alias k8s=$(which kubectl)
alias k8sunset='kubectl config unset current-context'
function k8s-set-ns() {
  kubectl config set-context --current --namespace=$1
}
