
install:
	sudo gem install hashie

newkey:
	dd if=/dev/random bs=1024 count=1 2>/dev/null | sha512sum | awk '{print $$1}'

15m:
	~/.restic/backup erebusbat 15m

load15m:
	launchctl load -w ~/Library/LaunchAgents/local.restic.15m.plist

unload15m:
	launchctl unload ~/Library/LaunchAgents/local.restic.15m.plist

status:
	~/.restic/backup-status
