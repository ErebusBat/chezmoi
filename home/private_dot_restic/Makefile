
newkey:
	dd if=/dev/random bs=1024 count=1 2>/dev/null | sha512sum | awk '{print $$1}'

status:
	~/.restic/backup-status

# Manually trigger loaded launch agents
run-15m:
	launchctl start local.restic.15m

run-hourly:
	launchctl start local.restic.hourly

run-daily:
	launchctl start local.restic.daily
