#!/bin/bash
# Cancel pending notifications for current session

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
STATE_DIR="${TMPDIR}claude-notifications"
PID_FILE="${STATE_DIR}/session-${SESSION_ID}.pid"

# Exit if no pending notifications
[ ! -f "$PID_FILE" ] && exit 0

# Kill all pending notification processes
while read -r pid; do
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null
  fi
done < "$PID_FILE"

# Remove markers and PID file
rm -f "${STATE_DIR}/session-${SESSION_ID}"-*.marker 2>/dev/null
rm -f "$PID_FILE"

exit 0
