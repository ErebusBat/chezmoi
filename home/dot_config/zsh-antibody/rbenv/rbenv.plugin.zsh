if [[ ! -x $(which rbenv) ]]; then return 0; fi
# if [[ -f ~/.no-rvm ]]; then echo "RVM installed, but disabled by ~/.no-rvm"; return 0; fi
eval "$(rbenv init -)"
