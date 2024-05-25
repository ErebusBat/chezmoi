if [[ `which kubectl` =~ 'not found' ]]; then return 0; fi

# source <(kubectl completion zsh)
alias k8=$(which kubectl)
alias ksunset='kubectl config unset current-context'
