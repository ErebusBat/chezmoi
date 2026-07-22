# These are both the same, for now anyway
STAGING_ROLE := "lsu/pos/poweruser/us-east-1"
PROD_ROLE    := "lsu/pos/poweruser/us-east-1"

# Connect to a random pos-service-r0-internal pod
[no-cd]
[group('EKS')]
pos-bash shard='r0':
    #!/usr/bin/env bash
    set -euo pipefail
    k8s_ns="pos-service-{{shard}}"

    label="app.kubernetes.io/name=$k8s_ns-internal"
    pods=$(kubectl -n $k8s_ns get pods -l "$label" -o jsonpath='{.items[*].metadata.name}')
    if [[ -z "$pods" ]]; then
        echo "No pods found with label $label in namespace $k8s_ns" >&2
        exit 1
    fi
    pod_array=($pods)
    pod=${pod_array[$((RANDOM % ${#pod_array[@]}))]}
    echo "Connecting to: $pod"
    kubectl -n $k8s_ns exec -it "$pod" -- bash

# Open a bash shell on give ENV/Shard/Role using ecspress
[no-cd]
[group('ECSpress')]
ecspress_shell env_name shard_num='0' shard_name="internal":
  #!/usr/bin/env zsh
  env_name="{{ env_name }}"
  cluster_name="${env_name}_{{ shard_name }}_shard_r{{ shard_num }}"

  # Staging vs Prod differences
  env_name_disp=$env_name
  if [[ $env_name == "production" ]]; then
    env_name_disp="☢️❗PRODUCTION ❗☢️"
    desired_aws_role="{{ PROD_ROLE }}"
  else
    desired_aws_role="{{ STAGING_ROLE }}"
  fi

  if [[ $AWS_PROFILE != $desired_aws_role ]]; then
    echo "ERROR: Please authenticate with AWS_PROFILE=$desired_aws_role"
    echo "                        Current AWS_PROFILE=$AWS_PROFILE"
    echo ""
    echo "assume $desired_aws_role"
    echo ""
    exit 1
    # Tried to get this to work, but because of the way assume works it wont
    # always work in a sub-script so I just revered and required explicit
    # role switching
    # echo "Press ENTER to automatically switch; Ctrl+C to abort"
    # read
    # assume $desired_aws_role
  fi

  # Information Display
  echo ""
  echo "             env=${env_name_disp}"
  echo "      shard_type={{ shard_name }}"
  echo "       shard_num={{ shard_num }}"
  echo ""
  echo "❯ AWS_PROFILE=$AWS_PROFILE bundle exec rake ecspress:console:run:${cluster_name}"

  # Actually Open the Console
  bundle exec rake ecspress:console:run:${cluster_name}

# Open a staging console on given shard
[no-cd]
[group('Staging')]
staging_shell shard_num='0' shard_name="internal":
  just ecspress_shell 'staging' "{{ shard_num }}" "{{ shard_name }}"
# staging_shell shard_num='0' shard_name="internal":
#   #!/usr/bin/env zsh
#   cluster_name="staging_{{ shard_name }}_shard_r{{ shard_num }}"
#   if [[ $AWS_PROFILE != "{{ STAGING_ROLE }}" ]]; then
#     echo "ERROR: Please authenticate with AWS_PROFILE={{ STAGING_ROLE }}"
#     echo "                        Current AWS_PROFILE=$AWS_PROFILE"
#     exit 1
#   fi
#   echo "bundle exec rake ecspress:console:run:${cluster_name}"
#   bundle exec rake ecspress:console:run:${cluster_name}

# Staging Rails Console
[no-cd]
[group('Staging')]
@staging_console:
  echo "\n\n📝 NOTE: Once the bash prompt opens run the following ot open a rails console:\n\tbundle exec rails c\n\n"
  just staging_shell

# Open a production console on given shard
[no-cd]
[group('Production')]
prod_shell shard_num='0' shard_name="internal":
  just ecspress_shell 'production' "{{ shard_num }}" "{{ shard_name }}"

# Production Rails Console
[no-cd]
[group('Production')]
@prod_console:
  echo "\n\n📝 NOTE: Once the bash prompt opens run the following ot open a rails console:\n\tbundle exec rails c\n\n"
  just prod_shell
