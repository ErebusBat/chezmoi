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

# Install herdr integration to specififed profile
[group('herdr - Install/Upgrade')]
herdr-install-omp-integration profile:
    #!/usr/bin/env zsh
    set -euo pipefail

    # https://herdr.dev/docs/integrations/#omp
    PI_CODING_AGENT_DIR=$(printf '{{TEMPLATE_AGENT_DIR }}' '{{profile}}')
    # echo "PI_CODING_AGENT_DIR=$PI_CODING_AGENT_DIR"
    herdr integration install omp
