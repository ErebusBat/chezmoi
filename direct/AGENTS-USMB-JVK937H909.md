# AGENTS.md — USMB-JVK937H909

Guidance for working in Andrew's home directory on this Mac.

## Disk cleanup on USMB-JVK937H909

Use this section when investigating low disk space, identifying removal targets, or performing an authorized cleanup on this Mac. These notes are machine-specific. Measure current usage before selecting targets; the dated results below are historical, not current free-space estimates.

### Investigation and verification

1. Record available space with `df -k /System/Volumes/Data`. Use the same units and volume for the final measurement.
2. Measure targeted directories with `du -sk`; broad home-directory scans can take minutes. Report macOS privacy-denied paths as unmeasured, including Trash when access is blocked.
3. Inspect Docker with `docker system df`. Inspect local models with `hf cache list` and check model files outside the Hugging Face cache.
4. Separate recreatable caches from project data, model weights, containers, volumes, and personal files. A request to identify targets authorizes investigation; use the user's current cleanup scope for deletion.
5. After cleanup, verify each requested target and any disabled service, then report actual free space and net gain. Docker's reclaimed-byte estimate can differ substantially from the initial estimate and from physical disk recovery; do not add tool totals and call the sum recovered space.

### Cleanup targets

- **uv:** `~/.cache/uv` and `~/.cache/ocpersona/lshq/uv`. Use `uv cache clean --cache-dir <path>` for each authorized cache. Let uv handle in-use checks; avoid forced/manual deletion. Installed environments are separate from these caches.
- **Homebrew:** preview with `HOMEBREW_NO_AUTO_UPDATE=1 brew cleanup --dry-run --prune=all`; execute the same command without `--dry-run` when authorized. It removes eligible old versions, cached downloads, and temporary installation files.
- **Docker unused images:** `docker image prune --all --force` removes images not referenced by containers. Preserve containers and volumes unless separately included in the request. Use supported Docker commands; never delete `~/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw` directly. Its logical size is not its physical allocation. Build cache is a separate target: inspect before deciding whether pruning is useful.
- **Restic cache:** `~/Library/Caches/restic` is recreatable cache, not the backup repositories. Inspect running backups before cleanup; preserve active/new cache files and repository-directory structure. It was retained during the 2026-10-06 cleanup.
- **Browser/media caches:** `~/Library/Caches/Google/Chrome` and `~/Library/Caches/com.spotify.client`. Clear cache through supported app controls where practical, preserving browser profiles, cookies, and user data. Both were retained on 2026-10-06.
- **Xcode:** inspect `~/Library/Developer/Xcode/iOS DeviceSupport`, `DerivedData`, and `~/Library/Developer/CoreSimulator` separately. Device-support files may be recreated when debugging current devices. Simulator data and runtimes require an explicit selection; directory size alone does not establish that they are disposable.
- **Models:** identify each cached repository and weight file before deleting. Stop the process using selected weights and verify it has exited before removing them. Preserve unselected models and project code.

### Nibbler is retired on this Mac

On 2026-10-06, Andrew explicitly discarded Nibbler history because it was not useful. The database, WAL, SHM, and lock file under `~/.local/share/nibbler/` were removed. The LaunchAgent `net.erebusbat.nibbler.scan` was unloaded and persistently disabled; its plist remains at `~/Library/LaunchAgents/net.erebusbat.nibbler.scan.plist`. It previously scanned the home directory every six hours.

Keep that agent disabled unless Andrew asks to resume Nibbler. Verify with `launchctl print-disabled gui/$(id -u)` and `launchctl print gui/$(id -u)/net.erebusbat.nibbler.scan`; the latter should report that the service is absent. Resolve the current UID rather than hardcoding it. If Nibbler storage returns, inspect its processes and scheduling before removing new history. The local launchctl override is machine state, not a chezmoi-managed deployment rule.

### Last completed cleanup: 2026-10-06

- Removed Nibbler history (about 13.9 GiB) and disabled the scan agent.
- Pruned unused Docker images; Docker reported 50.68 GB reclaimed. Containers and volumes were preserved.
- Cleared both uv caches (3.4 GiB and 8.2 GiB) and ran Homebrew cleanup (reported 6.2 GB).
- Stopped the Bonsai local server and removed its two GGUF files under `~/src/vendor/Bonsai-demo/models/bonsai2-gguf/27B/` (about 7.3 GiB). Demo code remains; its launcher needs model weights restored before reuse.
- Preserved Hugging Face models: `unsloth/Qwen3-4B-Instruct-2507-GGUF` (about 2.5 GB), `Qwen/Qwen3-1.7B-MLX-4bit` (about 930 MB), and `unsloth/bge-small-en-v1.5-GGUF` (about 68 MB).
- Verified 97.61 GiB available, a net increase of 69.77 GiB from the pre-cleanup measurement. These values are a dated checkpoint only.
