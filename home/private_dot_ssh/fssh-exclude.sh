# Used by fssh function defined in the aliases zsh plugin

# After editing this file, run `unset FSSH_EXCLUDE` to reload it on the next fssh invocation.
# Sourced by fssh only when FSSH_EXCLUDE is unset.
# Use exact host names or quoted shell patterns. Empty means no exclusions.
FSSH_EXCLUDE=(
  arcade
  retropie
  de4062.rsync.net

  # Git remotes
  gitea
  github-eb
  codeburg-eb

  '*.lan'
  '*.erebusbat.net'
  nuc02
)
