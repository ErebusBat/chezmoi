#
# git stuff
#   - Also look at scm-breeze and scm-breeze-fixes, both of which run after this!
#

# if [ -f /data/Dropbox/Library/G/git-master-branch-setup.txt ]; then alias git_master_setup="cat /data/Dropbox/Library/G/git-master-branch-setup.txt"; fi
alias gs='git status'
alias gsu='git submodule init && git submodule update'

alias glp='git log --pretty=oneline'
alias gld='git log --decorate --oneline --graph'

# alias gpp='git pull --prune'
# alias gprb='git pull --rebase --autostash'
# alias gpbgh='git_push_update_origin && git browse'
# alias gcip='git ci && git push'

alias gfo='git fetch origin'

alias gcv='git commit -v'
alias gcva='git commit -v --amend'
# alias gcvt='git commit -vt .git/COMMIT_EDITMSG.claude'
# alias gcvta='git commit -vt --amend .git/COMMIT_EDITMSG.claude'

alias gbrc='git branch --show-current'

# Git Quick Save
# alias gqs='git add -Av $(git rev-parse --show-toplevel || echo ".") && git commit'
# alias gu='gpm && gbda && gsu'

# Additional useful aliases
alias gbda=git_rm_merged_branches
# alias gca!='git commit -v -a --amend'
alias gdw='git diff --word-diff'
alias glol='git log --oneline --decorate --color'
alias glo='glol | head -n 20'

alias gP='git push'
alias gp='git pull --no-edit --autostash'
alias gprb='git pull --rebase --autostash'
alias gy='git sync'
alias gysm='git syncsm'

alias gpbgh='git_push_update_origin && gh pr create --web'
alias gpm='git co master && git pull --prune'

alias grbi='git rebase -i'
alias grhh='git reset --hard HEAD'
alias gremv='git remote -v'

# Git Catch Up (Clean)
alias gcu='gfo && gsu'
alias gcuc='gcu && gbda'

# Clean branches merged into upstream main/master without switching worktrees.
alias gcum=git_rm_merged_branches

# Git WorkTree (now using https://github.com/max-sixty/worktrunk)
alias gwt='git worktree'
# alias gwta='git worktree add'
# alias gwtrm='git worktree remove'
# alias gwtp='git worktree prune'
alias gwtls='git worktree list'
# alias gnwtm='gwtnew'

# Create a new worktree with a branch prefixed by the repo name
# Usage: gwtnew my-feature
#   In ~/src/lshq/granted-registry.git → git worktree add -b granted-registry/my-feature <master|main>
# function gwtnew() {
#   if [[ -z $1 ]]; then
#     echo "Usage: gwtnew <branch-name>"
#     return 1
#   fi
#   local base_branch=$(git_master_branch_name)
#   local repo_name=${${PWD:t}%.---}
#   local wt_path="../${repo_name}--$1"
#   if git show-ref --verify --quiet "refs/heads/$1"; then
#     git worktree add "$wt_path" "$1" || return $?
#   else
#     git worktree add -b "$1" "$wt_path" "$base_branch" || return $?
#   fi
#   echo "\nWorktree path: ${${wt_path:a}/#$HOME/~}"
#   cd "$wt_path"
# }

function git-clone-worktree-repo() {
  ### Make sure we have a valid repo URI
  local repo=$1
  if [[ -z $repo ]]; then
    echo "*** FATAL: Specify repoUri" >&2
    return 1
  fi
  ### What is the repo's base dir? (handle .git)
  local repoAnchorDir="${2:-${repo:t}}"
  if [[ ${repoAnchorDir:e} == "git" ]]; then
    repoAnchorDir=${repoAnchorDir:r}
  fi
  # local barePath="${repoAnchorDir}/.bare"
  local barePath="${repoAnchorDir}/.${repoAnchorDir:t}"

  ### Clone Repo
  printf "\n------------------------------------------------------------\n"
  printf "--- Checking Out Repository\n"
  if [[ -d $repoAnchorDir ]]; then
    echo "*** FATAL: Directory already exists: $repoAnchorDir" >&2
    return 1
  fi
  command git clone --bare $repo $barePath
  printf "------------------------------------------------------------\n"

  ### Checkout master/main as a worktree
  local defaultBranch=$(command git -C $barePath symbolic-ref --short HEAD)
  local defaultBranchWtPath="${repoAnchorDir}/${defaultBranch}" # Relative to cwd
  local defaultBranchCheckoutPath="../${defaultBranch}"         # Relative to barePath
  printf "\n------------------------------------------------------------\n"
  printf "--- Creating a worktree for $defaultBranch\n"
  echo "git -C ${barePath} worktree add ${defaultBranchCheckoutPath} ${defaultBranch}"
  command git -C ${barePath} worktree add ${defaultBranchCheckoutPath} ${defaultBranch}
  printf "--- Ensuring that $defaultBranch tracks remote\n"
  cd ${defaultBranchWtPath}
  command git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
  command git fetch origin
  printf "------------------------------------------------------------\n"

  ### Debugging
  # printf "\n--- DEBUG --------------------------------------------------\n"
  # printf "                     repo=$repo\n"
  # printf "            defaultBranch=$defaultBranch\n"
  # printf "            repoAnchorDir=$repoAnchorDir\n"
  # printf "          repoAnchorDir:r=${repoAnchorDir:r}\n"
  # printf "                 barePath=$barePath\n"
  # printf "      defaultBranchWtPath=$defaultBranchWtPath\n"
  # printf "defaultBranchCheckoutPath=$defaultBranchCheckoutPath\n"
  # printf "------------------------------------------------------------\n"

  printf "\nDone! You are now in the ${defaultBranch} of the ${repoAnchorDir} repository"
}

function git_worktree_paths_in_main() {
  local master_branch=$(git_master_branch_name)
  local current_worktree_path=$(git rev-parse --show-toplevel 2>/dev/null)
  local worktree_path
  git worktree list --porcelain |
    sed -n 's/^worktree //p' |
    while IFS= read -r worktree_path; do
      [ -d "$worktree_path" ] || continue
      [ "$(git -C "$worktree_path" branch --show-current)" = "$master_branch" ] && continue
      [ -z "$(git -C "$worktree_path" status --porcelain)" ] || continue
      git -C "$worktree_path" merge-base --is-ancestor HEAD "origin/$master_branch" || continue
      if [[ -n $current_worktree_path && ${worktree_path:A} == ${current_worktree_path:A} ]]; then
        printf 'Skipping current worktree: %s\n' "$worktree_path" >&2
        continue
      fi
      printf '%s\n' "$worktree_path"
    done
}

# List clean worktrees whose HEAD is reachable from any cached origin branch.
# Run git fetch origin first if the remote-tracking refs need updating.
function git_worktree_paths_pushed_to_origin() {
  local current_worktree_path=$(git rev-parse --show-toplevel 2>/dev/null)
  local worktree_path head
  git worktree list --porcelain |
    sed -n 's/^worktree //p' |
    while IFS= read -r worktree_path; do
      [[ -d $worktree_path ]] || continue
      [[ $(git -C "$worktree_path" rev-parse --is-bare-repository 2>/dev/null) == false ]] || continue
      [[ -n $current_worktree_path && ${worktree_path:A} == ${current_worktree_path:A} ]] && continue
      git -C "$worktree_path" symbolic-ref --quiet HEAD >/dev/null || continue
      [[ -z $(git -C "$worktree_path" status --porcelain) ]] || continue
      head=$(git -C "$worktree_path" rev-parse HEAD) || continue
      [[ -n $(git for-each-ref --format='%(refname)' --contains "$head" refs/remotes/origin/) ]] || continue
      printf '%s\n' "$worktree_path"
    done
}

function remove_worktrees_in_main() {
  git_worktree_paths_in_main |
    while IFS= read -r worktree_path; do
      if [[ $PWD == $worktree_path ]]; then
        echo "SKIP $worktree_path"
      else
        echo "Removing ${worktree_path:t}"
        git worktree remove "$worktree_path"
      fi
    done
}

function remove_worktrees_pushed() {
  git_worktree_paths_pushed_to_origin |
    while IFS= read -r worktree_path; do
      if [[ $PWD == $worktree_path ]]; then
        echo "SKIP $worktree_path"
      else
        echo "Removing ${worktree_path:t}"
        git worktree remove "$worktree_path"
      fi
    done
}

function git_worktree_cleanup() {
  git worktree prune
  remove_worktrees_in_main
  remove_worktrees_pushed
}
alias gwtcu=git_worktree_cleanup

# See working/scm-breeze/scm-breeze.plugin.zsh for more aliases

# Is it master or main?  This will find out
# Usage:
#   local branch=$(git_master_branch_name)
function git_main_remote_name() {
  local branch remote current_branch
  current_branch=$(command git symbolic-ref --quiet --short HEAD)
  # Prefer the default branch's upstream (which may differ from a fork's remote).
  for branch in main master "$current_branch"; do
    [[ -n $branch ]] || continue
    remote=$(command git config --get "branch.$branch.remote") || continue
    [[ $remote != . ]] || continue
    if command git remote get-url "$remote" >/dev/null 2>&1; then
      print -r -- "$remote"
      return 0
    fi
  done
  if command git remote get-url origin >/dev/null 2>&1; then
    print -r -- origin
    return 0
  fi
  local -a remotes
  remotes=("${(@f)$(command git remote)}")
  if (( ${#remotes} == 1 )) && [[ -n $remotes[1] ]]; then
    print -r -- "$remotes[1]"
    return 0
  fi
  print -u2 -r -- 'Cannot determine upstream remote; configure tracking for main/master.'
  return 1
}

function git_master_branch_name() {
  local remote=${1-} default_ref branch
  if [[ -z $remote ]]; then
    remote=$(git_main_remote_name) || return 1
  fi
  default_ref=$(command git symbolic-ref --quiet "refs/remotes/$remote/HEAD")
  if [[ -n $default_ref ]] && command git show-ref --verify --quiet "$default_ref"; then
    print -r -- "${default_ref#refs/remotes/$remote/}"
    return 0
  fi
  # Remote HEAD is optional; fetch does not always create it.
  for branch in main master; do
    if command git show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
      print -r -- "$branch"
      return 0
    fi
  done
  print -u2 -r -- "Cannot find main/master on upstream remote '$remote'."
  return 1
}

# What is the current branches name?
function git_current_branch_name() {
  local branch=$(git name-rev --name-only HEAD)
  echo "$branch"
}

alias gpm=git_checkout_update_master
function git_checkout_update_master() {
  # Old version:
  # alias gpm='git co master && git pull --prune && git_rm_merged_branches'
  local branch
  branch=$(git_master_branch_name) || return 1
  git checkout "$branch" && git pull --prune && git_rm_merged_branches
}


alias gpuo=git_push_update_origin
function git_push_update_origin() {
  local branch=$(git_current_branch_name)
  if [[ -n $1 ]]; then
    branch=$1
  fi
  echo "git push -u origin $branch"
  git push -u origin $branch
}

alias gnbm=git_new_branch_mastermain
function git_new_branch_mastermain() {
  # Old version:
  # alias gnbm='git co master && git pull --prune && git co master -b'
  local branch=$(git show-ref --verify --quiet refs/heads/main && echo "main" || echo "master")
  git co $branch && git pull --prune && git co $branch -b $1
}

### End SCM

# Show all aliases for git
function git-aliases() {
  if [[ -z $1 ]]; then
    alias | grep -E "='?git" | sort
  else
    alias | grep -E "='?git" | grep -E $1 | sort
  fi
}

# Git Push All
function gpa(){
  for r in $(git remote); do
    echo "Pushing All Changes to $r";
    git push $r --all;
    echo "";
  done
}

alias gpou=git_push_update_origin
function git_push_update_origin() {
  local branch=$(git name-rev --name-only HEAD)
  if [[ -n $1 ]]; then
    branch=$1
  fi
  echo "git push -u origin $branch"
  git push -u origin $branch
}

alias grmmb=git_rm_merged_branches
function git_rm_merged_branches() {
  local remote default_branch base_ref base_oid records branch oid worktree_path
  local continue_signal current_oid failures=0
  local -a branches
  local -A branch_oids
  command git rev-parse --git-dir >/dev/null || return 1
  remote=$(git_main_remote_name) || return 1
  # Refresh every upstream branch even in bare/single-branch clones whose
  # configured fetch refspec may omit main/master and leave a stale cached ref.
  command git fetch --prune "$remote" \
    "+refs/heads/*:refs/remotes/$remote/*" || return 1
  default_branch=$(git_master_branch_name "$remote") || return 1
  base_ref="refs/remotes/$remote/$default_branch"
  base_oid=$(command git rev-parse --verify "$base_ref^{commit}") || return 1

  # Ref fields contain no display markers or ANSI colors. A worktree path may
  # contain spaces, so read it as the last field and never split it into words.
  records=$(command git for-each-ref --merged="$base_oid" \
    --format='%(refname:strip=2)%09%(objectname)%09%(worktreepath)' refs/heads/) || return 1
  while IFS=$'\t' read -r branch oid worktree_path; do
    [[ -n $branch ]] || continue
    [[ $branch == main || $branch == master || $branch == "$default_branch" ]] && continue
    if [[ -n $worktree_path ]]; then
      print -u2 -r -- "Skipping branch '$branch' used by worktree: $worktree_path"
      continue
    fi
    branches+=("$branch")
    branch_oids[$branch]=$oid
  done <<< "$records"

  if (( ${#branches} == 0 )); then
    print -r -- "No unused local branches merged into $remote/$default_branch."
    return 0
  fi
  print -r -- "The following branches are merged into $remote/$default_branch and can be removed:"
  printf '  %s\n' "${branches[@]}"
  print -r -- 'Press ENTER to purge branches; any other input cancels.'
  if ! IFS= read -r continue_signal || [[ -n $continue_signal ]]; then
    print -r -- 'Branch cleanup cancelled.'
    return 1
  fi

  for branch in "${branches[@]}"; do
    # Only delete the displayed revision, and recheck worktree occupancy after
    # confirmation. Git's branch deletion also guards against a checkout race.
    current_oid=$(command git rev-parse --verify "refs/heads/$branch") || continue
    worktree_path=$(command git for-each-ref --format='%(worktreepath)' \
      "refs/heads/$branch") || return 1
    if [[ $current_oid != ${branch_oids[$branch]} || -n $worktree_path ]]; then
      print -u2 -r -- "Skipping branch '$branch': branch or worktree changed during confirmation."
      continue
    fi
    command git merge-base --is-ancestor "$current_oid" "$base_oid" || return 1
    # Reachability was checked against the fetched default branch above. -d
    # instead checks HEAD or this branch's own upstream, which may be unrelated.
    # -D still refuses to delete a branch checked out in any worktree.
    command git branch -D -- "$branch" || failures=1
  done
  return $failures
}

# If git aliases like gs/ga are not working then make sure that scm-breeze is working
# alias gco='git checkout'
# alias ga='git add'

#########
# LazyGit
#########
if command -v lazygit >/dev/null 2>&1; then
  alias lg=lazygit
fi

# fzf
if [[ `type fzf` =~ 'fzf is' ]]; then
  # Git Check Out (local)
  unalias gco 2>/dev/null
  function gco() {
    if [[ -n $1 ]]; then
      git checkout $1 && gsu && return
    fi
    local branches branch
    branches=$(/usr/local/bin/git branch | grep -v HEAD) &&
    branch=$(echo "$branches" |
             fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##") && \
    gsu
  }

  # Git Check Out Remote (and track branch)
  function gcor() {
    local branches branch
    branches=$(git branch --remote | grep -v HEAD) &&
    branch=$(echo "$branches" |
             fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout --track $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##") && \
    gsu
  }

  # Git Reset File
  function grf() {
    local all_files files
    # Handle file paths passed in
    if [[ -n $1 ]]; then
      # Use sourc-scm alias for provided args
      git checkout HEAD -- $*
      return 0
    fi
    all_files=$(/usr/local/bin/git ls-files --modified --exclude-standard) &&
    files=$(echo "$all_files" |
            fzf-tmux -d $(( 2 + $(wc -l <<< "$all_files") )) +m) &&
    git checkout HEAD -- $files
  }

  # Git Branch 'd'elete (small d for merged only)
  unalias gbd 2>/dev/null
  function gbd() {
    local branches branch
    branches=$(/usr/bin/git branch | grep -v HEAD) &&
    branch=$(echo "$branches" |
             fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git branch -d $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  }

  unalias ga 2>/dev/null
  function ga() {
    local all_files files
    # Handle file paths passed in
    if [[ -n $1 ]]; then
      # Use sourc-scm alias for provided args
      git_add_shortcuts $*
      return 0
    fi
    all_files=$(/usr/local/bin/git ls-files --modified --others --exclude-standard) &&
    files=$(echo "$all_files" |
            fzf-tmux -d $(( 2 + $(wc -l <<< "$all_files") )) +m) &&
    git add $files
  }

  # Git UnStage
  function gus() {
    local staged files
    # Handle file paths passed in
    if [[ -n $1 ]]; then
      git restore --staged $*
      return 0
    fi
    staged=$(/usr/local/bin/git diff --name-only --cached) &&
    files=$(echo "$staged" |
            fzf-tmux -d $(( 2 + $(wc -l <<< "$staged") )) +m) &&
    git restore --staged $files
  }
fi
