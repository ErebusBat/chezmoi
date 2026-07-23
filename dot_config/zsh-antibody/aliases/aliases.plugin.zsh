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

function dpsu() {
  local script
  local -a script_paths=(
    "$HOME/src/erebusbat/myserver/docker-out-of-date"
    "/myserver/docker-out-of-date"
    "$HOME/bin/docker-out-of-date"
  )

  for script in "${script_paths[@]}"; do
    if [[ -x "$script" ]]; then
      "$script" "$@"
      return $?
    fi
  done

  print -u2 "dpsu: no executable found in: ${script_paths[*]}"
  return 127
}

function dcpsu() {
  local script
  local -a script_paths=(
    "$HOME/src/erebusbat/myserver/docker-compose-out-of-date"
    "/myserver/docker-compose-out-of-date"
    "$HOME/bin/docker-compose-out-of-date"
  )

  for script in "${script_paths[@]}"; do
    if [[ -x "$script" ]]; then
      "$script" "$@"
      return $?
    fi
  done

  print -u2 "dcpsu: no executable found in: ${script_paths[*]}"
  return 127
}

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

function mkcd() {
  if [[ -z $1 ]]; then
    echo "ERROR: Specify path"
  elif [[ -d $1 ]]; then
    echo "Folder $1 already exists"
    cd $1
  else
    mkdir $1 && cd $1
  fi
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

################################################################################
# Sudo Helpers
################################################################################
# if [[ -x $(which rg) ]]; then
  # alias rgh="$(which rg) --hidden"
# fi
if command -v rg >/dev/null 2>&1; then
  alias surg="sudo -E $(command -v rg)"
fi
if command -v nvim >/dev/null 2>&1; then
  alias sunvim="sudo -E $(command -v nvim)"
  alias suvim=sunvim
fi

# function sudovim() {
#   sudo HOME=$HOME PATH=$PATH $(which nvim) "$@"
# }

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
  alias vicz='vim ~/.config/chezmoi/chezmoi.toml'
  alias cz='chezmoi'
  alias czu='chezmoi update'
  alias czs='chezmoi status'
  alias czfu='command just -f ~/.local/share/chezmoi/justfile chezmoi-full-update'

  function chezmoi-diff() {
    if [[ $# -eq 0 ]]; then
      command chezmoi diff
      return $?
    elif [[ $# -eq 1 ]]; then
      local dpath=$1
      if [[ $dpath == ${dpath:a} ]]; then
        command chezmoi diff $dpath
      else
        command chezmoi diff ~/$dpath
      fi
      return $?
    fi
    command chezmoi diff "$@"
  }
  alias czd=chezmoi-diff

  function chezmoi-add {
    local processed_paths=()
    local p

    for p in "$@"; do
        # Expand tilde if present
        p="${~p}"

        if [[ $p == ${p:a} ]]; then
            processed_paths+=("$p")
        else
            processed_paths+=("$HOME/$p")
        fi
    done

    if [[ ${#processed_paths[@]} -le 0 ]]; then
      echo "*** ERROR: No paths specified" >&2
      return 1
    fi
    command chezmoi add "${processed_paths[@]}"
  }
  alias czadd=chezmoi-add

  function chezmoi-apply() {
    local processed_paths=()
    local p

    for p in "$@"; do
        # Expand tilde if present
        p="${~p}"

        if [[ $p == ${p:a} ]]; then
            processed_paths+=("$p")
        else
            processed_paths+=("$HOME/$p")
        fi
    done

    if [[ ${#processed_paths[@]} -le 0 ]]; then
      echo "*** ERROR: No paths specified" >&2
      echo "         : Use 'chezmoi apply' directly" >&2
      return 1
    fi
    chezmoi apply "${processed_paths[@]}"
  }
  alias czapply=chezmoi-apply
fi

################################################################################
# Network
################################################################################
alias homeip="dig +short cpr.erebusbat.net @ns1.digitalocean.com"
alias digs="dig +short"

# Cisco Console command, needs adapter attached
# alias con="screen -c ~/.screenrcUSB"

if [[ -x ~/.ssh/reload-ssh-agent ]]; then
  alias reload-ssh-agent='echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"; eval $(~/.ssh/reload-ssh-agent); echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"'
fi

# assh https://github.com/moul/assh
if [[ -x $(which assh) ]]; then
  # Wiring layer: run ssh via assh and register which completion function ssh uses.
  ssh() {
    command assh wrapper ssh -- "$@"
  }

  if [[ -o interactive ]]; then
    _assh_ssh_completion_init() {
      if ! (( $+functions[compdef] && $+functions[_main_complete] && $+parameters[_comps] )); then
        return
      fi

      autoload -Uz _ssh_assh_hosts
      compdef _ssh_assh_hosts ssh
      add-zsh-hook -d precmd _assh_ssh_completion_init
      unfunction _assh_ssh_completion_init
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook -d precmd _assh_ssh_completion_init 2>/dev/null
    add-zsh-hook precmd _assh_ssh_completion_init
  fi
fi

if [[ -d ~/.local/bin ]]; then
  if [[ -f ~/.local/bin/env ]] then
    . ~/.local/bin/env
  else
    export PATH=$PATH:$HOME/.local/bin
  fi
fi

################################################################################
# Development Aliases
################################################################################

# System Commands
alias mounts="mount | grep -vE '^(cgroup2? on|sysfs on|proc on|udev on|devpts on|securityfs on|pstore on|efivars on|\/var\/lib\/|\/dev\/nvme0n1)'"

# Glow - Markdown Reader
if command -v glow >/dev/null 2>&1; then
  alias glowp='glow -p'
  alias glowt='glow -t'
fi

if [[ -d /Applications/MarkText.app ]]; then
  alias mdview='open -a MarkText'
fi


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
  # Don't register an alias if we don't have the command in scope
  if command -v >/dev/null 2>&1; then
    alias $cmd="sudo -E $cmd"
  fi
done
unset SUDO_CMDS

################################################################################
# OSX Commands
################################################################################
if [[ "$(uname)" == "Darwin" ]]; then
  alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale
fi
