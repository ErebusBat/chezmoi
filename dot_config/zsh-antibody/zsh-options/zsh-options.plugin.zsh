# Don't share history between windows
# setopt no_share_history

# Disable CTRL+D closing session
setopt IGNORE_EOF

# Allow things like for f in *.{jpg,jpeg} where there are no *.jpeg files
setopt cshnullglob

######################################################################################################
## History
######################################################################################################
# Stole from https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh
### There were massive problems before this... and we know these options work.
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_all_dups
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_find_no_dups
setopt hist_save_no_dups
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
### End History

# Disable terminal "alternate scrolling"
#    https://github.com/alacritty/alacritty/issues/4583
printf '\x1b[?1007l'

# Disable Software Flow Ctrl (CTRL-S)
# stty -ixon
setopt noflowcontrol
