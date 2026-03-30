# SketchyBar System Info Widgets Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add CPU, memory, network up/down, WiFi, and a divider item to the right side of SketchyBar.

**Architecture:** Five independent shell scripts in `plugins/`, each called by a dedicated sketchybar item on a 5s timer (or `wifi_change` event for WiFi). A static divider item separates the new group from the existing clock/volume/battery group. All scripts follow the existing `#!/bin/sh` + `sketchybar --set "$NAME" ...` pattern.

**Tech Stack:** bash/sh, sketchybar CLI, macOS `top`, `vm_stat`, `sysctl`, `netstat`, `airport`

---

## Chunk 1: CPU and Memory scripts

### Task 1: `cpu.sh`

**Files:**
- Create: `~/.config/sketchybar/plugins/cpu.sh`

- [ ] **Step 1: Create `cpu.sh`**

```sh
#!/bin/sh

# top -l 2: take two samples; first sample idle% is stale on macOS.
# -s 0: no delay between samples. -n 0: don't show processes.
CPU_INFO=$(top -l 2 -s 0 -n 0 | grep -E "^CPU usage" | tail -1)

# Extract user + sys percentages (e.g. "12.5% user, 4.3% sys, 83.2% idle")
USER=$(echo "$CPU_INFO" | awk '{print $3}' | tr -d '%')
SYS=$(echo  "$CPU_INFO" | awk '{print $5}' | tr -d '%')

# Integer arithmetic via printf rounding
USED=$(printf "%.0f" "$(echo "$USER + $SYS" | bc)")

if [ "$USED" -ge 85 ]; then
  COLOR=0xffF38BA8
elif [ "$USED" -ge 60 ]; then
  COLOR=0xfff9e2af
else
  COLOR=0xffffffff
fi

sketchybar --set "$NAME" label="${USED}%" label.color="$COLOR"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x ~/.config/sketchybar/plugins/cpu.sh
```

- [ ] **Step 3: Smoke-test the script directly**

```bash
NAME=cpu ~/.config/sketchybar/plugins/cpu.sh
```

Expected: no errors, no output (sketchybar --set will fail gracefully if bar isn't running — that's fine). If the bar is running, the item will update. If not running, you'll see a connection error — that's expected.

- [ ] **Step 4: Verify `top` output parsing is correct**

```bash
top -l 2 -s 0 -n 0 | grep -E "^CPU usage" | tail -1
```

Expected output like: `CPU usage: 8.33% user, 4.16% sys, 87.50% idle`  
Verify the `awk '{print $3}'` and `'{print $5}'` fields match your actual output. If column positions differ, adjust the field numbers.

- [ ] **Step 5: Commit**

```bash
git -C ~/.config/sketchybar add plugins/cpu.sh
git -C ~/.config/sketchybar commit -m "feat: add cpu.sh plugin"
```

---

### Task 2: `memory.sh`

**Files:**
- Create: `~/.config/sketchybar/plugins/memory.sh`

- [ ] **Step 1: Create `memory.sh`**

```sh
#!/bin/sh

# Get total RAM in bytes
TOTAL=$(sysctl -n hw.memsize)

# Get page size
PAGE_SIZE=$(vm_stat | awk '/page size/ {print $8}')

# Get used page counts (active + wired + compressed)
ACTIVE=$(    vm_stat | awk '/Pages active:/     {gsub(/\./,"",$3); print $3}')
WIRED=$(     vm_stat | awk '/Pages wired down:/ {gsub(/\./,"",$4); print $4}')
COMPRESSED=$(vm_stat | awk '/Pages occupied by compressor:/ {gsub(/\./,"",$5); print $5}')

USED_BYTES=$(( (ACTIVE + WIRED + COMPRESSED) * PAGE_SIZE ))

# Format used bytes as human-readable
if [ "$USED_BYTES" -ge 1073741824 ]; then
  LABEL=$(printf "%.1fG" "$(echo "scale=1; $USED_BYTES / 1073741824" | bc)")
else
  LABEL=$(printf "%dM" "$(echo "$USED_BYTES / 1048576" | bc)")
fi

# Color threshold based on % of total RAM
PCT=$(echo "scale=0; $USED_BYTES * 100 / $TOTAL" | bc)

if [ "$PCT" -ge 90 ]; then
  COLOR=0xffF38BA8
elif [ "$PCT" -ge 75 ]; then
  COLOR=0xfff9e2af
else
  COLOR=0xffffffff
fi

sketchybar --set "$NAME" label="$LABEL" label.color="$COLOR"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x ~/.config/sketchybar/plugins/memory.sh
```

- [ ] **Step 3: Verify `vm_stat` parsing**

```bash
vm_stat
```

Check that the field names match: `Pages active:`, `Pages wired down:`, `Pages occupied by compressor:`. The `awk` patterns in the script must match exactly. Adjust if needed.

- [ ] **Step 4: Smoke-test**

```bash
NAME=mem ~/.config/sketchybar/plugins/memory.sh
```

Expected: no errors. If you want to verify the computed value, add a temporary `echo "$LABEL $PCT%"` line before the sketchybar call, run it, then remove the echo.

- [ ] **Step 5: Commit**

```bash
git -C ~/.config/sketchybar add plugins/memory.sh
git -C ~/.config/sketchybar commit -m "feat: add memory.sh plugin"
```

---

## Chunk 2: Network and WiFi scripts

### Task 3: `network.sh`

**Files:**
- Create: `~/.config/sketchybar/plugins/network.sh`

- [ ] **Step 1: Identify the primary network interface**

```bash
ifconfig | awk '/^en[0-9]/{iface=$1} /inet [0-9]/{print iface; exit}' | tr -d ':'
```

Expected: `en0` or `en1` (or similar). This is what the script will detect at runtime. Note the result — you'll use it to verify the netstat parsing below.

- [ ] **Step 2: Create `network.sh`**

```sh
#!/bin/sh

# Detect primary interface (first en* with an IPv4 address)
IFACE=$(ifconfig | awk '/^en[0-9]/{iface=$1} /inet [0-9]/{print iface; exit}' | tr -d ':')

if [ -z "$IFACE" ]; then
  sketchybar --set "$NAME" label="—"
  exit 0
fi

# Sample netstat -ib twice, 1 second apart, diff byte counters
SNAP1=$(netstat -ib | awk -v iface="$IFACE" '$1 == iface && $3 ~ /^[0-9]/ {print $7, $10; exit}')
sleep 1
SNAP2=$(netstat -ib | awk -v iface="$IFACE" '$1 == iface && $3 ~ /^[0-9]/ {print $7, $10; exit}')

IN1=$(echo "$SNAP1" | awk '{print $1}')
OUT1=$(echo "$SNAP1" | awk '{print $2}')
IN2=$(echo "$SNAP2" | awk '{print $1}')
OUT2=$(echo "$SNAP2" | awk '{print $2}')

BYTES_IN=$(( IN2 - IN1 ))
BYTES_OUT=$(( OUT2 - OUT1 ))

# Guard against negative values (interface counter reset)
[ "$BYTES_IN"  -lt 0 ] && BYTES_IN=0
[ "$BYTES_OUT" -lt 0 ] && BYTES_OUT=0

# Format bytes/s with auto-scale
format_rate() {
  BYTES=$1
  if [ "$BYTES" -ge 1048576 ]; then
    printf "%.1fM" "$(echo "scale=1; $BYTES / 1048576" | bc)"
  elif [ "$BYTES" -ge 1024 ]; then
    printf "%dK" "$(echo "$BYTES / 1024" | bc)"
  else
    printf "0K"
  fi
}

# $NAME is set by sketchybar — determines which value to output
case "$NAME" in
  net_up)   sketchybar --set "$NAME" label="$(format_rate "$BYTES_OUT")" ;;
  net_down) sketchybar --set "$NAME" label="$(format_rate "$BYTES_IN")"  ;;
esac
```

- [ ] **Step 3: Make executable**

```bash
chmod +x ~/.config/sketchybar/plugins/network.sh
```

- [ ] **Step 4: Verify `netstat -ib` column layout**

```bash
netstat -ib | head -5
```

Expected header: `Name Mtu Network Address Ipkts Ierrs Ibytes Opkts Oerrs Obytes Coll`  
Columns 7 (`$7`) = Ibytes, column 10 (`$10`) = Obytes. Confirm these match your output. The awk filter `$3 ~ /^[0-9]/` skips the header and IPv6 rows.

- [ ] **Step 5: Smoke-test upload**

```bash
NAME=net_up ~/.config/sketchybar/plugins/network.sh
```

Expected: takes ~1 second, no errors.

- [ ] **Step 6: Smoke-test download**

```bash
NAME=net_down ~/.config/sketchybar/plugins/network.sh
```

- [ ] **Step 7: Commit**

```bash
git -C ~/.config/sketchybar add plugins/network.sh
git -C ~/.config/sketchybar commit -m "feat: add network.sh plugin"
```

---

### Task 4: `wifi.sh`

**Files:**
- Create: `~/.config/sketchybar/plugins/wifi.sh`

- [ ] **Step 1: Verify `airport` binary exists**

```bash
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | head -5
```

Expected: output including a line like `     SSID: MyNetwork`. If the binary is missing, you'll need an alternative (e.g. `networksetup -getairportnetwork en0`).

- [ ] **Step 2: Create `wifi.sh`**

```sh
#!/bin/sh

AIRPORT="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"

SSID=$("$AIRPORT" -I 2>/dev/null | awk -F': ' '/ SSID:/{print $2}')

if [ -z "$SSID" ]; then
  sketchybar --set "$NAME" icon="󰤭" label=""
else
  sketchybar --set "$NAME" icon="󰤨" label="$SSID"
fi
```

- [ ] **Step 3: Make executable**

```bash
chmod +x ~/.config/sketchybar/plugins/wifi.sh
```

- [ ] **Step 4: Smoke-test**

```bash
NAME=wifi ~/.config/sketchybar/plugins/wifi.sh
```

Expected: no errors. Verify SSID parsing manually:

```bash
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk -F': ' '/ SSID:/{print $2}'
```

Should print your current WiFi network name.

- [ ] **Step 5: Commit**

```bash
git -C ~/.config/sketchybar add plugins/wifi.sh
git -C ~/.config/sketchybar commit -m "feat: add wifi.sh plugin"
```

---

## Chunk 3: Wiring into `sketchybarrc`

### Task 5: Add divider and new items to `sketchybarrc`

**Files:**
- Modify: `~/.config/sketchybar/sketchybarrc`

The existing right-side block looks like this (lines 163–170):

```bash
sketchybar --add item clock right \
           --set clock update_freq=10 icon=  script="$PLUGIN_DIR/clock.sh" \
           --add item volume right \
           --set volume script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change \
           --add item battery right \
           --set battery update_freq=120 script="$PLUGIN_DIR/battery.sh" \
           --subscribe battery system_woke power_source_change
```

Sketchybar renders `right` items right-to-left. Items declared **after** clock/volume/battery will render **to their left** on screen. So append the new items after the existing block, before `sketchybar --update`.

- [ ] **Step 1: Add divider and system info items**

Add the following block to `sketchybarrc` after the battery block and before the `sketchybar --update` line:

```bash
##### Adding System Info Items #####
sketchybar --add item divider right \
           --set divider icon.drawing=off \
                         label="｜" \
                         label.color=0x44ffffff \
                         label.font="Hack Nerd Font:Bold:16.0" \
                         padding_left=4 \
                         padding_right=4

sketchybar --add item cpu right \
           --set cpu update_freq=5 \
                     icon=󰻠 \
                     script="$PLUGIN_DIR/cpu.sh" \
           --add item mem right \
           --set mem update_freq=5 \
                     icon= \
                     script="$PLUGIN_DIR/memory.sh" \
           --add item net_up right \
           --set net_up update_freq=5 \
                        icon=󰕒 \
                        script="$PLUGIN_DIR/network.sh" \
           --add item net_down right \
           --set net_down update_freq=5 \
                          icon=󰇚 \
                          script="$PLUGIN_DIR/network.sh" \
           --add item wifi right \
           --set wifi icon=󰤨 \
                      script="$PLUGIN_DIR/wifi.sh" \
           --subscribe wifi wifi_change
```

- [ ] **Step 2: Reload the bar**

```bash
sketchybar --reload
```

Or kill and restart:

```bash
brew services restart sketchybar
```

- [ ] **Step 3: Verify all new items appear**

Check the bar visually. Expected right-side order (left to right):
`cpu · mem · net_up · net_down · wifi | clock · vol · bat`

- [ ] **Step 4: Verify color thresholds work**

To force the CPU item into warning/danger state for a quick visual check, temporarily lower the thresholds in `cpu.sh` (e.g. set danger at ≥5%), reload, watch the bar, then restore original thresholds.

- [ ] **Step 5: Verify WiFi disconnected state**

Turn off WiFi, wait one `wifi_change` event (or run `NAME=wifi ~/.config/sketchybar/plugins/wifi.sh` manually). The WiFi item should show `󰤭` with no label. Re-enable WiFi and verify SSID returns.

- [ ] **Step 6: Commit**

```bash
git -C ~/.config/sketchybar add sketchybarrc
git -C ~/.config/sketchybar commit -m "feat: wire cpu/mem/network/wifi items into sketchybarrc"
```
