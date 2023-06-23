PSH_PATH=/usr/local/microsoft/powershell/7/pwsh
if [[ ! -x $PSH_PATH ]]; then return 0; fi
alias pwsh=$PSH_PATH
unset PSH_PATH
