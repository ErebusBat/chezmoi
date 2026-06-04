# Do a mirror push on specified remote
[group('git')]
push-mirror local-rem-name:
    git push --mirror {{ local-rem-name }}

# Create a new mirror repository (idempotent: creates bare repo on server, cleans local junk, pushes)
[group('Maintenance')]
[group('git')]
mirror-to local-rem-name full-git-rem-url:
    #!/usr/bin/env zsh
    set -euo pipefail

    url='{{ full-git-rem-url }}'
    rem_name='{{ local-rem-name }}'

    if [[ "$url" == *:* ]]; then
        ssh_target="${url%%:*}"
        remote_path="${url#*:}"
        printf '==> Ensuring bare repo at %s:%s\n' "$ssh_target" "$remote_path"
        ssh "$ssh_target" "mkdir -p '$(dirname -- "$remote_path")' && mkdir -p '$remote_path' && cd '$remote_path' && ([ -f HEAD ] || /usr/bin/env git init --bare)"
    else
        printf '==> No SSH target in URL; assuming remote already exists\n'
    fi

    printf '==> Adding remote %s\n' "$rem_name"
    /usr/bin/env git remote remove "$rem_name" 2>/dev/null || true
    /usr/bin/env git remote add "$rem_name" "$url"

    printf '==> Pushing mirror\n'
    just push-mirror $rem_name

    printf '==> Remotes after\n'
    /usr/bin/env git remote -v

# Verify Remote repository health
[group('Maintenance')]
[group('git')]
check-remote rem='maze':
    #!/usr/bin/env zsh
    set -euo pipefail

    remote='{{ rem }}'
    repo_url="$(/usr/bin/env git remote get-url "$remote")"
    tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/git-check-${remote}.XXXXXX")"
    repo_path="$tmp_root/repo.git"
    show_ref_file="$tmp_root/show-ref.txt"

    function step() {
      printf '\n==> %s\n' "$*"
    }

    function ok() {
      printf '[ok] %s\n' "$*"
    }

    trap 'rm -rf "$tmp_root"' EXIT

    step "Remote"
    printf 'name: %s\nurl:  %s\n' "$remote" "$repo_url"

    step "Clone mirror"
    printf 'temp: %s\n' "$repo_path"
    /usr/bin/env git clone --mirror "$repo_url" "$repo_path" --quiet
    ok "clone complete"

    step "/usr/bin/env git fsck --full --strict"
    /usr/bin/env git -C "$repo_path" fsck --full --strict
    ok "fsck passed"

    step "/usr/bin/env git show-ref"
    /usr/bin/env git -C "$repo_path" show-ref > "$show_ref_file"
    ref_count="$(wc -l < "$show_ref_file" | tr -d ' ')"
    if [[ "$ref_count" -le 20 ]]; then
      sed 's/^/  /' "$show_ref_file"
    else
      sed -n '1,10s/^/  /p' "$show_ref_file"
      printf '  ... %s refs total ...\n' "$ref_count"
      tail -n 5 "$show_ref_file" | sed 's/^/  /'
    fi
    ok "show-ref passed"

    step "/usr/bin/env git rev-parse --is-bare-repository"
    is_bare="$(/usr/bin/env git -C "$repo_path" rev-parse --is-bare-repository)"
    printf '%s\n' "$is_bare"
    if [[ "$is_bare" != "true" ]]; then
      printf '[error] expected a bare repository clone\n' >&2
      exit 1
    fi
    ok "repository is bare"

    step "Cleaning up"
    rm -rf "$repo_path"
    ok "done"

    step "Summary"
    printf '[ok] remote %s looks healthy\n' "$remote"

