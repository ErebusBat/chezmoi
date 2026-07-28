# vim: set ft=just ts=4 sw=4 sts=4 et ai si sta:

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
