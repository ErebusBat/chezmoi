# SketchyBar + AeroSpace Workspace Integration Design

## Goal

Integrate SketchyBar with AeroSpace so workspace display and switching are fully driven by AeroSpace state.

Behavior requirements:
- Show only workspaces that currently contain windows.
- Group workspaces by monitor.
- Highlight the active workspace.
- Indicate the active monitor.
- Clicking a workspace switches to it via AeroSpace.

## Current State

- SketchyBar is using the default Mission Control `space` component pattern in `sketchybarrc`.
- Existing workspace click action is yabai-based (`yabai -m space --focus`).
- `plugins/space.sh` currently only toggles item background based on `$SELECTED` from SketchyBar Mission Control space events.
- AeroSpace is already configured with named persistent workspaces and monitor assignments in `~/.config/aerospace/aerospace.toml`.

## Chosen Approach

Use a single shared SketchyBar workspace area rendered from AeroSpace data, grouped by monitor.

Why this approach:
- Works reliably even when per-display bar scoping is limited or inconsistent.
- Matches desired fallback format (e.g., `P | M | 1 >Q< W`).
- Keeps implementation complexity moderate while preserving extensibility.

## Alternatives Considered

### 1) Per-monitor workspace groups only

- Render separate workspace groups on each monitor and show only local monitor workspaces.
- Pros: cleanest UX.
- Cons: more fragile with display IDs/hot-plug behavior; more complexity.

### 2) Hybrid with auto-fallback

- Prefer per-monitor rendering, fallback to shared rendering when mapping fails.
- Pros: best UX when all dependencies align.
- Cons: highest complexity and debugging cost.

## Data Model

The renderer derives this state on each refresh:

- `monitors`: list of active monitors.
- `workspaces_by_monitor`: only workspaces containing at least one window, grouped by monitor.
- `focused_workspace`: currently focused workspace.
- `focused_monitor`: currently focused monitor.

## Data Sources (Concrete Contract)

The integration will use JSON output from AeroSpace only:

- `aerospace list-monitors --json`
  - Required fields: `monitor-id`, `monitor-name`
- `aerospace list-workspaces --all --json`
  - Required field: `workspace`
- `aerospace list-workspaces --focused --json`
  - Required field: `workspace`
- `aerospace list-windows --all --format '<id><delim><workspace><delim><monitor-id>'`
  - Recommended delimiter: ASCII Unit Separator (`\x1f`) to safely support workspace names with spaces.
  - Parsed fields: `window-id` (int), `workspace` (string), `monitor-id` (int)

Derived structures per refresh:
- `windows_by_workspace[workspace] = count`
- `workspace_monitor[workspace] = monitor-id` (from window rows; for populated workspaces this is authoritative)
- `monitor_groups[monitor-id] = [workspace...]` (populated workspaces only)

Focused monitor resolution:
- Primary: monitor containing at least one window in `focused_workspace`.
- Fallback: first monitor from `list-monitors --json` if focused workspace is empty/unmapped.

Rendering rules:
- Omit empty workspaces.
- Sort monitor groups deterministically (focused monitor first, then stable order).
- Within each group, order workspaces stably by AeroSpace output order.
- Highlight focused workspace with a stronger style (or marker like `>Q<`).
- Mark focused monitor group with a distinct label/style.
- If focused workspace has no windows, still render it in the focused monitor group as a synthetic entry so focus is always visible.

## Interaction Design

- Each workspace label is clickable.
- Click command: `aerospace workspace <workspace-name>`.
- After click, trigger immediate redraw to avoid stale visual state.
- Workspace names in click scripts must be single-quoted and shell-escaped.

## Update Flow

Primary updates:
- Time-based refresh (`update_freq`) for resilience.
- Event-based refresh when supported (workspace/monitor focus and window movement changes).

Fallback strategy:
- If custom AeroSpace events are not practical, keep frequent lightweight polling.

Concrete refresh model:
- Single refresh entrypoint: `plugins/aerospace.sh --refresh`.
- SketchyBar subscription triggers: `routine` (timer) and `forced` redraw (`sketchybar --trigger aerospace_workspace_change` after click).
- Poll cadence: `update_freq=2` seconds.
- Debounce guard: if the previous refresh started <200ms ago, skip (prevents racey duplicate renders).
- Refresh writes the full target state in one `sketchybar` invocation batch.

## Error Handling

- If AeroSpace command execution fails, keep previous successful render and show a compact degraded indicator (`WS: unavailable`) instead of clearing items.
- Write stderr/debug output to `/tmp/sketchybar-aerospace.log`.
- Guard against partial parses (empty lines, malformed fields, transient command failures).

Failure taxonomy and recovery:
- Command timeout/non-zero exit: enter degraded mode, keep last-good render.
- Malformed row(s): drop malformed rows, continue with valid rows if enough data remains.
- Valid-but-empty state: render explicit empty state (`WS: none`) without degraded marker.
- Degraded exit: after one fully successful refresh, clear degraded marker and replace with normal render.
- Retry/backoff: continue normal polling (`update_freq=2`); no additional burst retries.

Logging policy:
- Log only when `AEROSPACE_WS_DEBUG=1` is set.
- Prefix each line with timestamp and level (`INFO`, `WARN`, `ERROR`).
- Cap file at 256KB by truncating when exceeded.

## File-Level Changes

### `sketchybarrc`

- Remove Mission Control/yabai `space` component loop.
- Add one AeroSpace-driven workspace bracket/group on the left side with stable names:
  - `aerospace.mon.<monitor-id>` (group label items)
  - `aerospace.ws.<encoded-id>` (workspace items; workspace display text stored in label)
  - `aerospace.divider.<n>` (optional separators)
- Keep existing non-workspace items (`front_app`, `clock`, `volume`, `battery`) unchanged.

### `plugins/aerospace.sh`

- Add `plugins/aerospace.sh` as the AeroSpace-driven render/update entrypoint.
- Parse AeroSpace command output, compute grouped state, and apply styles/labels via SketchyBar commands.
- Build click handlers for each rendered workspace.
- Manage dynamic lifecycle every refresh:
  - create missing items
  - update existing items
  - remove stale items not present in current target state
- Use a state file in `/tmp/sketchybar-aerospace-items.state` to track last rendered item names.

Optional refactor if script grows:
- Extract parser/helpers into a second plugin helper script while keeping `aerospace.sh` as entrypoint.

## Validation Plan

Manual checks:
- Switching workspaces updates highlight correctly.
- Moving windows between workspaces updates visible workspace lists.
- Switching focused monitor updates active monitor indicator.
- Clicking any shown workspace switches via AeroSpace and redraws quickly.
- Focused workspace empty case: focused workspace still appears and is highlighted.

Recovery checks:
- Restart SketchyBar only: state recovers on next refresh.
- Restart AeroSpace only: state recovers on next refresh.

Negative checks:
- AeroSpace unavailable: degraded indicator appears without item loss/flicker.

Edge-case matrix:
- Hot-plug monitor while workspaces are populated.
- Rapid workspace switching across monitors.
- Rapid window moves between workspaces.
- Repeated AeroSpace command failures followed by recovery.

Executable checks:
- Parser fixture tests for `list-windows` row parsing and grouping.
- Deterministic sort test for monitor/workspace ordering.
- Click-script escaping test for workspace names with special characters.

## Non-Goals

- No yabai integration.
- No Mission Control space dependency.
- No attempt to render all keybound workspaces; only workspaces with windows are shown.

## Open Decisions Deferred to Implementation Planning

- Exact visual styling (marker syntax vs color-only emphasis).
- Whether to introduce a dedicated helper script immediately or only if complexity warrants.
