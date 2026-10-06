#!/bin/sh

# Get total RAM in bytes
TOTAL=$(sysctl -n hw.memsize)

if [ -z "$TOTAL" ]; then
  exit 0
fi

# eval is used to set multiple variables in one vm_stat pass (POSIX sh has no arrays).
# Output is integers/sizes from kernel — no injection risk.
# Single vm_stat pass: extract page size, active, wired, and compressed counts
eval "$(vm_stat | awk '
  /page size of/ { printf "PAGE_SIZE=%s\n", $8 }
  /Pages active:/ { gsub(/\./, "", $3); printf "ACTIVE=%s\n", $3 }
  /Pages wired down:/ { gsub(/\./, "", $4); printf "WIRED=%s\n", $4 }
  /Pages occupied by compressor:/ { gsub(/\./, "", $5); printf "COMPRESSED=%s\n", $5 }
')"

if [ -z "$PAGE_SIZE" ] || [ -z "$ACTIVE" ] || [ -z "$WIRED" ] || [ -z "$COMPRESSED" ]; then
  exit 0
fi

USED_BYTES=$(( (ACTIVE + WIRED + COMPRESSED) * PAGE_SIZE ))

# Format used bytes as human-readable
if [ "$USED_BYTES" -ge 1073741824 ]; then
  LABEL=$(awk "BEGIN { printf \"%.1fG\", $USED_BYTES / 1073741824 }")
else
  LABEL=$(awk "BEGIN { printf \"%dM\", int($USED_BYTES / 1048576) }")
fi

# Color threshold based on % of total RAM
PCT=$(awk "BEGIN { printf \"%d\", int($USED_BYTES * 100 / $TOTAL) }")

if [ "$PCT" -ge 90 ]; then
  COLOR=0xffF38BA8
elif [ "$PCT" -ge 75 ]; then
  COLOR=0xfff9e2af
else
  COLOR=0xffffffff
fi

sketchybar --set "$NAME" label="$LABEL" label.color="$COLOR"
