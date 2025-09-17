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
# bin_tasks taken from a new rails 8.0.2 project
bin_tasks=(
  brakeman
  dev
  docker-entrypoint
  importmap
  jobs
  kamal
  rails
  rake
  rubocop
  setup
  thrust
)

for bin in "${bin_tasks[@]}"; do
  eval "$bin() {
    if [[ -x bin/$bin ]]; then
      echo '> bin/$bin \$*'
      bin/$bin \$*
    else
      echo '> bundle exec $bin \$*'
      bundle exec $bin \$*
    fi
  }"
done

unset bin_tasks
