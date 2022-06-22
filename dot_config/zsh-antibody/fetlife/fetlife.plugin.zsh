### Mail

# mail server deferred
# msd 11 <-- mail11
function msd() { watch -n30  "ssh mail$1 -- qshape -l -b20 deferred" }

### Kubernetes
alias fz=fetzeug

# function app-pods() { kubectl get pods -l web | awk '/web-puma-[0-9]/ { print $1 }'; }

# function rand-app-pod() { app-pods | gshuf | head -n1 }

# function app-pod-or-rand() {
#   POD_NAME=$1
#   [[ -z $POD_NAME ]] && POD_NAME=$(rand-app-pod)
#   export POD_NAME
# }

alias prod-con="fz web console"
alias prod-bash="fz web bash"
alias prod-rollout="kubectl rollout status deploy/web-puma"

alias stage-con="fz web console -e staging"
alias stage-bash="fz web bash -e staging"

alias maint-current="fz web current -e maintenance"
alias maint-deploy="fz web deploy -e maintenance"
alias maint-con="fz web console -e maintenance"
alias maint-bash="fz web bash -e maintenance"

alias dc=docker-compose
function waitdc() {
  local dcpid=$(pgrep docker-compose build | sort -n | head -n1)
  if [[ $dcpid -le 0 ]]; then
    echo "Couldn't find a docker-compose pid"
    return 0
  fi
  waitpid $dcpid
  saydone
}

function redeploy() {
  if [[ -n $1 ]]; then
    echo "Patching $1"
    echo "  kubectl patch deployment $1 -p '{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"timestamp\":\"$(date +%s)\"}}}}}'"
    kubectl patch deployment $1 -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"timestamp\":\"$(date +%s)\"}}}}}"
  else
    echo "specify deployment"
  fi
}

function stage-deploy() {
  branch_name=$(git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3)
  echo "INFO: Deploying to staging by merging ${branch_name} to staging"
  # echo -n "      Press ENTER to continue"
  # read
  git checkout staging && \
    git fetch && \
    git reset --hard origin/staging && \
    git merge ${branch_name} --no-edit && \
    git push && \
    git checkout ${branch_name}
}

alias stage-current="fetzeug web current -e staging"
alias prod-current="fetzeug web current -e production"

alias rspec='bundle exec rspec'

if [[ -x $HOME/.local/bin/linode-cli ]]; then
  function lssh() {
    local host=$1
    if [[ ! $host =~ /\./ ]]; then
      host="$host.fetlifemail.com"
    fi
    echo "linode-cli ssh $host"
    $HOME/.local/bin/linode-cli ssh $host
  }
fi

export PRY_RESCUE_RAILS=0
