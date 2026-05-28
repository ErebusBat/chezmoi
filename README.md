# chezmoi

This repo manages my home directory across multiple machines and work contexts via [chezmoi](https://chezmoi.io/).

See [`AGENTS.md`](AGENTS.md) for full documentation.

## Quick Reference

```bash
chezmoi apply              # Apply source to home directory
chezmoi apply --dry-run    # Preview changes
chezmoi diff               # Show diff between source and target
chezmoi add ~/.some/file   # Add a file to chezmoi management
```

Changes to this repo are auto-committed and pushed on `chezmoi apply`.
