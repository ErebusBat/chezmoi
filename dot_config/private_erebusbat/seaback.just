# vim: set ft=just ts=4 sw=4 sts=4 et ai si sta:
SEABACK_TERM := 'SeaBack'
SEABACK_OUTPUT_PATH := '/tmp/ext-seaback.out'

[group('SeaBack External HDD Management')]
ls-seaback:
    just --list --group 'SeaBack External HDD Management'

[group('SeaBack External HDD Management')]
seaback-ps-ls:
    sudo lsof | rg {{ SEABACK_TERM }} | tee {{ SEABACK_OUTPUT_PATH }} | awk '{print $2 "\t" $1}' | sort -u
