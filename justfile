
# Kills all GPG components
[group('gopass')]
gpg-kill-all:
  gpgconf --kill all


# Sync gopass repository
[group('gopass')]
gopass-sync:
  gopass sync
