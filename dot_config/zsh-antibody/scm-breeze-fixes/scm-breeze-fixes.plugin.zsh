# When running in Claude Code, remove all scm_breeze function wrappers
# so that commands like git use the actual binaries instead
if [[ -n $CLAUDE_SESSION_ID ]]; then
  for cmd in "${scmb_wrapped_shell_commands[@]}"; do
    unfunction "$cmd" 2>/dev/null
  done
fi
