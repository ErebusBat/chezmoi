#!/bin/bash
# Delayed notification with cancellation support

DELAY=${CLAUDE_NOTIFICATION_DELAY:-45}
STATE_DIR="${TMPDIR}claude-notifications"

# Parse hook input
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude Code needs your attention"')
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')

# Detect tmux session/pane or shell name
if [ -n "$TMUX" ]; then
  CONTEXT=$(tmux display-message -p '#S:#I.#P' 2>/dev/null || echo "tmux")
else
  CONTEXT=$(basename "$SHELL")
fi

# Append context to title
TITLE="${TITLE} (${CONTEXT})"

# Create state directory
mkdir -p "$STATE_DIR"

# Create marker file with timestamp
MARKER="${STATE_DIR}/session-${SESSION_ID}-$(date +%s).marker"
touch "$MARKER"

# Store PID for cancellation
PID_FILE="${STATE_DIR}/session-${SESSION_ID}.pid"
echo $$ >> "$PID_FILE"

# Wait for delay
sleep "$DELAY"

# Check if marker still exists (removed if cancelled)
if [ -f "$MARKER" ]; then
  osascript -e "display notification \"${MESSAGE}\" with title \"${TITLE}\" sound name \"Sosumi\""
  rm -f "$MARKER"
fi

# Clean up own PID
sed -i '' "/^$$$/d" "$PID_FILE" 2>/dev/null
exit 0
