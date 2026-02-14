# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

This is a **chezmoi** dotfiles repository (`~/.local/share/chezmoi`) that manages the home directory for multiple machines and work contexts. The GitHub remote is `ErebusBat/chezmoi`.

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

### Run Scripts (Orchestration)
- `run_000_calc_zsh_shas.sh.tmpl` — Runs first (000 prefix), calculates sha checksums for zsh plugin files so onchange scripts can detect modifications
- `run_onchange_brew_bundle.sh.tmpl` — macOS only, runs `brew bundle` when `~/Brewfile` changes
- `run_onchange_zsh_rebuild.sh.tmpl` — Re-bundles antidote (zsh plugin manager) when plugin config changes
- `run_onchange_lazy_nvim.sh.tmpl` — Restores NeoVim Lazy.nvim plugin state when `lazy-lock.json` changes
- `run_onchange_mise_install.sh.tmpl` — Runs `mise install` when mise config changes
- `run_onchange_bin_ensure.sh.tmpl` — Runs `~/bin/bin ensure` when bin config changes
- `run_onchange_chrony_cfg.sh.tmpl` — macOS, symlinks chrony config into `/etc/chrony.d/` (requires sudo)

### External Dependencies (`.chezmoiexternal.toml`)
Git repos cloned/updated automatically: diff-so-fancy, tmux plugin manager (tpm), tmux themes, base16-shell, scm_breeze, antidote (zsh plugin manager), plex-nowplaying, dlog-ruby. Linux-only: ncdu binary, neovim appimage.

### Directory Layout
- **`bin/`** — Executable scripts installed to `~/bin/` (prefixed `executable_`)
- **`dot_config/`** — `~/.config/` contents: nvim, tmux, ghostty, starship, mise, zsh-antibody plugins, fzf, etc.
- **`dot_config/zsh-antibody/`** — ZSH plugin system: `plugins.txt` defines load order, subdirectories are individual plugin configs (aliases, git, docker, rails, etc.)
- **`private_dot_ssh/`** — SSH config using `assh` (Advanced SSH Config); `assh.yml` includes files from `assh.d/`
- **`dot_tmuxp/`** — tmuxp session layouts (YAML files, `_` prefix = disabled/ignored)
- **`direct/`** — Files not managed by chezmoi directly; used for symlink targets (e.g., `warprc_*` files) and per-host config JSONs
- **`private_Library/`**, **`private_Downloads/`** — macOS-specific managed files
- **`src/`** — Source code repos (lshq, sie)
- **`bootstrap/`** — New machine bootstrap instructions and minimal Brewfile

### Secrets Management
Secrets are managed via **gopass** (GPG-encrypted), accessed in templates with `{{ gopassRaw "path" }}`. SSH private keys use `.tmpl` suffix with gopass lookups. The GPG key for gopass is stored in 1Password.

### `.chezmoiremove`
Lists files that chezmoi should actively **remove** from the target. Used for cleanup of deprecated configs.

## Editing Guidelines

- **Always edit source files here**, never edit `~/` targets directly (chezmoi will overwrite them)
- Template files (`.tmpl`) use Go template syntax — test with `chezmoi execute-template`
- When adding area-conditional files, update both `.chezmoiignore` (to exclude from other areas) and `Brewfile.tmpl` (if packages are needed)
- The `Brewfile.tmpl` has a warning comment: "THIS FILE IS TEMPLATED, DO NOT EDIT DIRECTLY!" — the source of truth is here in chezmoi
- ZSH plugin load order matters — see `dot_config/zsh-antibody/plugins.txt` comments
