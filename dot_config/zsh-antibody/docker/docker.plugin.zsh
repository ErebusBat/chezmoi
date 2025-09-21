[[ `which docker` =~ 'not found' ]] && return 0

alias dc='docker compose'

if [[ ! `which lazydocker` =~ 'not found' ]]; then
  alias ld=lazydocker
fi

alias dcp='docker compose pull'
alias dcpud='docker compose pull && docker compose up -d'
alias dcud='docker compose up -d'
