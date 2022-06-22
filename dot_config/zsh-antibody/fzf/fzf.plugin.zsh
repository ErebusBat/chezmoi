if [[ `type fzf` =~ 'not found' ]]; then return 0; fi

[ -f ~/.config/fzf.zsh ] && source ~/.config/fzf.zsh

if [[ `type fd` =~ 'fd is' ]]; then
  export FZF_DEFAULT_COMMAND='fd --type f'
  #
  # FZF ZSH Commands
  #   CTRL-R - Search History
  #   CTRL-T - Search Files
  #   CTRL-H - --- can not use ---
  #   CTRL-N - Search Files+Hidden
  #   CTRL-D - Search Directories
  #   CTRL-F - Search Directories+Hidden
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_G_COMMAND="git diff master..HEAD --name-only"
  export FZF_CTRL_N_COMMAND="$FZF_DEFAULT_COMMAND --hidden"
  export FZF_CTRL_D_COMMAND="fd --type d"
  export FZF_CTRL_F_COMMAND="fd --type d --hidden --exclude=.git"
fi

if [[ -n $FZF_CTRL_G_COMMAND ]]; then
  # My own fsel, adapted from original fzf-bindings
  __fsel-aab() {
    local cmd="${FZF_AAB_CMD:-"fd"}"
    setopt localoptions pipefail no_aliases 2> /dev/null
    eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
      echo -n "${(q)item} "
    done
    local ret=$?
    echo
    return $ret
  }

  # CTRL-N = CTRL-T + Hidden (Find [hidden] files)
  fzf-file-widget-hidden() {
    export FZF_AAB_CMD=$FZF_CTRL_N_COMMAND
    LBUFFER="${LBUFFER}$(__fsel-aab)"
    local ret=$?
    zle reset-prompt
    return $ret
  }
  zle     -N   fzf-file-widget-hidden
  bindkey '^N' fzf-file-widget-hidden

  # CTRL-G = Find git changes files on branch
  fzf-git-widget-hidden() {
    export FZF_AAB_CMD=$FZF_CTRL_G_COMMAND
    LBUFFER="${LBUFFER}$(__fsel-aab)"
    local ret=$?
    zle reset-prompt
    return $ret
  }
  zle     -N   fzf-git-widget-hidden
  bindkey '^G' fzf-git-widget-hidden

  # CTRL-D = Find Dirs
  fzf-file-widget-dirs() {
    export FZF_AAB_CMD=$FZF_CTRL_D_COMMAND
    LBUFFER="${LBUFFER}$(__fsel-aab)"
    local ret=$?
    zle reset-prompt
    return $ret
  }
  zle     -N   fzf-file-widget-dirs
  bindkey '^D' fzf-file-widget-dirs

  # CTRL-F = Find Dirs + hidden
  fzf-file-widget-dirs-hidden() {
    export FZF_AAB_CMD=$FZF_CTRL_F_COMMAND
    LBUFFER="${LBUFFER}$(__fsel-aab)"
    local ret=$?
    zle reset-prompt
    return $ret
  }
  zle     -N   fzf-file-widget-dirs-hidden
  bindkey '^F' fzf-file-widget-dirs-hidden
fi
