if ! command -v herdr 2>&1 >/dev/null; then return 0; fi

echo "Installing Herdr Plugin..."
alias hr='herdr'
