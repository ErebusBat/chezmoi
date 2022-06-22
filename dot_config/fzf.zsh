# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

BINDING_FILE=~/.config/zsh-antibody/fzf-bindings.zsh
[[ -f $BINDING_FILE ]] || BINDING_FILE=~/.config/fzf-bindings.zsh
[[ -f $BINDING_FILE ]] || BINDING_FILE=/usr/share/doc/fzf/examples/key-bindings.zsh
[[ -f $BINDING_FILE ]] || BINDING_FILE=/usr/local/opt/fzf/shell/completion.zsh

if [[ -f $BINDING_FILE ]]; then
  # Auto-completion
  # ---------------
  [[ $- == *i* ]] && source $BINDING_FILE 2> /dev/null

  # Key bindings
  # ------------
  source $BINDING_FILE
fi

unset BINDING_FILE
