#!/bin/zsh

# There is a race condition / personal/server issue with this
# It just needs to exist or chezmoi will fail
if [[ ! -f $HOME/.config/zsh-antibody/setec-astronomy/setec-astronomy.plugin.zsh ]] && [[ -d $HOME/.config/zsh-antibody/setec-astronomy ]]; then
  touch $HOME/.config/zsh-antibody/setec-astronomy/setec-astronomy.plugin.zsh
fi
