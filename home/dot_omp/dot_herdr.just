# vim: set ft=just ts=4 sw=4 sts=4 et ai si sta:

# Install herdr app, OMP integration, and skill
[group('herdr - Install/Upgrade')]
herdr-full-install profile='personal':
    just herdr-install-herdr
    just herdr-install-omp-integration {{profile}}
    just herdr-install-skill

[group('herdr - Install/Upgrade')]
herdr-install-herdr:
    curl -fsSL https://herdr.dev/install.sh | sh

# Install agent skill
[group('herdr - Install/Upgrade')]
herdr-install-skill:
    npx skills@latest add ogulcancelik/herdr --skill herdr -g

# Upgrade herdr OMP integration for profiles
[group('herdr - Install/Upgrade')]
herdr-upgrade:
    herdr update
    just herdr-install-omp-integration
    just herdr-link-omp-integration personal
    just herdr-link-omp-integration upserve
    just herdr-integration-status

#Link herdr integration in specififed profile
[group('herdr - Install/Upgrade')]
herdr-link-omp-integration profile:
    #!/usr/bin/env zsh
    set -euo pipefail
    INSTALL_PATH=~/.omp/agent/extensions/herdr-omp-agent-state.ts

    if [[ ! -f $INSTALL_PATH ]]; then
        just herdr-install-omp-integration
    fi

    export PI_CODING_AGENT_DIR=$(printf '{{TEMPLATE_AGENT_DIR }}' '{{profile}}')
    EXT_DIR="$PI_CODING_AGENT_DIR/extensions/"
    ln -sf $INSTALL_PATH $EXT_DIR

# Install herdr integration to specififed profile
[group('herdr - Install/Upgrade')]
herdr-install-omp-integration:
    herdr integration install omp

[group('herdr - Install/Upgrade')]
herdr-integration-status:
    ls -lh $(fd herdr-omp-agent-state.ts)
    shasum $(fd herdr-omp-agent-state.ts)

