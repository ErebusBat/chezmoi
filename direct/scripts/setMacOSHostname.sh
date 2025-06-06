#!/bin/zsh
NEWHN=$1

function printCurrentValues() {
  echo "Current HostName(s):"
  echo -n "     HostName: "
  scutil --get HostName

  echo -n "LocalHostName: "
  scutil --get LocalHostName

  echo -n " ComputerName: "
  scutil --get ComputerName
  cat <<-EOF

  Explaination:
  •	     HostName: The system hostname (e.g., used for SSH and networking).
  •	LocalHostName: The Bonjour name (what other Macs see on the local network, e.g., your-new-hostname.local).
  •	 ComputerName: The name shown in the Finder and system preferences.
EOF
}

if [[ -z $NEWHN ]]; then
  printCurrentValues
  exit 0
fi

echo "Setting new hostname"
sudo scutil --set HostName "$NEWHN"
sudo scutil --set LocalHostName "$NEWHN"
sudo scutil --set ComputerName "$NEWHN"

echo "\n\nAttempting to read set values"
printCurrentValues
