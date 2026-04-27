# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## What This Is

This is a **chezmoi** dotfiles repository (`~/.local/share/chezmoi`) that manages the home directory for multiple machines and work contexts. The GitHub remote is `ErebusBat/chezmoi`.
This repo is more than static dotfiles: it is the control plane for shell startup, package bootstrapping, workstation layout, backup orchestration, and machine-specific behavior.

## Key Chezmoi Commands

```bash
chezmoi apply              # Apply changes from source to home directory
chezmoi apply --dry-run    # Preview what would change
chezmoi diff               # Show diff between source state and destination
chezmoi add ~/.some/file   # Add a file to chezmoi management
chezmoi edit ~/.some/file  # Edit the source version of a managed file
chezmoi data               # Show template data (useful for debugging templates)
chezmoi execute-template < file.tmpl  # Test a template
```

The chezmoi config (`.chezmoi.toml.tmpl`) sets `git.autoAdd = true`, `git.autoCommit = true`, and `git.autoPush = true`, so `chezmoi apply` will automatically commit and push changes.
In restricted or offline environments, those git/push steps may fail even when the local source changes are correct.

## Architecture & Conventions

### Chezmoi Naming Conventions
- `dot_` prefix → `.` in target (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_` prefix → restrictive permissions (e.g., `private_dot_ssh/`)
- `executable_` prefix → executable bit set on target
- `symlink_` prefix → creates a symlink (target path is the file content)
- `.tmpl` suffix → processed as a Go template
- `run_` prefix → scripts executed by chezmoi (not installed as files)
- `run_onchange_` → re-run only when template content changes (uses sha256sum hash comments to detect changes in external files)

### Template Data & Multi-Context System
The `.chezmoi.toml.tmpl` prompts for `email` and `focus` on init. The `focus` value (e.g., `personal`, `server`, `companycam`, `lshq`) drives conditional inclusion throughout:

- **`.data.area.*`** booleans (`personal`, `server`, `fetlife`, `tractionguest`, `companycam`, `lshq`) control which files are ignored via `.chezmoiignore` and which sections of `Brewfile.tmpl` are active
- **`.data.focus`** determines the active warp directory set (`direct/warprc_<focus>`) symlinked as `~/.warprc`
- Templates use `{{ if .area.personal }}` / `{{ if eq .focus "server" }}` guards
- `focus` is effectively the machine/work-context selector; treat it as the top-level switch for what this machine should be.

### Run Scripts (Orchestration)
- `run_000_calc_zsh_shas.sh.tmpl` — Runs first (000 prefix), calculates sha checksums for zsh plugin files so onchange scripts can detect modifications
- `run_001_bootstrap_fixes.sh` — Creates small bootstrap prerequisites before other tooling expects them
- `run_onchange_brew_bundle.sh.tmpl` — macOS only, runs `brew bundle` when `~/Brewfile` changes
- `run_onchange_zsh_rebuild.sh.tmpl` — Re-bundles antidote (zsh plugin manager) when plugin config changes
- `run_onchange_lazy_nvim.sh.tmpl` — Restores NeoVim Lazy.nvim plugin state when `lazy-lock.json` changes
- `run_onchange_mise_install.sh.tmpl` — Runs `mise install` when mise config changes
- `run_onchange_mise_update.sh.tmpl` — Periodically bumps mise-managed tools using a rendered time bucket
- `run_onchange_bin_ensure.sh.tmpl` — Runs `~/bin/bin ensure` when bin config changes
- `run_onchange_chrony_cfg.sh.tmpl` — macOS, symlinks chrony config into `/etc/chrony.d/` (requires sudo)

These scripts are important to how this repo works. `chezmoi apply` is effectively a workstation reconcile step, not just a file copy.

### External Dependencies (`.chezmoiexternal.toml`)
Git repos cloned/updated automatically: diff-so-fancy, tmux plugin manager (tpm), tmux themes, base16-shell, scm_breeze, antidote (zsh plugin manager), plex-nowplaying, dlog-ruby. Linux-only: ncdu binary, neovim appimage.

### Directory Layout
- **`bin/`** — Executable scripts installed to `~/bin/` (prefixed `executable_`)
- **`dot_config/`** — `~/.config/` contents: nvim, tmux, ghostty, starship, mise, zsh-antibody plugins, fzf, etc.
- **`dot_config/zsh-antibody/`** — ZSH plugin system: `plugins.txt` defines load order, subdirectories are individual plugin configs (aliases, git, docker, rails, etc.)
- **`private_dot_ssh/`** — SSH config using `assh` (Advanced SSH Config); `assh.yml` includes files from `assh.d/`
- **`dot_tmuxp/`** — tmuxp session layouts (YAML files, `_` prefix = disabled/ignored)
- **`direct/`** — Source-controlled support files used by managed configs: Warp directory maps, host-specific `bin` configs, restic dataset YAMLs, cron snippets, and similar machine-specific data
- **`private_Library/`**, **`private_Downloads/`** — macOS-specific managed files
- **`src/`** — Local source tree pointers and support files; the actual home directory also has large working trees under `~/src/erebusbat`, `~/src/lshq`, and `~/src/sie`
- **`bootstrap/`** — New machine bootstrap instructions and minimal Brewfile

### Day-To-Day Operating Model
- Shell startup is intentionally split into source-of-truth files plus generated artifacts
- `dot_zshrc` boots critical PATH entries first, initializes `mise` early, then loads a compiled zsh plugin bundle
- `dot_config/zsh-antibody/plugins.txt.tmpl` is the plugin manifest; `.plugins.zsh`, `.zcompdump`, and `.shasum` are generated state
- The zsh-antibody `justfile` is the maintenance entry point for cleaning and rebuilding generated shell artifacts
- `dot_config/wezterm/wezterm.lua` uses a host-aware module loader so machine-specific overrides can exist without forking the whole config
- AeroSpace, WezTerm, tmux, Warp, and startup scripts are designed to make the workstation land in a known layout quickly

### Launchd / Scheduled Automation
- This repo contains some LaunchAgent source files, but not every active LaunchAgent on the machine is managed here
- `.chezmoiignore` intentionally excludes several `Library/LaunchAgents/*.plist` files
- Active LaunchAgents in `~/Library/LaunchAgents` currently include restic schedules, Obsidian automation, and WezTerm wallpaper rotation
- The general pattern is: launchd schedules a thin wrapper, and the wrapper calls a reusable script or Ruby tool owned by this setup

### Backup / Restic Conventions
- `dot_restic/` is a real subsystem, not a couple of helper scripts
- `executable_restic-multi.rb` is the reusable orchestrator for datasets, targets, policies, availability checks, and retention actions
- Host-specific backup definitions live under `direct/restic-multi-*.yml`
- LaunchAgents typically call `~/.restic/backup-all` or kick helper scripts, which then delegate into the shared restic tooling
- Backups are environment-aware: targets can be enabled/disabled, ping-checked, or local-path checked before use

### Source Code Layout In Practice
- `~/src/erebusbat` is the large personal/project root for your own tooling and services
- `~/src/lshq` is the large work tree for LightspeedHQ-related repos
- `~/src/sie` is a smaller work-context root, with supporting scripts also mirrored in this chezmoi repo
- Warp shortcuts, tmuxp sessions, startup scripts, and backup datasets all assume these roots exist and are part of the normal workflow

### Secrets Management
Secrets are managed via **gopass** (GPG-encrypted), accessed in templates with `{{ gopassRaw "path" }}`. SSH private keys use `.tmpl` suffix with gopass lookups. The GPG key for gopass is stored in 1Password.

Also note:
- Some scripts read secrets indirectly through generated files under `~/.config`, `~/.ssh`, or `~/.restic`
- `dot_config/tmux/dot_executable_init_chezmoi_secrets.sh` and related startup hooks are part of the secret/bootstrap path

### `.chezmoiremove`
Lists files that chezmoi should actively **remove** from the target. Used for cleanup of deprecated configs.

## Editing Guidelines

- **Always edit source files here**, never edit `~/` targets directly (chezmoi will overwrite them)
- Template files (`.tmpl`) use Go template syntax — test with `chezmoi execute-template`
- When adding area-conditional files, update both `.chezmoiignore` (to exclude from other areas) and `Brewfile.tmpl` (if packages are needed)
- The `Brewfile.tmpl` has a warning comment: "THIS FILE IS TEMPLATED, DO NOT EDIT DIRECTLY!" — the source of truth is here in chezmoi
- ZSH plugin load order matters — see `dot_config/zsh-antibody/plugins.txt` comments
- Prefer preserving the generated-artifact workflow instead of replacing it with ad hoc startup logic
- When changing scheduled behavior, check both managed LaunchAgent source files and unmanaged live `~/Library/LaunchAgents` files so you do not assume everything is tracked here
- When changing workstation flow, inspect the interaction between AeroSpace, tmuxp, Warp shortcuts, WezTerm modules, and `~/bin` helper scripts
