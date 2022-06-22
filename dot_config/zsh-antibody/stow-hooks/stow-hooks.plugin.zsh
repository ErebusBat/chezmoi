[[ -z $HOOKS_PATH ]] && HOOKS_PATH=$HOME/.config/zsh-hooks
if [[ ! -d $HOOKS_PATH ]]; then return 0; fi

#
# This ZSH plugin allows other stow packages to easily include ZSH startup
# hooks that don't have to be in the main zsh-antibody package.
#
# WARNING: Scripts included in this way are NOT statically compiled meaning:
#          1) You do not need to perform an antibody `make static` to pick them up
#          2) They will generally be slower (so a full plugin might make sense sometimes)
#

# This is probably going to change the entire shell?  How to preserve it?
# setopt +o nullglob
setopt +o nomatch

for hook in $HOOKS_PATH/*.{sh,zsh}; do
  [[ ! -f $hook ]] && continue            # zsh will pass the literal *.sh (if no match) so make sure $hook is an actual file
  source $hook
done
