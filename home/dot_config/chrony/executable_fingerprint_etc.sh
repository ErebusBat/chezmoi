#!/bin/bash
fingerprintText=$(
find /etc/chrony.d -maxdepth 1 -exec sh -c '
  for item; do
    if [ -L "$item" ]; then
      target=$(readlink -f "$item")
      if [[ "$target" == $HOME* ]]; then
        target="~${target#$HOME}"
      fi
      echo "$item (symlink -> $target)"
    elif [ -d "$item" ]; then
      echo "$item (directory)"
    elif [ -f "$item" ]; then
      echo "$item (file)"
    fi
  done
' _ {} +
)

fingerprint=$(echo "$fingerprintText" | sha256sum | awk '{print $1}')
echo "# $fingerprint"
