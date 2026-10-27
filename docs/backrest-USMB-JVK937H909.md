# Backrest on USMB-JVK937H909

Chezmoi manages the Backrest Restic wrapper, Seaback catch-up utility, Seaback
exclude list, legacy Seaback manual runner, and Backrest/catch-up LaunchAgents. These files
are restricted to this Mac by `.chezmoiignore`. The README migration section is
also host-specific. Backrest and Restic were already present in Brewfile.

The host-specific `run_once_after_disable_legacy_restic_USMB.sh.tmpl` disables
and unloads the five legacy Restic LaunchAgents. It does not start or restart
Backrest. The current Mac already has those agents disabled and unloaded.

`direct/backrest-USMB-JVK937H909.json` is a recovery fragment containing the nine
plans and repository definitions as of the migration. It is not a complete
Backrest config and is not applied automatically. It has no repository passwords,
login credentials, or sync keys. Repository passwords are referenced through
existing `.restic` key files, whose source templates use gopass.

For recovery, restore Backrest's private config from a backup first, or complete
Backrest setup and pair with maze. Merge this fragment's plans and any missing
repositories by ID through Backrest's config interface. Preserve the current
config version, modification number, authentication, and sync settings. The
`rsyncnet` repository is shared by maze; restore pairing before using that shared
repository. Do not replace the entire live config with this fragment.

The live config, credentials file, success markers, and migration/restore
artifacts are explicitly ignored. Changes made later in the Backrest UI remain
application-owned; refresh the recovery fragment when those changes should be
recorded here. Never add the raw live config to Git.

After restoring the files, load the Backrest LaunchAgent when ready. Its
`BACKREST_RESTIC_COMMAND` setting must point to `~/.restic/backrest-restic`.
Homebrew service reinstallation may regenerate that plist; reapply the managed
plist before loading the service again.

## SeaBack scheduling and catch-up

Backrest owns the native schedules: `seaback-daily` at 17:35 every day and
`seaback-weekly` at 18:35 Wednesday, using the Mac's local clock. Neither plan has
a cadence-gating hook. The restic wrapper retains disk/repository identity,
protected-folder access checks, and sleep prevention; it no longer writes
success markers. Old `daily.success` and `weekly.success` files are unused.
Existing cancelled history is retained.

`~/.restic/backrest-seaback-catchup` checks the mounted SeaBack UUID before
contacting `http://127.0.0.1:9898`. It reads each plan's schedule and operation
history through the API. A successful, non-dry-run backup with a snapshot that
finished after the most recent scheduled occurrence covers that occurrence.
Partial backups and snapshot-index operations do not count. Only daily and
weekly plans are considered; the existing 15-minute plan is unchanged.

`local.backrest.seaback-catchup` runs at login, on volume mounts, and every
15 minutes. It skips running or due/soon queued jobs, allows the native scheduler
five minutes, and waits an hour between failed/cancelled attempts or catch-up
submissions. A lock prevents concurrent utility runs. Before POSTing a backup,
it records the attempt so a lost response does not cause an immediate duplicate.
The API may continue a backup after the client's ten-second timeout. Every retry
checks history again. The native scheduler and API do not provide an atomic
check-and-enqueue operation; the five-minute guard reduces boundary races.

Credentials come from the existing `~/.restic/agent-backrest-creds` file (username
and password on separate lines, mode 0600), which remains outside Git. No new
credentials or successful-backup markers are maintained by this utility.
Submission cooldown data is private runtime state under `~/.restic/seaback/state`.
Unsupported schedule formats stop catch-up rather than guessing. Fixed-time
daily/weekly local cron is supported; changing to other formats requires updating
the utility. Backrest schedules still run normally if the catch-up API is down.

Inspect without triggering backups:

```sh
~/.restic/backrest-seaback-catchup --dry-run
```

Run catch-up immediately:

```sh
~/.restic/backrest-seaback-catchup
```

Logs: `~/Library/Logs/backrest-seaback-catchup.log`.
Tests: `python3 tests/test_backrest_seaback_catchup.py` from the Chezmoi repository.
API reference: https://garethgeorge.github.io/backrest/docs/api
