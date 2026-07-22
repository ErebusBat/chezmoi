DEFAULT_SHARD := 'r0'

# Open a rails console on a staging pod in the given shard
[group('Staging')]
staging-console shard='':
    just staging-run '{{shard}}' 'bundle exec rails console'

# Run a command on a random pos-service pod for the given shard
[group('Staging')]
staging-run shard='' cmd='bash':
    #!/usr/bin/env zsh
    k8s_ns=
    shard="{{shard}}"

    # If user did not specify a shard then attempt to get one from current context; or use default
    if [[ -z "$shard" ]]; then
      shard="{{DEFAULT_SHARD}}"
      k8s_ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' | grep . || echo "pos-service-$shard")
    else
      # User specified an explicit shard so use that
      k8s_ns="pos-service-$shard"
    fi

    echo "*** INFO: Running '{{cmd}}' in $k8s_ns"
    kubectl -n $k8s_ns get pod -l "app.kubernetes.io/name=${k8s_ns}-internal" -o json \
      | jq -r --argjson rand $RANDOM '.items[($rand % (.items | length))] | .metadata.name' \
      | xargs -o -I{} kubectl -n $k8s_ns exec -it {} -- {{cmd}}
