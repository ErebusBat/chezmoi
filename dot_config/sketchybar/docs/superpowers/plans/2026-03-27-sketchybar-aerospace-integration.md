# SketchyBar AeroSpace Integration Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Mission Control/yabai workspace UI with AeroSpace-driven workspace groups that show only populated workspaces, highlight focused workspace, mark focused monitor, and support click-to-switch.

**Architecture:** A single plugin entrypoint (`plugins/aerospace.sh`) performs one refresh pass: gather AeroSpace state, compute grouped monitor/workspace model, then apply SketchyBar item lifecycle changes (create/update/remove) atomically. `sketchybarrc` wires one dynamic workspace area to this script and preserves existing non-workspace items. A tiny shell test harness validates parser/grouping behavior from fixtures.

**Tech Stack:** SketchyBar config/scripts (POSIX shell), AeroSpace CLI, `just` task runner.

---

## File Structure

- Modify: `sketchybarrc`
  - Remove current Mission Control `space` loop and yabai click behavior.
  - Add AeroSpace workspace container item wiring to `plugins/aerospace.sh`.
- Create: `plugins/aerospace.sh`
  - Single refresh entrypoint (`--refresh` and default event invocation path).
  - Data fetch, parse, sort, render, stale-item cleanup, degraded mode/logging.
- Modify: `justfile`
  - Keep `refresh-aerospace` and `update` mapped to `plugins/aerospace.sh --refresh`.
- Create: `tests/aerospace/parser_fixtures.sh`
  - Fixture data for monitors/workspaces/windows/focused workspace.
- Create: `tests/aerospace/parser_test.sh`
  - Shell assertions for grouping, ordering, focused-empty behavior, escaping.

## Chunk 1: Core Integration Wiring

### Task 1: Replace Mission Control wiring in `sketchybarrc`

**Files:**
- Modify: `sketchybarrc`

- [ ] **Step 1: Run precondition check for legacy wiring**

Run: `grep -n "plugins/space.sh\|yabai -m space --focus" sketchybarrc`
Expected: if matches exist, remove in Step 2; if no matches, continue.

- [ ] **Step 2: Remove legacy space component loop and add AeroSpace item bootstrap**

Use this target structure in `sketchybarrc`:

```sh
PLUGIN_DIR="$CONFIG_DIR/plugins"

# Workspace area bootstrap (dynamic items managed by plugins/aerospace.sh)
sketchybar --add event aerospace_workspace_change

sketchybar --add item aerospace.root left \
           --set aerospace.root script="$PLUGIN_DIR/aerospace.sh" \
                                 update_freq=2 \
                                 label.drawing=off \
                                 icon.drawing=off \
           --subscribe aerospace.root routine aerospace_workspace_change

# Force first render after startup (safe before Task 2 lands)
if [ -x "$PLUGIN_DIR/aerospace.sh" ]; then
  "$PLUGIN_DIR/aerospace.sh" --refresh
fi
```

- [ ] **Step 3: Run integration check to verify legacy wiring is gone**

Run: `grep -n "plugins/space.sh\|yabai -m space --focus" sketchybarrc`
Expected: no matches.

- [ ] **Step 4: Validate config syntax at runtime**

Run: `sketchybar --reload`
Expected: command succeeds without syntax errors.


### Task 2: Implement `plugins/aerospace.sh` refresh pipeline

**Files:**
- Create: `plugins/aerospace.sh`

- [ ] **Step 1: Write failing smoke test for missing script**

Run: `test -x plugins/aerospace.sh`
Expected: non-zero (script not executable yet).

- [ ] **Step 2: Implement minimal executable script skeleton**

```sh
#!/bin/sh
set -eu

LOG_FILE="/tmp/sketchybar-aerospace.log"
STATE_FILE="/tmp/sketchybar-aerospace-items.state"
LAST_TS_FILE="/tmp/sketchybar-aerospace-last-refresh.ts"

now_ms() { python3 -c 'import time; print(int(time.time()*1000))'; }

log() {
  [ "${AEROSPACE_WS_DEBUG:-0}" = "1" ] || return 0
  level="$1"; shift
  msg="$*"
  [ -f "$LOG_FILE" ] && [ "$(wc -c < "$LOG_FILE")" -gt 262144 ] && : > "$LOG_FILE"
  printf '%s [%s] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$level" "$msg" >> "$LOG_FILE"
}

refresh() {
  : # implemented in later steps
}

case "${1:---refresh}" in
  --refresh) refresh ;;
  *) refresh ;;
esac
```

- [ ] **Step 3: Add AeroSpace data gathering and grouping logic (via safe wrapper)**

Implement data fetches through `run_cmd` (same command set):

```sh
monitors_json="$(aerospace list-monitors --json)"
workspaces_json="$(aerospace list-workspaces --all --json)"
focused_workspace_json="$(aerospace list-workspaces --focused --json)"
windows_rows="$(aerospace list-windows --all --format '%{window-id} %{workspace} %{monitor-id}')"

# parse focused workspace from JSON contract
focused_workspace="$(printf '%s' "$focused_workspace_json" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d[0]["workspace"] if d else "")')"
```

`run_cmd` requirements:
- capture stdout/stderr/exit status without terminating under `set -eu`
- return stdout to caller on success
- on failure, allow degraded-mode path in Step 5 to execute

Then compute:
- non-empty workspace set from `windows_rows`
- monitor groups from workspace->monitor mapping
- focused monitor = monitor containing focused workspace, else first monitor
- stable workspace order from `workspaces_json` (do not rely on hash/dictionary iteration)
- focused monitor sorted first, remaining monitors in stable order
- include focused workspace as synthetic entry when empty

- [ ] **Step 4: Add render/apply lifecycle and click scripts**

Rendering contract:
- item names: `aerospace.mon.<monitor-id>`, `aerospace.ws.<encoded-id>`, `aerospace.divider.<n>`
- all dynamic items are created on the `left` side and kept in one consistent workspace group order per refresh
- focused workspace style must preserve the actual workspace name (for example `>Q<`, not a generic token)
- focused monitor label style (e.g., prefix `*M<id>:`)
- click script: `aerospace workspace '<escaped-workspace>' && sketchybar --trigger aerospace_workspace_change`
- remove stale items listed in `$STATE_FILE` but not in current render pass
- apply all creates/updates/removals through a single batched `sketchybar` invocation per refresh pass

- [ ] **Step 5: Add degraded mode and debouncing**

Rules:
- if last refresh started <200ms ago, skip.
- on command failure: preserve last good items, set root label to `WS: unavailable`.
- on successful refresh: clear degraded label.
- if AeroSpace commands succeed but no populated workspaces exist, set root label to `WS: none` (valid empty state) and clear when data reappears.
- use a safe command wrapper (`run_cmd`) so failures do not terminate script under `set -eu` before degraded rendering.
- parse `windows_rows` defensively: malformed rows are dropped with warning logs while valid rows continue processing.
- degraded mode must set `aerospace.root` to `label.drawing=on label='WS: unavailable'`.
- successful refresh must restore `aerospace.root` to `label.drawing=off`.

Item-id rule (separate from click escaping):
- never use raw workspace text in item names.
- add helper `workspace_item_id()` that encodes workspace names to safe IDs (e.g., hex) and use `aerospace.ws.<encoded-id>`.
- keep original workspace string for display label and click command payload.

- [ ] **Step 6: Make script executable and run smoke test**

Run: `chmod +x plugins/aerospace.sh && test -x plugins/aerospace.sh`
Expected: success.

- [ ] **Step 7: Run script directly and verify no crash**

Run: `plugins/aerospace.sh --refresh`
Expected: exit code 0.

- [ ] **Step 8: Verify single-pass batched apply behavior**

Run: `AEROSPACE_WS_DEBUG=1 plugins/aerospace.sh --refresh`
Expected: debug output indicates one final batched `sketchybar` apply for the refresh pass (no incremental partial redraw loop).


### Task 3: Align `justfile` refresh tasks

**Files:**
- Modify: `justfile`

- [ ] **Step 1: Run precondition check for inconsistent refresh target**

Run: `grep -n "update_all_workspaces\|plugins/space.sh" justfile`
Expected: if matches exist, fix in Step 2; if no matches, continue.

- [ ] **Step 2: Ensure both tasks use `plugins/aerospace.sh --refresh`**

Target:

```make
update:
  plugins/aerospace.sh --refresh

refresh-aerospace:
  plugins/aerospace.sh --refresh
```

- [ ] **Step 3: Verify just tasks run**

Run: `just refresh-aerospace`
Expected: refresh completes successfully.


## Chunk 2: Parser Tests and Behavior Hardening

### Task 4: Add fixture-driven parser tests

**Files:**
- Create: `tests/aerospace/parser_fixtures.sh`
- Create: `tests/aerospace/parser_test.sh`

- [ ] **Step 1: Write test harness with one intentionally failing assertion**

`tests/aerospace/parser_test.sh` scaffold:

```sh
#!/bin/sh
set -eu

fail() { printf 'FAIL: %s\n' "$1"; exit 1; }
pass() { printf 'PASS: %s\n' "$1"; }

. "$(dirname "$0")/parser_fixtures.sh"

# Replace with real function invocations once aerospace.sh exposes helpers
computed="placeholder"
[ "$computed" = "expected" ] || fail "placeholder should fail first"
pass "placeholder"
```

- [ ] **Step 2: Run tests and confirm failure**

Run: `sh tests/aerospace/parser_test.sh`
Expected: FAIL on placeholder assertion.

- [ ] **Step 3: Expose pure helper functions from `plugins/aerospace.sh` for tests**

Add test-mode source guard in `plugins/aerospace.sh`:

```sh
if [ "${AEROSPACE_WS_SOURCE_ONLY:-0}" = "1" ]; then
  return 0 2>/dev/null || exit 0
fi
```

And pure helpers:
- `group_workspaces_by_monitor windows_rows focused_workspace monitors_json`
- `escape_single_quotes workspace_name`

- [ ] **Step 4: Replace placeholder with real assertions**

Assertions to include:
- monitor groups include only populated workspaces
- focused monitor group sorted first
- focused workspace rendered even when empty
- workspace escaping handles single quotes safely

- [ ] **Step 5: Run tests and confirm pass**

Run: `sh tests/aerospace/parser_test.sh`
Expected: all PASS.


### Task 5: End-to-end verification and handoff

**Files:**
- Modify: `plugins/aerospace.sh` (small fixes only)
- Modify: `sketchybarrc` (small wiring fixes only)

- [ ] **Step 1: Run live refresh and inspect resulting items**

Run:
`plugins/aerospace.sh --refresh && sketchybar --query aerospace.root`
Expected: root exists and script is attached.

- [ ] **Step 2: Manual behavior matrix**

Verify manually:
- switch workspaces across monitors
- move windows between workspaces
- change focused monitor
- click workspace labels to switch

Expected: groups and highlights stay consistent with AeroSpace state.

- [ ] **Step 3: Failure-mode check**

Run (simulate unavailable aerospace in subshell):
`PATH="/nonexistent:$PATH" plugins/aerospace.sh --refresh || true`

Expected: degraded mode indicator path executes without deleting last-good item set.

- [ ] **Step 4: Final verification commands**

Run:
- `just refresh-aerospace`
- `sketchybar --update`

Expected: successful refresh and stable UI.

- [ ] **Step 5: Commit**

```bash
git add sketchybarrc plugins/aerospace.sh justfile tests/aerospace/parser_fixtures.sh tests/aerospace/parser_test.sh
git commit -m "feat: drive sketchybar workspaces from aerospace state"
```

#### Execution Notes (2026-03-27)

- Step 1 (`plugins/aerospace.sh --refresh && sketchybar --query aerospace.root`): both commands exited `0`.
- Step 2 manual matrix in CLI harness:
  - switch workspaces across monitors: **simulated refresh path only** (`plugins/aerospace.sh --refresh`), `0`; visual monitor/workspace highlight confirmation remains manual.
  - move windows between workspaces: **not directly simulated** (would require interactive window move in AeroSpace/GUI); visual verification remains manual.
  - change focused monitor: **simulated refresh path only** (`plugins/aerospace.sh --refresh`), `0`; focused monitor marker verification remains manual.
  - click workspace labels to switch: **not directly simulated** (requires bar click event + visible workspace change); click behavior visual verification remains manual.
- Step 3 degraded-mode evidence:
  - added env-guarded test hook in `plugins/aerospace.sh`: `FORCE_DEGRADED=1` (also accepts `AEROSPACE_FORCE_DEGRADED=1`) to force degraded path.
  - baseline state hash before forced degrade: `e54efa15801b3f4fb0d40cec29a50128c50288bf7891da58c5af8de47832a7cf` (`13` lines).
  - forced degraded run (`FORCE_DEGRADED=1 AEROSPACE_WS_DEBUG=1 plugins/aerospace.sh --refresh`) exited `0`; state hash stayed identical; log showed `forcing degraded mode via env` and `entering degraded mode`.
- Step 4 final commands:
  - `just refresh-aerospace` exit `0`.
  - `sketchybar --update` exit `0`.
