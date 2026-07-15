import? '.git-remote.just'
CHEZMOI_LOCAL_DIR := home_dir() / '.local/share/chezmoi'

# Kills all GPG components
[group('gopass')]
gpg-kill-all:
    gpgconf --kill all

# Sync gopass repository
[group('gopass')]
[group('update')]
gopass-sync:
    gopass sync

# Run Chezmoi Update
[group('update')]
chezmoi-update:
    command chezmoi update

chezmoi-init-config:
    command chezmoi init

# Pull chezmoi changes, sync gopass database, re-init config, and run chezmoi update
[group('update')]
chezmoi-full-update:
    cd {{ CHEZMOI_LOCAL_DIR }} && git pull
    gopass sync
    just --justfile {{ source_file() }} chezmoi-init-config chezmoi-update
