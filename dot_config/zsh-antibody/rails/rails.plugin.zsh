if ! command -v ruby >/dev/null 2>&1; then
  return
fi

alias be="bundle exec"
# alias guard="bundle exec guard"
# alias rails="bin/rails"
# alias rake="bundle exec rake"
# alias rspec="rbenv exec rspec"
# alias rspecd="rbenv exec rspec -f d"

################################################################################
## Command Aliases
################################################################################
brakeman() {
  if [[ -x bin/brakeman ]]; then
    bin/brakeman $*
  else
    bundle exec brakeman $*
  fi
}

# bundle skiped as bundle exec bundle doesn't really make sense

dev() {
  if [[ -x bin/dev ]]; then
    bin/dev $*
  else
    bundle exec dev $*
  fi
}

# docker-entrypoint skipped

importmap() {
  if [[ -x bin/importmap ]]; then
    bin/importmap $*
  else
    bundle exec importmap $*
  fi
}

jobs() {
  if [[ -x bin/jobs ]]; then
    bin/jobs $*
  else
    bundle exec jobs $*
  fi
}

kamal() {
  if [[ -x bin/kamal ]]; then
    bin/kamal $*
  else
    bundle exec kamal $*
  fi
}

rails() {
  if [[ -x bin/rails ]]; then
    bin/rails $*
  else
    bundle exec rails $*
  fi
}

rake() {
  if [[ -x bin/rake ]]; then
    bin/rake $*
  else
    bundle exec rake $*
  fi
}

rubocop() {
  if [[ -x bin/rubocop ]]; then
    bin/rubocop $*
  else
    bundle exec rubocop $*
  fi
}

setup() {
  if [[ -x bin/setup ]]; then
    bin/setup $*
  else
    bundle exec setup $*
  fi
}

thrust() {
  if [[ -x bin/thrust ]]; then
    bin/thrust $*
  else
    bundle exec thrust $*
  fi
}

