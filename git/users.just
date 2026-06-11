git_users_group := "git-users"
git_users_home_base := "/var/git-users"
git_shell := "/usr/bin/git-shell"
git_remote_host := "maze.erebusbat.net"

# List local human users with UID, primary group, home, and shell.
[linux]
[group('Users')]
users-list:
  #!/usr/bin/env bash
  set -euo pipefail

  printf '%-24s %-8s %-24s %-32s %s\n' USER UID PRIMARY-GROUP HOME SHELL
  getent passwd | while IFS=: read -r user _ uid gid _ home shell; do
    if (( uid >= 1000 )) && [[ "$user" != nobody ]]; then
      primary_group=$(getent group "$gid" | cut -d: -f1)
      printf '%-24s %-8s %-24s %-32s %s\n' "$user" "$uid" "$primary_group" "$home" "$shell"
    fi
  done

# Create the shared supplemental group for git repository users if needed.
[linux]
[group('Users')]
git-users-ensure-group:
  #!/usr/bin/env bash
  set -euo pipefail

  group={{quote(git_users_group)}}

  if getent group "$group" >/dev/null; then
    echo "Group already exists: $group"
    exit 0
  fi

  sudo /usr/sbin/groupadd "$group"
  echo "Created group: $group"

# List users who are supplemental members of the shared git-users group.
[linux]
[group('Users')]
git-users-list:
  #!/usr/bin/env bash
  set -euo pipefail

  group={{quote(git_users_group)}}

  if ! group_entry=$(getent group "$group"); then
    echo "Group does not exist: $group"
    exit 0
  fi

  members=$(printf '%s\n' "$group_entry" | cut -d: -f4)
  if [[ -z "$members" ]]; then
    echo "No supplemental members in $group"
    exit 0
  fi

  printf '%-24s %-8s %-24s %-32s %s\n' USER UID PRIMARY-GROUP HOME SHELL
  tr ',' '\n' <<<"$members" | while IFS= read -r user; do
    [[ -n "$user" ]] || continue
    if passwd_entry=$(getent passwd "$user"); then
      IFS=: read -r _ _ uid gid _ home shell <<<"$passwd_entry"
      primary_group=$(getent group "$gid" | cut -d: -f1)
      printf '%-24s %-8s %-24s %-32s %s\n' "$user" "$uid" "$primary_group" "$home" "$shell"
    else
      printf '%-24s %-8s %-24s %-32s %s\n' "$user" missing missing missing missing
    fi
  done

# Add an existing Unix account to the shared git-users supplemental group.
[linux]
[group('Users')]
git-users-add user:
  #!/usr/bin/env bash
  set -euo pipefail

  user={{quote(user)}}
  group={{quote(git_users_group)}}

  if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username: $user" >&2
    exit 1
  fi

  if ! getent passwd "$user" >/dev/null; then
    echo "User does not exist: $user" >&2
    exit 1
  fi

  if ! getent group "$group" >/dev/null; then
    sudo /usr/sbin/groupadd "$group"
  fi

  sudo /usr/sbin/usermod --append --groups "$group" "$user"
  echo "Added $user to $group"

# Remove an existing Unix account from the shared git-users supplemental group.
[linux]
[group('Users')]
git-users-remove user:
  #!/usr/bin/env bash
  set -euo pipefail

  user={{quote(user)}}
  group={{quote(git_users_group)}}

  if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username: $user" >&2
    exit 1
  fi

  if ! getent passwd "$user" >/dev/null; then
    echo "User does not exist: $user" >&2
    exit 1
  fi

  if ! getent group "$group" >/dev/null; then
    echo "Group does not exist: $group" >&2
    exit 1
  fi

  sudo /usr/bin/gpasswd --delete "$user" "$group"
  echo "Removed $user from $group"

# Create a git-only Unix account with a restricted SSH public key.
[linux]
[group('Users')]
git-user-create user pubkey_file:
  #!/usr/bin/env bash
  set -euo pipefail

  user={{quote(user)}}
  pubkey_file={{quote(pubkey_file)}}
  group={{quote(git_users_group)}}
  home_base={{quote(git_users_home_base)}}
  git_shell={{quote(git_shell)}}
  home="$home_base/$user"

  if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username: $user" >&2
    exit 1
  fi

  if [[ ! -x "$git_shell" ]]; then
    echo "git-shell is not executable: $git_shell" >&2
    exit 1
  fi

  if getent passwd "$user" >/dev/null; then
    echo "User already exists: $user" >&2
    exit 1
  fi

  if [[ ! -f "$pubkey_file" ]]; then
    echo "Public key file does not exist: $pubkey_file" >&2
    exit 1
  fi

  key_line=$(awk '!/^[[:space:]]*($|#)/ { print; exit }' "$pubkey_file")
  if [[ -z "$key_line" ]]; then
    echo "Public key file contains no public key: $pubkey_file" >&2
    exit 1
  fi

  key_tmp=$(mktemp)
  trap 'rm -f "$key_tmp"' EXIT
  printf '%s\n' "$key_line" >"$key_tmp"
  ssh-keygen -l -f "$key_tmp" >/dev/null

  if ! getent group "$group" >/dev/null; then
    sudo /usr/sbin/groupadd "$group"
  fi

  if ! getent group "$user" >/dev/null; then
    sudo /usr/sbin/groupadd "$user"
  fi

  sudo /usr/bin/install -d -o root -g root -m 0755 "$home_base"
  sudo /usr/sbin/useradd \
    --create-home \
    --home-dir "$home" \
    --gid "$user" \
    --groups "$group" \
    --shell "$git_shell" \
    --comment "Git-only user" \
    "$user"
  sudo /usr/bin/passwd --lock "$user" >/dev/null
  sudo /usr/bin/install -d -o "$user" -g "$user" -m 0700 "$home/.ssh"
  printf 'restrict %s\n' "$key_line" | sudo /usr/bin/tee "$home/.ssh/authorized_keys" >/dev/null
  sudo /usr/bin/chown "$user:$user" "$home/.ssh/authorized_keys"
  sudo /usr/bin/chmod 0600 "$home/.ssh/authorized_keys"

  echo "Created git-only user: $user"
  echo "Home: $home"
  echo "Shell: $git_shell"

# Add a restricted SSH public key file, or use '-' to paste one interactively.
[linux]
[group('Users')]
git-user-key-add user pubkey_file:
  #!/usr/bin/env bash
  set -euo pipefail

  user={{quote(user)}}
  pubkey_file={{quote(pubkey_file)}}
  home_base={{quote(git_users_home_base)}}
  temp_files=()

  cleanup() {
    for temp_file in "${temp_files[@]}"; do
      rm -f "$temp_file"
    done
  }
  trap cleanup EXIT

  if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username: $user" >&2
    exit 1
  fi

  if ! passwd_entry=$(getent passwd "$user"); then
    echo "User does not exist: $user" >&2
    exit 1
  fi

  home=$(printf '%s\n' "$passwd_entry" | cut -d: -f6)
  case "$home" in
    "$home_base"/*) ;;
    *)
      echo "Refusing to modify SSH keys for $user because home is outside $home_base: $home" >&2
      exit 1
      ;;
  esac

  if [[ "$pubkey_file" == "-" ]]; then
    input_tmp=$(mktemp)
    temp_files+=("$input_tmp")
    printf 'Paste SSH public key, then press Enter: ' >/dev/tty
    IFS= read -r pasted_key </dev/tty
    printf '%s\n' "$pasted_key" >"$input_tmp"
    pubkey_file="$input_tmp"
  elif [[ ! -f "$pubkey_file" ]]; then
    echo "Public key file does not exist: $pubkey_file" >&2
    exit 1
  fi

  key_line=$(awk '!/^[[:space:]]*($|#)/ { print; exit }' "$pubkey_file")
  if [[ -z "$key_line" ]]; then
    echo "Public key file contains no public key: $pubkey_file" >&2
    exit 1
  fi

  key_tmp=$(mktemp)
  temp_files+=("$key_tmp")
  printf '%s\n' "$key_line" >"$key_tmp"
  ssh-keygen -l -f "$key_tmp" >/dev/null

  sudo /usr/bin/install -d -o "$user" -g "$user" -m 0700 "$home/.ssh"
  auth_file="$home/.ssh/authorized_keys"
  restricted_key="restrict $key_line"

  if sudo /usr/bin/test -f "$auth_file" && sudo /usr/bin/grep -Fqx -- "$restricted_key" "$auth_file"; then
    echo "Key already exists for $user"
    exit 0
  fi

  printf '%s\n' "$restricted_key" | sudo /usr/bin/tee -a "$auth_file" >/dev/null
  sudo /usr/bin/chown "$user:$user" "$auth_file"
  sudo /usr/bin/chmod 0600 "$auth_file"
  echo "Added SSH public key for $user"

# Print public keys installed for an existing git-only Unix account.
[linux]
[group('Users')]
git-user-keys user:
  #!/usr/bin/env bash
  set -euo pipefail

  user={{quote(user)}}
  home_base={{quote(git_users_home_base)}}

  if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username: $user" >&2
    exit 1
  fi

  if ! passwd_entry=$(getent passwd "$user"); then
    echo "User does not exist: $user" >&2
    exit 1
  fi

  home=$(printf '%s\n' "$passwd_entry" | cut -d: -f6)
  case "$home" in
    "$home_base"/*) ;;
    *)
      echo "Refusing to read SSH keys for $user because home is outside $home_base: $home" >&2
      exit 1
      ;;
  esac

  sudo /usr/bin/test -f "$home/.ssh/authorized_keys"
  sudo /usr/bin/sed 's/^restrict //' "$home/.ssh/authorized_keys"

# Create a bare git repository for a user and print its SSH remote.
[linux]
[group('Git Repositories')]
git-create-repo user repo:
  #!/usr/bin/env bash
  set -euo pipefail

  user={{quote(user)}}
  repo={{quote(repo)}}
  git_shell={{quote(git_shell)}}
  remote_host={{quote(git_remote_host)}}

  if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username: $user" >&2
    exit 1
  fi

  if [[ -z "$repo" || "$repo" == /* ]]; then
    echo "Repository path must be a non-empty relative path: $repo" >&2
    exit 1
  fi

  if [[ ! "$repo" =~ ^[A-Za-z0-9._/-]+$ ]]; then
    echo "Repository path may only contain letters, numbers, dots, underscores, hyphens, and slashes: $repo" >&2
    exit 1
  fi

  IFS='/' read -r -a repo_parts <<<"$repo"
  for part in "${repo_parts[@]}"; do
    case "$part" in
      ''|'.'|'..')
        echo "Repository path contains an unsafe segment: $repo" >&2
        exit 1
        ;;
    esac
  done

  if [[ "$repo" != *.git ]]; then
    repo="$repo.git"
  fi

  if ! passwd_entry=$(getent passwd "$user"); then
    echo "User does not exist: $user" >&2
    exit 1
  fi

  IFS=: read -r _ _ _ gid _ home shell <<<"$passwd_entry"
  if [[ -z "$home" || "$home" == / ]]; then
    echo "Refusing to create repository for unsafe home path: $home" >&2
    exit 1
  fi

  if [[ "$shell" == "$git_shell" ]]; then
    target="$home/$repo"
    remote_path="$repo"
  else
    target="$home/git/$repo"
    remote_path="git/$repo"
  fi

  if sudo -u "$user" /usr/bin/test -e "$target"; then
    echo "Repository path already exists: $target" >&2
    exit 1
  fi

  primary_group=$(getent group "$gid" | cut -d: -f1)
  target_parent=$(/usr/bin/dirname "$target")
  git_bin=$(command -v git)

  sudo -u "$user" /usr/bin/mkdir -p "$target_parent"
  sudo -u "$user" "$git_bin" init --bare "$target" >/dev/null
  sudo /usr/bin/chown -R "$user:$primary_group" "$target"

  echo "Created bare repository: $target"
  echo "Remote: $user@$remote_host:$remote_path"

# Show repository disk usage for a user's git repository directory.
[linux]
[group('Git Repositories')]
git-user-ls-repos user level='2':
  #!/usr/bin/env bash
  set -euo pipefail

  user={{quote(user)}}
  level={{quote(level)}}
  git_shell={{quote(git_shell)}}

  if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username: $user" >&2
    exit 1
  fi

  if [[ ! "$level" =~ ^[0-9]+$ ]]; then
    echo "Level must be a non-negative integer: $level" >&2
    exit 1
  fi

  if ! eza_bin=$(command -v eza); then
    echo "eza is not available in PATH" >&2
    exit 1
  fi

  if ! passwd_entry=$(getent passwd "$user"); then
    echo "User does not exist: $user" >&2
    exit 1
  fi

  IFS=: read -r _ _ _ _ _ home shell <<<"$passwd_entry"
  if [[ -z "$home" || "$home" == / ]]; then
    echo "Refusing to inspect unsafe home path: $home" >&2
    exit 1
  fi

  if [[ "$shell" == "$git_shell" ]]; then
    target="$home"
  else
    target="$home/git"
  fi

  if ! sudo /usr/bin/test -d "$target"; then
    echo "Git directory does not exist: $target" >&2
    exit 1
  fi

  sudo "$eza_bin" -Tlh -L "$level" --total-size --icons=auto "$target"

# Delete a git-only Unix account and all data under its /var/git-users home.
[linux]
[confirm('Are you sure you want to destroy the user and ALL of their data?')]
[group('Users')]
git-user-delete user:
  #!/usr/bin/env bash
  set -euo pipefail

  user={{quote(user)}}
  home_base={{quote(git_users_home_base)}}

  if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username: $user" >&2
    exit 1
  fi

  if ! passwd_entry=$(getent passwd "$user"); then
    echo "User does not exist: $user" >&2
    exit 1
  fi

  home=$(printf '%s\n' "$passwd_entry" | cut -d: -f6)
  case "$home" in
    "$home_base"/*) ;;
    *)
      echo "Refusing to delete $user because home is outside $home_base: $home" >&2
      exit 1
      ;;
  esac

  if [[ "$home" == "$home_base" || "$home" == / || -z "$home" ]]; then
    echo "Refusing to delete unsafe home path: $home" >&2
    exit 1
  fi

  sudo /usr/sbin/userdel --remove "$user"

  if [[ -d "$home" ]]; then
    sudo /usr/bin/rm -rf --one-file-system -- "$home"
  fi

  if getent group "$user" >/dev/null; then
    sudo /usr/sbin/groupdel "$user" || true
  fi

  echo "Deleted git-only user: $user"
