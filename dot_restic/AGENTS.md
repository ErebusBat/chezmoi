# Repository Guidelines

## Project Overview

Profile-based restic backup system for macOS. Thin shell scripts wrap restic for encrypted off-site backups to rsync.net. Architecture is deliberately simple — profiles handle credentials, schedules define what to back up, and a small orchestrator (`backup`) ties them together. The entire system is readable, auditable, and modifiable in minutes.

**Primary maintainer:** Andrew Burns

---

## Architecture & Data Flow

### How a backup runs

```
backup lshq hourly
  │
  ├─ 1. Validates profile-lshq.sh + lshq-hourly.sh exist
  ├─ 2. Sources profile-lshq.sh → sets RESTIC_REPOSITORY, RESTIC_PASSWORD_FILE
  ├─ 3. Resolves `restic` binary (mise → $HOME/bin → error)
  ├─ 4. Prints banner with repo info
  └─ 5. Execs lshq-hourly.sh → runs restic backup with schedule's paths/flags
```

### Batch mode

```
backup-all daily
  │
  ├─ Discovers every *-daily.sh with a matching profile-*.sh
  │  (e.g., lshq-daily.sh, erebusbat-daily.sh)
  ├─ Runs each sequentially via `backup $profile daily`
  └─ Collects failures; prints summary at end
```

### File naming convention

| Pattern | Purpose | Example |
|---|---|---|
| `profile-$NAME.sh` | Repository credentials (URL, key) | `profile-lshq.sh` |
| `$NAME-$SCHEDULE.sh` | What to back up, how often | `lshq-daily.sh` |
| `$NAME-excludes.lst` | Restic exclude patterns | `home-excludes.lst` |
| `.$NAME.key` | Encryption key (0400) | `.lshq.key` |

### Scheduling stack

- **macOS LaunchAgents** — plists in `~/Library/LaunchAgents/` trigger `backup-all hourly`, `backup-all daily`, `backup-all 15m`
- **`backup-status`** — monitors LaunchAgent health, colored table of last run times and exit codes
- **`agent-kick`** — watchdog script that SIGKILLs stuck agents past a threshold (relies on plist WatchPaths to restart)
- **`kick-restic-agents.sh`** — calls `agent-kick` for all three tiers with appropriate thresholds

---

## Key Directories

```
~/.restic/
├── backup                        # Main orchestrator (thin wrapper)
├── backup-all                    # Batch runner (all profiles, one schedule)
├── backup-status                 # LaunchAgent health monitor
├── agent-kick                    # Per-agent watchdog
├── kick-restic-agents.sh         # Multi-agent kicker
│
├── profile-lshq.sh               # LSHQ repository credentials
├── profile-erebusbat.sh          # Erebusbat repository (rsync.net)
├── profile-erebusbat-s3.sh       # Erebusbat repository (S3/MinIO fallback)
├── profile-TEMPLATE.sh           # Template for new profiles
│
├── lshq-15m.sh                   # lshq: fast tier (15-min cadence)
├── lshq-hourly.sh                # lshq: source trees
├── lshq-daily.sh                 # lshq: full home directory
├── lshq-docs.sh                  # lshq: docs directory
├── erebusbat-15m.sh              # erebusbat: Obsidian vault
├── erebusbat-hourly.sh           # erebusbat: source + MCP backups
│
├── home-excludes.lst             # Full $HOME exclude patterns (daily)
├── src-excludes.lst              # Source tree build artifacts
├── common-excludes.lst           # Shared patterns (15m tier)
├── 15m-excludes.lst              # 15m-tier-specific excludes
│
├── .lshq.key                     # Encryption key (mode 0400)
├── .erebusbat.key                # Encryption key (mode 0400)
│
├── .restic-env                   # Bootstrap — ensures restic binary available
├── mise.toml                     # OCP_PROFILE=personal
│
├── restic-multi.rb               # LEGACY Ruby multi-target orchestrator
├── .freenas_cifs_shell.env       # LEGACY FreeNAS credentials
├── .freenas-minio-creds.env      # LEGACY MinIO credentials
│
├── Makefile                      # Convenience targets (status, run-*)
├── README.md                     # Usage documentation
├── PRD.md                        # Design document
├── CLAUDE.md                     # Agent context
└── AGENTS.md                     # This file
```

---

## Development Commands

### Running backups

```bash
# Single profile
./backup lshq hourly

# All profiles for a schedule
./backup-all daily

# List available combinations
./backup --list

# Dry-run
./backup lshq daily --dry-run
```

### Monitoring

```bash
# Health check (colored table)
./backup-status

# Tail logs
tail -f /tmp/local.restic.hourly.log
tail -f /tmp/local.restic.daily.log
```

### Manual triggers (via launchd)

```bash
make run-15m
make run-hourly
make run-daily
```

### Status

```bash
make status        # same as ./backup-status
```

### Generate encryption key

```bash
make newkey
```

### Testing

```bash
# Direct dry-run on a schedule script (restic supports --dry-run natively)
./lshq-daily.sh --dry-run

# Test exclude patterns against a temp repo
mkdir -p /tmp/test-repo
RESTIC_REPOSITORY="local:///tmp/test-repo" \
  RESTIC_PASSWORD_FILE=~/.restic/.lshq.key \
  restic init 2>/dev/null
RESTIC_REPOSITORY="local:///tmp/test-repo" \
  RESTIC_PASSWORD_FILE=~/.restic/.lshq.key \
  restic backup --dry-run --verbose \
  --exclude-file=home-excludes.lst --exclude-caches "$HOME/.omp" 2>&1
```

---

## Code Conventions & Common Patterns

### Shell scripting

- **Shebang**: `#!/bin/bash` (except `agent-kick` and `kick-restic-agents.sh` which use `#!/usr/bin/env zsh` for zsh-specific features)
- **Strict mode**: `set -euo pipefail` at top of every script
- **Path resolution**: `cd "$(dirname "$0")" && pwd` to find own directory
- **No abstraction layers**: Schedule scripts call `restic` directly — you see the exact command
- **No config file formats**: Profiles are sourced shell scripts, not YAML/JSON
- **`exec` pattern**: Last command in schedule scripts uses `exec restic backup ...` for clean process tree and signal handling (optional, exit codes propagate correctly either way with `set -e`)
- **Error handling**: Fail fast via `set -e`; `backup-all` collects failures post-loop across all profiles and prints a summary
- **Exit codes**: Pass through from restic to caller (used by LaunchAgent monitoring)

### Naming

| Convention | Example | Rule |
|---|---|---|
| Profile files | `profile-{name}.sh` | Lowercase, no spaces |
| Schedule files | `{name}-{schedule}.sh` | e.g. `lshq-daily.sh` |
| Tags | `{name}`, `auto` | restic `--tag` flags |
| Exclude files | `{scope}-excludes.lst` | e.g. `home-excludes.lst` |
| Key files | `.{name}.key` | Mode 0400 |

### Restic conventions

- **Tags**: Always tag with schedule name (e.g., `daily`, `hourly`, `15m`) and `auto`
- **Exclude caches**: `--exclude-caches` on every backup (respects `CACHEDIR.TAG`)
- **Exclude files**: Referenced via `$RESTIC_DIR/` (set by `backup` wrapper)
- **Repository**: Set in profile via `RESTIC_REPOSITORY` environment variable
- **Auth**: Password file at `RESTIC_PASSWORD_FILE` (key file, 0400 permissions)

### Security

- Encryption keys stored in `~/.restic/.{name}.key` at mode 0400
- Master copies in 1Password
- Profile scripts contain no secrets — only paths to key files
- Exception: `profile-erebusbat-s3.sh` embeds plain-text AWS credentials (known issue)
- Schedule scripts are safe to share/version (no credentials)

---

## Important Files

### Entry points

| File | Purpose |
|---|---|
| `~/.restic/backup` | Primary entry: `backup lshq hourly` |
| `~/.restic/backup-all` | Batch: `backup-all daily` |
| `~/.restic/backup-status` | Monitoring |
| `~/Library/LaunchAgents/local.restic.{15m,hourly,daily}.plist` | Scheduling (macOS) |

## Profiles & Jobs

Each profile maps to one restic repository. Each job within a profile is a shell script that runs `restic backup` with specific paths and options. Jobs are tiered by cadence (15m → hourly → daily → docs) — faster tiers cover less data.

### Profile: `lshq`

**Repository:** `sftp://rsyncnet/restic/lshq`
**Key:** `~/.restic/.lshq.key`
**Target:** rsync.net (off-site SFTP)
**Host tag:** `$(hostname -s)`

| Job | Cadence | What backs up | Excludes | Tags |
|-----|---------|---------------|----------|------|
| **15m** | Every 15 min | `~/Documents/meetings` — meeting notes<br>`~/.pi` — Pi CLI data directory<br>`~/src` — all source trees<br>`~/Library/Application Support/OpenOats` — Oats app data | `common-excludes.lst` + `15m-excludes.lst` + `--exclude-larger-than 50M` + `**/.git/**/*` | `15m`, `auto` |
| **hourly** | Every 60 min | `~/src/lshq/` — LightspeedHQ source trees (pos-service, mad-venus, garden, etc.) | `src-excludes.lst` | `hourly`, `auto` |
| **daily** | Every 24h | `$HOME` — entire home directory (filtered through excludes) | `home-excludes.lst` + `src-excludes.lst` | `daily`, `auto` |
| **docs** | On demand | `~/src/lshq/docs` — documentation repo | `src-excludes.lst` | `docs` |

**Notes on lshq tiers:**
- 15m catches frequently-changing small data (meetings, source edits, CLI tool state) with aggressive size and git-exclude filtering so it completes fast
- hourly captures the primary work source tree with build artifact exclusions
- daily is the comprehensive safety net — full home directory minus caches, toolchains, and rebuildable artifacts
- docs runs separately for the documentation repo with a Slack notification (`~/bin/dlog`)

### Profile: `erebusbat`

**Repository:** `sftp://rsyncnet/restic/erebusbat`
**Key:** `~/.restic/.erebusbat.key`
**Target:** rsync.net (off-site SFTP)
**Host tag:** `$(hostname -s)`

| Job | Cadence | What backs up | Excludes | Tags |
|-----|---------|---------------|----------|------|
| **15m** | Every 15 min | `~/Documents/Obsidian` — Obsidian vault (personal wiki, notes) | `--exclude-caches` only | `obsidian`, `auto` |
| **hourly** | Every 60 min | `~/src/erebusbat/` — personal projects source tree<br>`~/.local/share/mcp-memory-service/db/backups` — MCP memory service database dumps | `src-excludes.lst` | `hourly`, `auto` |

**Notes on erebusbat tiers:**
- 15m is specifically the Obsidian vault — small text files that change frequently during note-taking, no heavy excludes needed
- hourly covers personal source code plus the MCP semantic memory database backups

### Profile: `erebusbat-s3`

**Repository:** `s3:https://rustfs.erebusbat.net/restic/erebusbat`
**Key:** `~/.restic/.erebusbat.key`
**Auth:** Embedded `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` (plain text in script)
**Target:** Self-hosted RustFS S3-compatible storage
**Status:** No schedule scripts exist — manual/inactive fallback profile

This is an alternative repository for the same erebusbat dataset. It exists as a secondary target option but has no active scheduled jobs. Use it manually:
```bash
source ~/.restic/profile-erebusbat-s3.sh
restic backup --tag manual $HOME/Documents
```

**⚠ Plain-text AWS credentials** — known issue; profile contains hardcoded access keys.

### Profile: `TEMPLATE`

Template for creating new profiles. Copy to `profile-{name}.sh`, set repository URL and key path, then create matching schedule scripts.

---
### Exclude file structure

| File | Size | Scope | Key categories |
|---|---|---|---|
| `home-excludes.lst` | 9.9K | Full $HOME | System caches, toolchains (`.rustup`, `.cargo`, `.kube`), browser data, MacOSX Library, OMP rebuildable assets, Docker/OrbStack |
| `src-excludes.lst` | 688B | Source trees | Build artifacts, vendored dependencies |
| `common-excludes.lst` | 753B | 15m tier | `.DS_Store`, caches, `node_modules`, `*.db-shm`, `*.log`, `*.pid` |
| `15m-excludes.lst` | 331B | 15m tier | Large src subdirs, audio files, `_cacache`, `sshuttle-venv` |

---

## Runtime/Tooling Preferences

### Required runtime
- **macOS** (LaunchAgent scheduling, launchctl)
- **bash** (primary runtime for scripts)
- **zsh** (used by `agent-kick`, `kick-restic-agents.sh`)
- **restic** — resolved via `mise` → `$HOME/bin/` → hard fail
- SSH access to rsync.net (key at `~/.ssh/id_rsync_ed25519`, alias `rsyncnet`)

### Tooling constraints
- **No CI/CD** — no CI pipeline or GitHub Actions configured
- **Not a git repo** — `~/.restic/` is not version controlled; profiles and excludes managed as static files
- **macOS only** — LaunchAgent plists and `launchctl` conventions; Makefile uses `launchctl start` for triggers
- **Ruby not required** — `restic-multi.rb` is legacy, `~/.restic-multi.yml` does not exist

---

## Testing & QA

- **No formal test framework** — this is a shell-script backup system
- **Testing method**: Run schedule scripts directly with restic's `--dry-run` flag
- **Exclude verification**: Real backup to a `local://` temp repository, then `restic ls` to inspect
- **Monitoring**: `backup-status` reads LaunchAgent exit codes — failures surface as non-zero exit and colored table
- **Watchdog**: `agent-kick` detects hung processes by comparing `ps -o etime=` against a threshold; stuck agents are SIGKILL'd

---

## Legacy Systems

### restic-multi.rb (being phased out)

Ruby wrapper for multi-target backups driven by YAML config. Supports MinIO, USB, B2, and local targets with availability checking, pre/post hooks, and named retention policies. No longer in active use — `~/.restic-multi.yml` does not exist on this machine.

### Why the new approach replaced it

| Concern | Shell profile-based | Ruby multi-target |
|---|---|---|
| Dependencies | bash + restic only | Ruby + gems + YAML |
| Transparency | `cat lshq-daily.sh` shows the exact restic command | YAML indirection layer |
| Maintenance | Edit one shell file | Edit YAML, possibly Ruby |
| Use case | Single target (rsync.net) | Multi-target orchestration |
