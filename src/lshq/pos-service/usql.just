# vim: set ft=just ts=4 sw=4 sts=4 et ai si sta:
# Used to determine if we're using usql or not and other just files.
USQL_JUST := '1'

# Open usql db console
[group('Database')]
[group('POS Service')]
[no-cd]
usql-dbconsole db='dev':
    #!/usr/bin/env zsh
    # set -euo pipefail

    db="{{ db }}"
    if [[ -z $db && -n "${APPDB_NAME:-}" ]]; then
      db=$APPDB_NAME
    elif [[ $db == "dev" ]]; then
      db="pos_service_development"
    elif [[ $db == "test" ]]; then
      db="pos_service_test"
    fi

    echo "source {{ LS_ENV_PATH }}"
    source {{ LS_ENV_PATH }}
    echo $'> \e[32musql mysql://'$APPDB_USER':$APPDB_PASS@'$APPDB_HOST'/'$db'\e[0m'
    usql mysql://$APPDB_USER:$APPDB_PASS@$APPDB_HOST/$db
