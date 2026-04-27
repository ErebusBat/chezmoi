# AGENTS.md

This file provides guidance to OpenCode agents working in this home directory.

## Shell Management

This machine's shell configuration is managed by **chezmoi**.

- Do not append installer snippets directly to `~/.zshrc`
- Do not patch shell startup files in `$HOME` unless the change is being made through the chezmoi source tree
- Prefer updating `~/.local/share/chezmoi/` source files and then applying them with chezmoi

## PATH Conventions

PATH is intentionally managed in layers:

- Early critical paths are set in `~/.zshrc`
- Shared aliases and fallback PATH behavior live in `~/.config/zsh-antibody/aliases/aliases.plugin.zsh`
- Tool-specific PATH additions should usually live in a dedicated zsh-antibody plugin

When a third-party installer says to add something to `~/.zshrc`, translate that into one of these managed locations instead.

## OCX

Reference docs: https://ocx.kdco.dev/docs/getting-started/installation

The OCX install script recommends:

- `curl -fsSL https://ocx.kdco.dev/install.sh | sh`
- or `npm install -g ocx`

Important local rule:

- Do not let the installer modify `~/.zshrc`

If OCX needs PATH wiring:

- Prefer an existing managed PATH location like `~/.local/bin`
- Otherwise add a dedicated zsh-antibody plugin under `~/.config/zsh-antibody/`
- If a shell helper is needed, keep it in chezmoi source, not in an ad hoc installer-managed block

The installer script currently defaults to:

- `/usr/local/bin` when writable
- otherwise `~/.local/bin`

Both are preferable to editing `~/.zshrc` directly in this setup.
