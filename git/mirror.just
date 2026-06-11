# https://chat.deepseek.com/a/chat/s/9598bd1e-80b2-4645-8e5b-09ea29ff621a
VENDOR_DIR := env("HOME") / "git/vendor"

# List only git mirror tasks
[group('List')]
ls-mirrors:
  just --list --group 'Mirrors'

# Iinitialize a new mirror in the vendor directory.
[group('Mirrors')]
mirror-init-repo remote-url:
  #!/usr/bin/env zsh
  set -euo pipefail

  REM_URL={{quote(remote-url)}}
  REM_ORG=${REM_URL:h:t}
  REM_PRJ=${REM_URL:t}
  VENDOR_DIR={{quote(VENDOR_DIR)}}
  FULL_DIR="$VENDOR_DIR/$REM_PRJ"

  # Sanity Check
  if [[ -d $FULL_DIR ]]; then
    echo "FATAL: $FULL_DIR already exists"
    exit 1
  fi

  # Clone into the vendor dir
  cd $VENDOR_DIR
  git clone --mirror $REM_URL $REM_PRJ

  # Update User
  echo ""
  echo "INFO: Cloned / Mirrored Repository:"
  echo "      $REM_URL"
  echo "   => $VENDOR_DIR/$REM_PRJ"
  echo ""
  echo "WARN: Do NOT do standard 'git pull'!"
  echo "      use 'git fetch --mirror origin' or:"
  echo "      use 'just mirror-fetch-repo $VENDOR_DIR/$REM_PRJ"

# Fetch mirror update
[group('Mirrors')]
mirror-fetch-repo repo-dir remote='origin':
  #!/usr/bin/env zsh
  set -euo pipefail

  REPO_DIR={{quote(repo-dir)}}
  if [[ ! -f "$REPO_DIR/HEAD" ]]; then
    echo "FATAL: Repo does not appear to be correct: $REPO_DIR"
    exit 1
  fi

  cd $REPO_DIR
  git fetch --prune {{remote}}


# Fetch updates from all mirrors
[group('Mirrors')]
mirror-fetch-all:
  just mirror-fetch-repo vendor/mcp-memory-service.git

# ################################################################################
# ### mcp-memory-service
# ################################################################################
#
# # Init mirror repository in vendor directory
# [group('Mirrors')]
# [group('mirror: mcp-memory-service')]
# @mirror-init-mcp-memory-service:
#   cd {{VENDOR_DIR}} && \
#     git clone --mirror https://codeberg.org/doobidoo/mcp-memory-service.git && \
#     echo "INFO: "
#
# # Fetch mirror updates from remote
# [group('Mirrors')]
# [group('mirror: mcp-memory-service')]
# mirror-mcp-memory-service-fetch remote='origin':
#   cd {{VENDOR_DIR}} && \
#     git fetch --prune {{remote}}
#
# # # Push mirror to remote
# # [group('Mirrors')]
# # [group('mirror: mcp-memory-service')]
# # mirror-mcp-memory-service-push remote='origin':
# #   cd {{VENDOR_DIR}} && \
# #     git push --mirror {{remote}}
