if [[ -d /opt/homebrew/opt/python@3.13/libexec/bin ]]; then
  export PATH=/opt/homebrew/opt/python@3.13/libexec/bin:$PATH
fi

if [[ -d $HOME/.local/bin ]]; then
  export PATH=$HOME/.local/bin:$PATH
fi
