
# List LightspeedHQ Tasks
[group('LSHQ')]
ls-lshq:
  just --list --group 'LSHQ'

# Run LSHQ Machine Startup
[group('LSHQ')]
lshq-startup:
  ~/bin/lsstartup.sh
