# vim: set ft=just ts=4 sw=4 sts=4 et ai si sta:

# List memex tasks
[group('Memex')]
memex-ls:
    just --list --group Memex

# Index specififed OMP profile
[group('Memex')]
memex-index profile='personal':
    #!/usr/bin/env zsh
    OMP_PROFILE="{{profile}}"
    PI_CODING_AGENT_DIR=$(printf "{{TEMPLATE_AGENT_DIR }}" "{{profile}}")

    echo "*** INFO: Attempting to index $OMP_PROFILE sessions"
    export PI_CODING_AGENT_DIR
    memex index --pi --no-codex --no-opencode --no-cursor --no-openclaw --no-copilot
