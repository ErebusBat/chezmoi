#!/bin/sh

# top -l 2: take two samples; first sample idle% is stale on macOS.
# -s 0: no delay between samples. -n 0: don't show processes.
# Single awk pass: extracts CPU usage line from second sample, sums user+sys.
USED=$(top -l 2 -s 0 -n 0 | awk '/^CPU usage/ { line = $0 } END {
  gsub(/%/, "", line)
  split(line, f, /[, ]+/)
  printf "%.0f", f[3] + f[5]
}')

if [ -z "$USED" ]; then
  exit 0
fi

if [ "$USED" -ge 85 ]; then
  COLOR=0xffF38BA8
elif [ "$USED" -ge 60 ]; then
  COLOR=0xfff9e2af
else
  COLOR=0xffffffff
fi

sketchybar --set "$NAME" label="${USED}%" label.color="$COLOR"
