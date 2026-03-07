# AGENTS.md

## Zsh Completion Debugging Playbook

When debugging completion issues (especially `wd`), follow this order:

1. Check for managed config drift first:
   - `chezmoi diff ~/.zshrc`
2. Verify `compinit` order:
   - `compinit` must run after plugin `fpath` entries are loaded.
   - Look for unexpected/injected completion blocks near the top of `~/.zshrc`.
3. Inspect completion state in a live shell:
   - `print -r -- "_comps[wd]=${_comps[wd]-<unset>}"`
   - `whence -v wd`
   - `whence -v _wd`
   - `grep -n "\\<wd\\>" ~/.zcompdump`

## Known Issue (2026-03)

- Symptom: `wd` tab completion stopped working.
- Root cause: an unexpected early completion block in `~/.zshrc` ran `compinit` too early.
- Outcome: stale/incorrect completion mapping in `.zcompdump` (`'wd' '_wd.sh'`).
- Resolution path: remove/relocate early `compinit`, then reinitialize completion state.

## Team Rule

- For completion bugs, always run `chezmoi diff ~/.zshrc` first.
