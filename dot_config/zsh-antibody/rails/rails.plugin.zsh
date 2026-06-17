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
  # jobs
  kamal
  rails
  rake
  rspec
  rubocop
  setup
  thrust
)

for bin in "${bin_tasks[@]}"; do
  eval "$bin() {
    local bin_ec=
    if [[ -x bin/$bin ]]; then
      echo '> bin/$bin \$*'
      bin/$bin \$*
      bin_ec=\$?
    else
      echo \"> bundle exec $bin \${*[@]}\"
      bundle exec $bin \$*
      bin_ec=\$?
    fi

    if command -v cmux-notify 2>&1 >/dev/null; then
      cmux-notify \"$bin exited (ec=\$bin_ec)\"
    fi
    return \$bin_ec
  }"
done

unset bin_tasks
