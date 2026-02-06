# bun completions
[ -s "/Users/andrew.burns/.bun/_bun" ] || return 0
if ! (( $+functions[compdef] )); then
  function compdef() { }
  source "/Users/andrew.burns/.bun/_bun"
  unfunction compdef
else
  source "/Users/andrew.burns/.bun/_bun"
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias claude-mem='/Users/andrew.burns/.bun/bin/bun "/Users/andrew.burns/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

