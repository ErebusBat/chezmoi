#!/bin/sh

# Detect primary interface via default route (most reliable on macOS)
IFACE=$(route get default 2>/dev/null | awk '/interface:/{print $2}')

# Fallback: first en* with an IPv4 address
if [ -z "$IFACE" ]; then
  IFACE=$(ifconfig | awk '/^en[0-9]:/{iface=substr($1,1,length($1)-1)} /^\tinet [0-9]/{print iface; exit}')
fi

if [ -z "$IFACE" ]; then
  sketchybar --set "$NAME" label="—"
  exit 0
fi

# Sample netstat -ib twice, 1 second apart, diff byte counters
# Use the <Link#> row — it holds the canonical cumulative byte counts
SNAP1=$(netstat -ib | awk -v iface="$IFACE" '$1 == iface && $3 ~ /^<Link/ {print $7, $10; exit}')
sleep 1
SNAP2=$(netstat -ib | awk -v iface="$IFACE" '$1 == iface && $3 ~ /^<Link/ {print $7, $10; exit}')

IN1=$(echo "$SNAP1" | awk '{print $1}')
OUT1=$(echo "$SNAP1" | awk '{print $2}')
IN2=$(echo "$SNAP2" | awk '{print $1}')
OUT2=$(echo "$SNAP2" | awk '{print $2}')

# Guard against empty values
if [ -z "$IN1" ] || [ -z "$IN2" ] || [ -z "$OUT1" ] || [ -z "$OUT2" ]; then
  sketchybar --set "$NAME" label="—"
  exit 0
fi

BYTES_IN=$(( IN2 - IN1 ))
BYTES_OUT=$(( OUT2 - OUT1 ))

# Guard against negative values (interface counter reset)
[ "$BYTES_IN"  -lt 0 ] && BYTES_IN=0
[ "$BYTES_OUT" -lt 0 ] && BYTES_OUT=0

# Format bytes/s with auto-scale (awk BEGIN avoids bc dependency)
format_rate() {
  BYTES=$1
  if [ "$BYTES" -ge 1048576 ]; then
    awk "BEGIN { printf \"%.1fM\n\", $BYTES / 1048576 }"
  elif [ "$BYTES" -ge 1024 ]; then
    awk "BEGIN { printf \"%dK\n\", $BYTES / 1024 }"
  else
    printf "0K"
  fi
}

# $NAME is set by sketchybar — determines which direction to output
case "$NAME" in
  net_up)   sketchybar --set "$NAME" label="$(format_rate "$BYTES_OUT")" ;;
  net_down) sketchybar --set "$NAME" label="$(format_rate "$BYTES_IN")"  ;;
esac
