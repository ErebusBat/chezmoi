# Simple Shell-Based Backup System

A minimal backup system using shell scripts and restic. Optimized for simplicity and maintainability.

## Quick Start

### Run a backup

```bash
# See what's available
./backup --list

# Run a single profile backup
./backup lshq hourly      # Hourly backup to lshq repository
./backup lshq daily       # Daily full backup
./backup lshq manual      # Manual comprehensive backup

# Run all profiles for a schedule
./backup-all hourly       # Run all profiles with hourly schedules
./backup-all daily        # Run all profiles with daily schedules
./backup-all --list       # Show all available schedules
```

### Create a new schedule

1. Copy an existing schedule script:
   ```bash
   cp lshq-hourly.sh lshq-weekly.sh
   ```

2. Edit it to define what to backup:
   ```bash
   vim lshq-weekly.sh
   ```

3. Make it executable:
   ```bash
   chmod +x lshq-weekly.sh
   ```

4. Run it:
   ```bash
   ./backup lshq weekly
   ```

### Create a new profile/repository

1. Copy the profile template:
   ```bash
   cp profile-TEMPLATE.sh profile-myrepo.sh
   ```

2. Edit repository details:
   ```bash
   vim profile-myrepo.sh
   # Set RESTIC_REPOSITORY and RESTIC_PASSWORD_FILE
   ```

3. Create a schedule script for it:
   ```bash
   cp PROFILE-SCHEDULE.sh.template myrepo-daily.sh
   vim myrepo-daily.sh
   # Update the source line and restic command
   chmod +x myrepo-daily.sh
   ```

4. Run it:
   ```bash
   ./backup myrepo daily
   ```

## File Structure

```
~/.restic/
├── backup                      # Main command (run single profile/schedule)
├── backup-all                  # Run all profiles for a schedule
├── profile-*.sh               # Repository configs (credentials, URLs)
├── *-*.sh                     # Schedule scripts (what to backup)
├── *-excludes.lst             # Exclusion lists
├── .*key                      # Encryption keys
├── PRD.md                     # Full design document
└── README.md                  # This file
```

## How It Works

1. **Main script** (`backup`) sets `$RESTIC_DIR`, sources the profile, validates files exist
2. **Profile files** (`profile-PROFILE.sh`) export environment variables (repository URL, credentials)
3. **Schedule scripts** (`PROFILE-SCHEDULE.sh`) directly execute restic with specific paths/options

That's it. No magic, no abstraction layers. Schedule scripts are pure restic commands.

## Understanding What Gets Backed Up

Just read the schedule script:

```bash
cat lshq-hourly.sh
```

The restic command shows exactly what paths are backed up and with what options.

## Scheduling Automated Backups

### macOS (launchd)

**Recommended**: Use `backup-all` to run all profiles for a schedule:

Create `~/Library/LaunchAgents/local.restic.hourly.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>local.restic.hourly</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/andrew.burns/.restic/backup-all</string>
        <string>hourly</string>
    </array>
    <key>StartInterval</key>
    <integer>3600</integer>
    <key>StandardOutPath</key>
    <string>/tmp/backup-hourly.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/backup-hourly.err</string>
</dict>
</plist>
```

Load it:
```bash
launchctl load -w ~/Library/LaunchAgents/local.restic.hourly.plist
```

**Alternative**: Run a single profile/schedule:
```xml
<key>ProgramArguments</key>
<array>
    <string>/Users/andrew.burns/.restic/backup</string>
    <string>lshq</string>
    <string>hourly</string>
</array>
```

### Linux (cron)

**Recommended**: Use `backup-all`:
```bash
# Hourly - all profiles
0 * * * * /home/user/.restic/backup-all hourly >> /tmp/backup-hourly.log 2>&1

# Daily at 2 AM - all profiles
0 2 * * * /home/user/.restic/backup-all daily >> /tmp/backup-daily.log 2>&1
```

**Alternative**: Run single profile:
```bash
0 * * * * /home/user/.restic/backup lshq hourly >> /tmp/backup-hourly.log 2>&1
```

## Testing

Run schedule scripts directly for testing:

```bash
# Test what a schedule script does
~/.restic/lshq-hourly.sh

# Or use restic's dry-run (add to schedule script)
# exec restic backup --dry-run ...
```

### Note on `exec`

Schedule scripts use `exec` to call restic, which is **optional but recommended**:
- **With `exec`**: Bash process is replaced by restic (cleaner process tree, direct signal handling)
- **Without `exec`**: Works identically for exit codes due to `set -e` and restic being the last command

Use `exec` for cleaner process management, or omit it if you need to add cleanup code after the backup.

## Direct Restic Usage

Since the wrapper sources profiles to set environment variables, you can do the same for direct restic commands:

```bash
# Set up environment
export RESTIC_DIR="$HOME/.restic"
source "$RESTIC_DIR/profile-lshq.sh"

# Run any restic command
restic snapshots
restic restore latest --target /tmp/restore
restic forget --keep-daily 7 --keep-weekly 4 --prune
```

## Current Setup

**Profiles:** lshq

**Schedules:**
- **hourly**: Critical directories (Documents, Projects, .config)
- **daily**: Full home directory with exclusions
- **manual**: Comprehensive backup with verbose output

## Need Help?

- Full design documentation: [PRD.md](PRD.md)
- Templates: `profile-TEMPLATE.sh`, `PROFILE-SCHEDULE.sh.template`
- Restic documentation: https://restic.readthedocs.io/
