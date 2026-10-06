bindkey -v

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# http://stratus3d.com/blog/2017/10/26/better-vi-mode-in-zshell/
bindkey -M vicmd "^V" edit-command-line

# Do not change prompt if we are using a prompt that already handles this
# if [[ -n $SPACESHIP_ROOT ]]; then
#   function zle-line-init zle-keymap-select {
#       VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
#       RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
#       # echo "zle-line-init V>${VIM_PROMPT}< RPS1>$RPS1<" >&2
#       # LP_PS1_PREFIX="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
#       # LP_PS1_POSTFIX="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
#       zle reset-prompt
#   }

#   zle -N zle-line-init
#   zle -N zle-keymap-select
# fi
export KEYTIMEOUT=1
