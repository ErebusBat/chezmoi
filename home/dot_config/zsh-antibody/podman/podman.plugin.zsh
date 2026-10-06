[[ `which podman` =~ 'not found' ]] && return 0

if [[ -f $HOME/.local/share/containers/podman-desktop/extensions-storage/compose/bin/compose ]]; then
  # Add into the PATH the folder where docker-compose is installed
  export PATH="$PATH:/Users/andrew.burns/.local/share/containers/podman-desktop/extensions-storage/compose/bin"

  # Set the DOCKER_HOST to the socket of the podman service
  export DOCKER_HOST=unix:///Users/andrew.burns/.local/share/containers/podman/machine/qemu/podman.sock
  # export PATH=$HOME/.local/share/containers/podman-desktop/extensions-storage/compose/bin;$PATH
fi

alias docker='podman'

# When installing podman-compose via homebrew it will install a symlink to ~/bin/docker-compose
# alias docker-compose='podman compose'
alias dc='docker-compose'

# Some dup here between podman and docker :/
if [[ ! `which lazydocker` =~ 'not found' ]]; then
  alias ld=lazydocker
fi
