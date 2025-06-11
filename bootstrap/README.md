# Machine Bootstrapping

This folder contains a bare minimum of items to get a new machine / profile setup and working.

## Usage
1. Open *Terminal.app*; Install homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Download `bootstrap/Brewfile`
```bash
curl -O https://raw.githubusercontent.com/ErebusBat/chezmoi/refs/heads/master/bootstrap/Brewfile
```

3. Install bootstrap Brewfile
```bash
brew bundle
```

4. Configure 1password and 1password-cli
    - CLI is optional, but will have to manually locate and download key (see below)


6. Download gopass secret key from 1Password
```bash
op read 'op://Private/Chezmoi gopass GPG Key/ChezmoiSecrets.asc' --out-file=ChezmoiSecrets.asc
```

6. Import key into gpg:
```bash
gpg --import ChezmoiSecrets.asc && rm -v ChezmoiSecrets.asc
```

7. Setup gopass:
```bash
gopass clone git@github.com:ErebusBat/chezmoi-secrets.git
```

8. Setup Chezmoi:
```bash
sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply git@github.com:ErebusBat/chezmoi.git
```

# Mandatory Items
All of these items are *required* to get a system up and running.

## Chezmoi
The dotfile manager.  The entire point of this bootstrap is to get chezmoi to a point where it can get everything else up and running.

## git
Needed to clone other repos

## gopass
Used to manage secrets for chezmoi, uses GPG.

## starship
Prompt config.  It is MUCH easier if this is installed prior to chezmoi setting up ZSH to use it.

## 1Password
Secret and license management.  Holds the secret key for gopass.

Also holds software licences for:
	- [Alfred](https://start.1password.com/open/i?a=O7M3LWL5XZGTZMFHHHVFNNVDL4&v=xdfwrvbi25frrfxyxeyfl66wpe&i=7b2qj7h4vernkp4vxgwdq5jtki&h=erebusbat.1password.com)
	- [Contexts 3](https://start.1password.com/open/i?a=O7M3LWL5XZGTZMFHHHVFNNVDL4&v=xdfwrvbi25frrfxyxeyfl66wpe&i=ettkpqbvtngvbjxuwuaxsda7nu&h=erebusbat.1password.com)
	- [Rectangle Pro](https://start.1password.com/open/i?a=O7M3LWL5XZGTZMFHHHVFNNVDL4&v=xdfwrvbi25frrfxyxeyfl66wpe&i=isl2d3qxvyfbhizgok23nl6sge&h=erebusbat.1password.com)

# Optional Items
These items are not strictly speaking needed to bootstrap a machine; however they do help greatly when standing up a new machine.

## GhosTTY
Getting a "decent" terminal ASAP is a good thing.

### GhosTTY Issues
- *Duplicate Characters on SSH*
	- Run `export TERM=xterm-256color`
	- Should not happen once you are in a tmux session

## Syncthing
Used to keep `Library` in sync.  It is needed for configs of the following:

## Alfred
- License is in 1Password:
	- [Alfred](https://start.1password.com/open/i?a=O7M3LWL5XZGTZMFHHHVFNNVDL4&v=xdfwrvbi25frrfxyxeyfl66wpe&i=7b2qj7h4vernkp4vxgwdq5jtki&h=erebusbat.1password.com)
- Sync config using `Syncthing` (see above)
	- Alfred Preferences => Advanced => Syncing:
	- `Library/A/Alfred/Sync`

## Rectangle Pro
- License is in 1Password:
	- [Rectangle Pro](https://start.1password.com/open/i?a=O7M3LWL5XZGTZMFHHHVFNNVDL4&v=xdfwrvbi25frrfxyxeyfl66wpe&i=isl2d3qxvyfbhizgok23nl6sge&h=erebusbat.1password.com)
- Sync config over iCloud
	- Rectangle Pro => Preferences => General
- Sync config using `Syncthing` (see above)
	- `Library/R/RectangleProConfig.json`
	- IMPORTANT: This is just a backup... use iCloud sync!

## Contexts 3
- License is in 1Password:
	- [Contexts 3](https://start.1password.com/open/i?a=O7M3LWL5XZGTZMFHHHVFNNVDL4&v=xdfwrvbi25frrfxyxeyfl66wpe&i=ettkpqbvtngvbjxuwuaxsda7nu&h=erebusbat.1password.com)
- Can't backup settings to `Library` or iCloud :(
