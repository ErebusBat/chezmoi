[[ `which docker` =~ 'not found' ]] && return 0

alias dc='docker compose'

if [[ ! `which lazydocker` =~ 'not found' ]]; then
  alias ld=lazydocker
fi

alias dcp='docker compose pull'
alias dcpud='docker compose pull && docker compose up -d'
alias dcud='docker compose up -d'
# alias dvdu='docker volume ls -q | xargs -I {} sh -c '\''echo "$(sudo du -sh /var/lib/docker/volumes/{}/_data | cut -f1)\t {}"'\'''

# Docker Volume NCDU
alias dvncdu='sudo ncdu /var/lib/docker/volumes'

# Docker Volume Disk Usage
function dvdu() {
  docker volume ls -q | while read -r vol; do
    # 1. Check if the volume has the 'cifs' type in its options
    # We inspect the JSON format for the .Options.type field
    mount_type=$(docker volume inspect "$vol" --format '{{ .Options.type }}')

    if [ "$mount_type" = "cifs" ]; then
      # It is a CIFS mount, set size to CIFS explicitly
      size="CIFS"
    else
      # Standard volume: Show progress, then run du
      printf "Calculating: %s\r" "$vol"

      # Run du and capture output
      size=$(sudo du -sh "/var/lib/docker/volumes/${vol}/_data" 2>/dev/null | cut -f1)

      # Clear the progress line
      printf "\r\033[K"
    fi

    # 2. Output the final formatted result: SIZE <TAB> VOLUME
    printf "%s\t%s\n" "$size" "$vol"
  done
}
