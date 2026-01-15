NVM_DIR="$HOME/.nvm"
if [[ ! -d $NVM_DIR ]]; then return 0; fi
export NVM_DIR
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
