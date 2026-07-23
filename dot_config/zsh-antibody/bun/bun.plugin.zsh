# bun completions
export BUN_INSTALL="$HOME/.bun"
if [[ ! -d $BUN_INSTALL ]]; then
  unset BUN_INSTALL
  return 0
fi

if [ -s "~/.bun/_bun" ]; then
  if ! (( $+functions[compdef] )); then
    function compdef() { }
    source "~/.bun/_bun"
    unfunction compdef
  else
    source "~/.bun/_bun"
  fi
fi

# bun
export PATH="$BUN_INSTALL/bin:$PATH"
alias claude-mem='~/.bun/bin/bun "~/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

