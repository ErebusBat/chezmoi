# chezmoi

This repo manages my home directory across multiple machines and work contexts via [chezmoi](https://chezmoi.io/).

See [`AGENTS.md`](AGENTS.md) for full documentation.

## Layout

`.chezmoiroot` selects `home/` as the deployment source. Repository instructions (`AGENTS.md`, `CLAUDE.md`), `direct/`, `bootstrap/`, and documentation remain outside that source root.

`home/symlink_AGENTS.md.tmpl` manages `~/AGENTS.md` from `direct/AGENTS-<hostname>.md` when that machine guide exists. Each guide contains home/machine guidance only. There is no repository-guide fallback.

Templates referencing `direct/` use `.chezmoi.workingTree`; `.chezmoi.sourceDir` now points to `home/`. Use `git diff` to review linked document content and `chezmoi diff` to review deployed files and links.

## Quick Reference

```bash
chezmoi apply              # Apply source to home directory
chezmoi apply --dry-run    # Preview changes
chezmoi diff               # Show diff between source and target
chezmoi add ~/.some/file   # Add a file to chezmoi management
```

Changes to this repo are auto-committed and pushed on `chezmoi apply`.
