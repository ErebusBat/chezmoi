import? '../.git.just'

# List changed spec files.
[no-cd]
[group('git')]
git-changed-spec-files base-branch='master':
  just git-changed-files {{base-branch}} | rg '^spec/'

# List changed spec files.
[no-cd]
[group('rspec')]
rspec-changed-spec-files base-branch='master':
  #!/usr/bin/env zsh
  set -euo pipefail

  # Get changed spec files, ignore factories.
  spec_files=($(just git-changed-files {{base-branch}} | rg '^spec/' | rg -v 'spec/factories/'))
  echo "rspec -f d ${spec_files[*]}"
  bundle exec rspec -f d "${spec_files[@]}"


