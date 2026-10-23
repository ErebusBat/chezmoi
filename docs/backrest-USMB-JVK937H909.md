# Backrest on USMB-JVK937H909

Chezmoi manages the Backrest Restic wrapper, Seaback cadence helper, Seaback
exclude list, legacy Seaback manual runner, and Backrest LaunchAgent. These files
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
