################################################################################
### On linux fd is in the fd-find packages and is called fdfind
################################################################################
if [[ $(uname) == "Linux" ]]; then
  if ! command -v fdfind >/dev/null 2>&1; then
    return
  fi

  if [[ -h $HOME/bin/fd ]]; then   # Symlink
    # fd is already a symlink (-h) don't do anything
    return
  elif [[ -f $HOME/bin/fd ]]; then # File
    echo "***WARN: Found fdfind on system, but ~/bin/fd exists!"
    return
  fi

  # Create symlink to fdfind
  ln -s $(which fdfind) $HOME/bin/fd
fi

if ! command -v fd >/dev/null 2>&1; then
  return
fi

# Add a sudo wrapper
alias sufd="sudo -E $(command -v fd)"
