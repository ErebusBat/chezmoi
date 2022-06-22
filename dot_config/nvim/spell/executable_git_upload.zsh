#!/usr/bin/env zsh
SPELL_FOLDER=${0:h}

if [[ ! -f $SPELL_FOLDER/en.utf-8.add ]]; then
  echo "*** FATAL: $SPELL_FOLDER does not appear to be spell directory!"
  exit 1
fi
cd ${SPELL_FOLDER}

if [[ $GIT_UPLOAD_STALL_TIME -gt 0 ]]; then
  echo "[$(date)] Waiting for ${GIT_UPLOAD_STALL_TIME}s..."
  sleep $GIT_UPLOAD_STALL_TIME
fi

# https://git-scm.com/docs/git-status
# git status --porcelain=2  | awk '{print $1 " " $2 " " $9}'
# 1 M. ../snip/after.vim
# 1 .M ../snip/plugin.vim
# 1 .M en.utf-8.add
# ? git_upload.zsh
#
# Untracked (1)
# ? vim/.config/nvim/spell/git_upload.zsh
#
# Unstaged (2)
# M vim/.config/nvim/snip/plugin.vim
# M vim/.config/nvim/spell/en.utf-8.add
#
# Staged (1)
# M vim/.config/nvim/snip/after.vim
#
# So any entry where:
#   - $1=1/2; AND
#   - $3 starts with ../
#   - the first character of $2 IS NOT '.
# Indicates that there are staged changes OUTSIDE of the spell folder
# and we should abort

GIT_STAGED_OUTSIDE_OF_SPELL=$(git status --porcelain=2  | awk '{print $1 " " $2 " " $9}' | grep -E '^\d [^\.]' | grep -F ' ../' | wc -l)
if [[ $GIT_STAGED_OUTSIDE_OF_SPELL -gt 0 ]]; then
  echo "[$(date)] Exiting... has staged changes outside of spell foldler..."
  exit 0
fi

GIT_CHANGES_OF_SPELL=$(git status --porcelain=2 *.add | awk '{print $1 " " $2 " " $9}' | wc -l | awk '{print $1}')
MSG="vim: SPELL[$(hostname -s)]-$(date +"%Y%m%d_%H%M%S"): ${GIT_CHANGES_OF_SPELL} changes"
if [[ $GIT_CHANGES_OF_SPELL -eq 0 ]]; then
  echo "[$(date)] No changes detected in spell folder"
  exit 0
fi

# Okay... we know we have changes to the dictionaries so make sure they are sorted before we add them
for spl_file in $(git status --porcelain=2 *.add | awk '{print $9}'); do
  echo "[$(date)] Sorting $spl_file"
  tmp=/tmp/spell
  cat $spl_file > $tmp
  sort -ui $tmp > $spl_file
done

# The `grep -vE '^\?'` ignores untracked files
GIT_ANY_CHANGES_OUTSIDE_OF_SPELL=$(git status --porcelain=2  | awk '{print $1 " " $2 " " $9}' | grep -vE '^\?' | awk '{print $3}' | grep -E '^\.\.\/' | wc -l | awk '{print $1}')
if [[ $GIT_ANY_CHANGES_OUTSIDE_OF_SPELL -eq 0 ]]; then
  git pull -q
else
  echo "[$(date)] Not pulling remote repository... detected ${GIT_ANY_CHANGES_OUTSIDE_OF_SPELL} non-spell changes"
fi

echo $MSG
git add *.add
git commit -q -m ${MSG}

if [[ $GIT_ANY_CHANGES_OUTSIDE_OF_SPELL -eq 0 ]]; then
  git push -q
fi
