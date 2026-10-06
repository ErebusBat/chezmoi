[ -s "$HOME/.scm_breeze/scm_breeze.sh" ] || return 0

# Can't turn off compdef crap with a setting so we provide a stub
# so we don't get an error
function compdef() { }
source "$HOME/.scm_breeze/scm_breeze.sh"
unfunction compdef;
