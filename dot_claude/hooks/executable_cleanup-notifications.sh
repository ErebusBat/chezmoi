#!/bin/bash
# Clean up notification state on session end

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
STATE_DIR="${TMPDIR}claude-notifications"
PID_FILE="${STATE_DIR}/session-${SESSION_ID}.pid"

# Kill and clean up session notifications
if [ -f "$PID_FILE" ]; then
  while read -r pid; do
    kill "$pid" 2>/dev/null
  done < "$PID_FILE"
  rm -f "$PID_FILE"
fi

# Remove session markers
rm -f "${STATE_DIR}/session-${SESSION_ID}"-*.marker 2>/dev/null

# Clean up stale files (older than 5 minutes)
find "$STATE_DIR" -name "*.marker" -type f -mmin +5 -delete 2>/dev/null
find "$STATE_DIR" -name "*.pid" -type f -size 0 -delete 2>/dev/null

exit 0
