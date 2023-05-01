####################
# General Commands
####################

alias cls=clear
alias df="df -h"
alias du="du -h"
alias hgrep='history 0 | grep'
alias h='history 0 | tail -50'

alias cp='cp -v'
alias mv='mv -v'

function todo() {
  local projID=377155580 # Inbox
  local task=$1
  local date=$2

  if [[ -n $date ]]; then
    if [[ "$date" == "t" ]]; then
      date="today"
    fi
    dateOpt=("-d" "$date")
  else
    dateOpt=""
  fi

  echo "Adding '$task' to Inbox $dateOpt..."
  todoist add -P $projID $dateOpt "$task"
}

# todo today
# function todot() {
#   todo "$1" t
# }

if [[ -d ~/Library/Python/3.9/bin ]]; then
  export PATH=~/Library/Python/3.9/bin:$PATH
fi

if [[ -f ~/.config/wezterm/wezterm.lua ]]; then
  alias viwezterm='vim ~/.config/wezterm/wezterm.lua ~/.config/wezterm/wallpaper.yaml && ~/.config/wezterm/build-wallpapers.rb'
fi
if [[ -f ~/.config/chezmoi/chezmoi.toml ]]; then
  alias vicz='vim ~/.config/chezmoi/chezmoi.toml'
fi
if [[ -x ~/.restic/restic-multi.rb ]]; then
  alias restic-multi="$HOME/.restic/restic-multi.rb"
fi

################################################################################
# Editing / Navigation / File Management
################################################################################
if [[ -x $(which bat) ]]; then
  alias cat=$(which bat)
fi
alias tf="tail -n50 -f"

if [[ -x $(which nvim) ]]; then
  export EDITOR=nvim
  alias vim=nvim
fi

alias vicolors="vim -S ~/.config/nvim/s_colors.vim"

# This captures CTRL in the window you started it in :/
# if [[ -x $(which gnvim) ]]; then
#   _gnvim="$(which gnvim)"
#   function gnvim() {
#     $_gnvim $* 2> /dev/null &
#   }
# fi

if [[ -x $(which rg) ]]; then
  alias rgh="$(which rg) --hidden"
fi

################################################################################
# System Utilities
################################################################################
if [[ -x $(which xclip) ]]; then
  alias pbpaste='xclip -selection c -o'
  alias pbcopy='xclip -selection c'
fi

if [[ $(uname) == "Linux" ]]; then
  alias o=xdg-open
  alias syscu='systemctl --user'
  alias syscudr='systemctl --user daemon-reload'
fi

if [[ -x $(which chezmoi) ]]; then
  alias cz=chezmoi
fi

################################################################################
# Network
################################################################################
alias homeip="dig +short cpr.erebusbat.net @ns1.digitalocean.com"
alias digs="dig +short"

# Cisco Console command, needs adapter attached
# alias con="screen -c ~/.screenrcUSB"

# assh https://github.com/moul/assh
if [[ -x $(which assh) ]]; then
  alias ssh="assh wrapper ssh --"
fi

if [[ -d ~/.local/bin ]]; then
  export PATH=$PATH:$HOME/.local/bin
fi

################################################################################
# Development Aliases
################################################################################
alias be="bundle exec"
alias guard="bundle exec guard"
alias rails="bundle exec rails"
alias rake="bundle exec rake"
alias rspec="rbenv exec rspec"
alias rspecd="rbenv exec rspec -f d"

# System Commands
alias mounts="mount | grep -vE '^(cgroup2? on|sysfs on|proc on|udev on|devpts on|securityfs on|pstore on|efivars on|\/var\/lib\/|\/dev\/nvme0n1)'"


################################################################################
# Commands that should/want to always run as sudo
################################################################################
SUDO_CMDS=(
  cryptsetup
  dmesg
  mount
  poweroff
  powertop
  reboot
  shutdown
)
for cmd in $SUDO_CMDS; do
  alias $cmd="sudo $cmd"
done
unset SUDO_CMDS

################################################################################
# OSX Commands
################################################################################
if [[ "$(uname)" == "Darwin" ]]; then
  alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale
fi
