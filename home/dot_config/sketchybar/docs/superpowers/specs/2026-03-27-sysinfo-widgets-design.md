# SketchyBar System Info Widgets — Design Spec

**Date:** 2026-03-27  
**Status:** Approved

---

## Overview

Add five new right-side items to the SketchyBar configuration: CPU usage, memory usage, network upload throughput, network download throughput, and WiFi SSID. A visual divider separates these new items from the existing clock/volume/battery group.

---

## Bar Layout

Items render right-to-left (sketchybar `right` position), producing this left-to-right visual order:

```
[workspaces · front_app]    cpu · mem · net↑ · net↓ · wifi | clock · vol · bat
```

The `|` divider is a static sketchybar item with a dimmed label and no script.

---

## New Items

| Item | Icon | Script | Trigger |
|---|---|---|---|
| `cpu` | `󰻠` | `cpu.sh` | `update_freq=5` |
| `mem` | `` | `memory.sh` | `update_freq=5` |
| `net_up` | `󰕒` | `network.sh` | `update_freq=5` |
| `net_down` | `󰇚` | `network.sh` | `update_freq=5` |
| `wifi` | `󰤨` / `󰤭` | `wifi.sh` | `wifi_change` event |
| `divider` | — | none | static |

---

## Scripts

All scripts live in `~/.config/sketchybar/plugins/`. All follow the existing convention: `#!/bin/bash`, update via `sketchybar --set "$NAME" ...`.

### `cpu.sh`

- Command: `top -l 2 -s 0 -n 0` (two samples, discard first for accuracy)
- Extracts CPU user+sys % from the second sample
- Label: integer percent, e.g. `47%`
- Color thresholds (applied to label):
  - ≥85% → red `0xffF38BA8`
  - ≥60% → yellow `0xfff9e2af`
  - else → white `0xffffffff`

### `memory.sh`

- Commands: `vm_stat` (used pages), `sysctl hw.memsize` (total RAM)
- Computes used = (active + wired + compressed) × page_size
- Label: auto-formatted, e.g. `6.1G` or `934M`
- Color thresholds (applied to label, based on % of total RAM):
  - ≥90% → red `0xffF38BA8`
  - ≥75% → yellow `0xfff9e2af`
  - else → white `0xffffffff`

### `network.sh`

- Detects primary interface: first of `en0`, `en1` that has an IPv4 address (`ifconfig`)
- Samples `netstat -ib` twice with 1s sleep, diffs byte counters for the detected interface
- Checks `$NAME` env var (set by sketchybar) to determine which value to output:
  - `net_up` → outbound bytes/s
  - `net_down` → inbound bytes/s
- Format (auto-scale):
  - `< 1024 B/s` → `"0K"`  (floor to K for clean display)
  - `< 1,048,576 B/s` → `"512K"`
  - else → `"3.2M"`
- No color thresholds — label stays white

### `wifi.sh`

- Command: `/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I`
- Extracts SSID from output
- Connected: icon `󰤨`, label = SSID name
- Not connected / no WiFi: icon `󰤭`, label = `""`
- No color thresholds — icon stays white

---

## `sketchybarrc` Changes

Add the following **after** the existing right-side block (clock/volume/battery), so the new items render to their left on screen.

### Divider item

```bash
sketchybar --add item divider right \
           --set divider icon.drawing=off \
                         label="｜" \
                         label.color=0x44ffffff \
                         label.font="Hack Nerd Font:Bold:16.0" \
                         padding_left=4 \
                         padding_right=4
```

### System info items

```bash
sketchybar --add item cpu right \
           --set cpu update_freq=5 icon=󰻠 script="$PLUGIN_DIR/cpu.sh" \
           --add item mem right \
           --set mem update_freq=5 icon= script="$PLUGIN_DIR/memory.sh" \
           --add item net_up right \
           --set net_up update_freq=5 icon=󰕒 script="$PLUGIN_DIR/network.sh" \
           --add item net_down right \
           --set net_down update_freq=5 icon=󰇚 script="$PLUGIN_DIR/network.sh" \
           --add item wifi right \
           --set wifi icon=󰤨 script="$PLUGIN_DIR/wifi.sh" \
           --subscribe wifi wifi_change
```

---

## Colors Reference

| Purpose | Value |
|---|---|
| Normal label | `0xffffffff` |
| Warning (yellow) | `0xfff9e2af` |
| Danger (red) | `0xffF38BA8` |
| Divider | `0x44ffffff` |

---

## Constraints & Notes

- All polling uses lightweight shell commands only — no `nettop`, no `iostat`, no Python
- `top -l 2` is the standard macOS approach for accurate CPU; `-l 1` returns stale idle %
- `network.sh` is called twice per cycle (once for `net_up`, once for `net_down`), each doing its own 1s sample. This means network sampling adds ~2s of wall time per 5s cycle on a background thread — acceptable since sketchybar runs scripts asynchronously
- WiFi uses the private `airport` binary, which is standard practice on macOS status bars
- Font: `Hack Nerd Font:Bold:17.0` for icons, `Hack Nerd Font:Bold:14.0` for labels (matches existing defaults — no per-item font override needed)
