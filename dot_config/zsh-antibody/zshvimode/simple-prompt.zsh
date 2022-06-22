
function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
    # echo "zle-line-init V>${VIM_PROMPT}< RPS1>$RPS1<" >&2
    # LP_PS1_PREFIX="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
    # LP_PS1_POSTFIX="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
