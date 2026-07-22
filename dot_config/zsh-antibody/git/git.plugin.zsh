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
alias gbda='git branch --merged | command grep -vE "^(\*|\s*master\s*$|\s*main\s*)" | command xargs -n 1 git branch -d'
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

# Git Catch Up (Clean)
alias gcu='gfo && gsu'
alias gcuc='gcu && gbda'

# Git Clean Up Master
alias gcum='git_checkout_update_master && gsu && gbda'

# Git WorkTree (now using https://github.com/max-sixty/worktrunk)
# alias gwt='git worktree'
# alias gwta='git worktree add'
# alias gwtrm='git worktree remove'
# alias gwtp='git worktree prune'
# alias gwtls='git worktree list'
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
  local barePath="${repoAnchorDir}/.bare"

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
  cd ${defaultBranchWtPath}
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

# See working/scm-breeze/scm-breeze.plugin.zsh for more aliases

# Is it master or main?  This will find out
# Usage:
#   local branch=$(git_master_branch_name)
function git_master_branch_name() {
  local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
  echo "$default_branch"
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
  local branch=$(git_master_branch_name)
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
  # local branches=$(git branch --merged | grep -Ev '(\*|master)' | awk '{print $1}')
  local branches=$(git branch --merged | grep -Ev '(\*|master)')
  branches=$(echo "$branches\n")
  echo "The following branches have been merged and can be removed:"
  echo $branches
  echo "Press ENTER to purge branches."
  read continue_signal
  # printf %s "$branches\n" | {
  #   while read -r br; do
  #     # echo ">$br<"
  #     # We don't use -D here as a failsafe
  #   done
  # }
  for br in $(git branch --merged | grep -Ev '(\*|master)' | awk '{print $1}'); do
    # We don't use -D here as a failsafe
    git branch -d "$br"
  done
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

