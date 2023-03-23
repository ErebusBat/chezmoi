[[ `which docker` =~ 'not found' ]] && return 0

alias dc='docker compose'

if [[ ! `which lazydocker` =~ 'not found' ]]; then
  alias ld=lazydocker
fi
