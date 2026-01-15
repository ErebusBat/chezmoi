if [[ ! -x $(which jenv) ]]; then return 0; fi
eval "$(jenv init -)"
