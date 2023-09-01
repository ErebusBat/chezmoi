#!/bin/zsh
set -e
ROOT_PATH=~/src/sie
PROJECTS=(
  server
  frontend
)

echo "[$(date)] Starting..."
for proj in $PROJECTS; do
  full_path=$ROOT_PATH/$proj
  if [[ ! -d $full_path ]]; then
    echo "***ERROR: Project path not found: $full_path"
    continue
  fi
  cd $full_path

  echo "[$(date)] Pushing $proj to bat-gitlab"
  git fetch origin 2>&1
  git push bat-gitlab --all --force 2>&1
  git push bat-gitlab --tags 2>&1
done

echo -n "[$(date)] Notifying UptimeKuma..."
curl -s 'http://uptime-kuma.erebusbat.net/api/push/3JmHurF7XG?status=up&msg=OK&ping='
echo ""

echo "[$(date)] Done."
