# vim: set ft=just ts=4 sw=4 sts=4 et ai si sta:
APP_SUPPORT := home_dir() / 'Library/Application Support'
MOSHI_APP_SUPPORT := APP_SUPPORT / 'Moshi'

# List Moshi Tasks
[group('Help')]
ls-moshi:
    just --group 'Moshi' --list

# Install moshi and prerequisites
[group('Moshi')]
moshi-install:
    curl -fsSL https://getmoshi.app/install.sh | sh
    sudo apt install mosh
    just -f ~/.config/herdr/justfile install

# Start linking process
[group('Moshi')]
moshi-setup-host:
    moshi-hook host setup

# Show status
[group('Moshi')]
moshi-status:
    moshi-hook status

# Tail Moshi Hook Log
[group('Moshi')]
moshi-hook-log-tail *args='-f':
    tail {{ args }} "{{ MOSHI_APP_SUPPORT }}/hook.log"

# Install (symlink) moshi hook to given profile
[group('Moshi')]
moshi-install-omp-hook profile='personal':
    #!/usr/bin/env zsh
    MOSHI_HOOK_SRC=~/.omp/agent/extensions/moshi-hooks.ts
    OMP_PROFILE="{{ profile }}"
    AGENT_DIR=$(printf "{{ TEMPLATE_AGENT_DIR }}" "{{ profile }}")

    if [[ ! -s $MOSHI_HOOK_SRC ]]; then
        echo "*** FATAL: Moshi hook extension not found!"
        echo "         : $MOSHI_HOOK_SRC"
        exit 1
    fi

    if [[ ! -d $AGENT_DIR ]]; then
        echo "*** FATAL: Path not found: $AGENT_DIR"
        exit 1
    fi
    EXT_DIR="${AGENT_DIR}/extensions"
    [[ -d $EXT_DIR ]] || mkdir -p ${EXT_DIR}

    ln -s $MOSHI_HOOK_SRC $EXT_DIR/
    ls -l $EXT_DIR
