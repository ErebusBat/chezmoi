NVM_DIR="$HOME/.nvm"
if [[ ! -d $NVM_DIR ]]; then return 0; fi
export NVM_DIR

# Lazy-load nvm: define stub functions that load nvm on first use.
# This avoids the ~1s startup cost of nvm_auto running at every shell open.
_nvm_load() {
  unfunction nvm node npm npx yarn pnpm 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

nvm()  { _nvm_load; nvm "$@" }
node() { _nvm_load; node "$@" }
npm()  { _nvm_load; npm "$@" }
npx()  { _nvm_load; npx "$@" }
yarn() { _nvm_load; yarn "$@" }
pnpm() { _nvm_load; pnpm "$@" }

# Add nvm-managed node bins to PATH immediately (without loading nvm)
# so that any installed node/npm versions are accessible without triggering load
if [[ -d "$NVM_DIR/versions/node" ]]; then
  # Use the default alias if it exists
  local nvm_default
  nvm_default=$(cat "$NVM_DIR/alias/default" 2>/dev/null)
  if [[ -n "$nvm_default" && -d "$NVM_DIR/versions/node/$nvm_default/bin" ]]; then
    export PATH="$NVM_DIR/versions/node/$nvm_default/bin:$PATH"
  fi
fi

