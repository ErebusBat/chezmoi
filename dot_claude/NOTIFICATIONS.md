# Delayed Notification System for Claude Code

## Overview

This system prevents notification fatigue by only alerting you when Claude needs attention **and** you haven't responded within a configurable delay (default: 45 seconds).

**Key Features:**
- If you respond before the delay expires, the notification is automatically cancelled
- Shows which tmux session/pane triggered the alert (e.g., "Claude Code (system:1.1)")
- Falls back to shell name if not in tmux (e.g., "Claude Code (zsh)")

## How It Works

1. **Notification triggered** → Background timer starts (45 seconds by default)
2. **You respond within 45s** → Notification is cancelled automatically ✅
   - Cancels on text input (UserPromptSubmit hook)
   - Cancels on tool approval (PreToolUse hook)
3. **45 seconds pass without response** → Notification appears with Glass sound 🔔
4. **Session ends** → All pending notifications are cleaned up

## Files

### Hook Scripts (`~/.claude/hooks/`)
- **`delayed-notification.sh`** - Main notification timer (backgrounds process, waits delay, sends notification)
- **`cancel-notification.sh`** - Cancels pending notifications when you respond
- **`cleanup-notifications.sh`** - Cleans up state when session ends

### Configuration (`~/.claude/settings.json`)
```json
"hooks": {
  "Notification": [{
    "matcher": "",
    "hooks": [{"type": "command", "command": "~/.claude/hooks/delayed-notification.sh"}]
  }],
  "UserPromptSubmit": [{
    "hooks": [{"type": "command", "command": "~/.claude/hooks/cancel-notification.sh"}]
  }],
  "PreToolUse": [{
    "matcher": "",
    "hooks": [{"type": "command", "command": "~/.claude/hooks/cancel-notification.sh"}]
  }],
  "SessionEnd": [{
    "hooks": [{"type": "command", "command": "~/.claude/hooks/cleanup-notifications.sh"}]
  }]
}
```

### State Files (`$TMPDIR/claude-notifications/`)
- `session-{id}.pid` - Process IDs for cancellation
- `session-{id}-{timestamp}.marker` - Notification markers
- *Auto-cleaned by macOS and SessionEnd hook*

## Configuration

### Change Notification Delay

Add to your shell config (`~/.zshrc` or `~/.bashrc`):

```bash
# 30 second delay
export CLAUDE_NOTIFICATION_DELAY=30

# 60 second delay (1 minute)
export CLAUDE_NOTIFICATION_DELAY=60

# 120 second delay (2 minutes)
export CLAUDE_NOTIFICATION_DELAY=120
```

Then restart your terminal or run `source ~/.zshrc`

## Testing

### ✅ Test 1: Notification Fires After Delay
1. Start Claude Code session
2. Wait for Claude to prompt you
3. **Don't respond for 45+ seconds**
4. **Expected:** Notification appears with Glass sound
   - If in tmux: Title shows "Claude Code (session:window.pane)"
   - If not in tmux: Title shows "Claude Code (zsh)" or your shell name

### ✅ Test 2: Cancellation Works
1. Start Claude Code session
2. Wait for Claude to prompt you
3. **Respond within 45 seconds**
4. **Expected:** No notification appears

### Monitor State
```bash
# Check running notification timers
ps aux | grep delayed-notification

# View state directory
ls -la "${TMPDIR}claude-notifications/"

# Check current delay setting
echo $CLAUDE_NOTIFICATION_DELAY
```

## Troubleshooting

### Notifications Not Appearing
- **Check delay setting:** `echo $CLAUDE_NOTIFICATION_DELAY`
- **Verify scripts are executable:** `ls -la ~/.claude/hooks/`
- **Check for errors:** Restart Claude Code and watch for hook errors
- **Verify jq is installed:** `which jq`

### Notifications Not Cancelling
- **Check UserPromptSubmit hook:** Look in `~/.claude/settings.json`
- **Verify PID file exists:** `ls "${TMPDIR}claude-notifications/"`
- **Check for hook errors:** Look for "UserPromptSubmit hook" messages

### Clean Up Manually
```bash
# Kill all notification processes
pkill -f delayed-notification.sh

# Remove state files
rm -rf "${TMPDIR}claude-notifications/"
```

## Technical Details

### Session Isolation
Each Claude Code session gets a unique `session_id`, ensuring notifications from different sessions don't interfere with each other.

### Cancellation Mechanism
1. `delayed-notification.sh` stores its PID in `session-{id}.pid`
2. Creates a marker file: `session-{id}-{timestamp}.marker`
3. When you respond, `cancel-notification.sh` reads the PID file
4. Kills all processes listed in the PID file
5. Removes marker files

### Notification Check
Before sending notification, `delayed-notification.sh` checks if its marker file still exists. If removed by cancel hook, notification is skipped.

### Cleanup Strategy
- **SessionEnd hook:** Removes session-specific files when you exit
- **Stale file cleanup:** Automatically removes files older than 5 minutes
- **macOS TMPDIR:** Files in `$TMPDIR` are cleaned on system restart

## Advanced Customization

### Different Delays Per Notification Type
Edit `delayed-notification.sh`:
```bash
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type')
case "$NOTIFICATION_TYPE" in
  permission_prompt) DELAY=30 ;;
  idle_prompt) DELAY=60 ;;
  *) DELAY=45 ;;
esac
```

### Progressive Notifications
```bash
# First notification (silent)
osascript -e "display notification \"Claude waiting...\" with title \"Claude Code\""
sleep 75

# Second notification (loud) if still no response
if [ -f "$MARKER" ]; then
  osascript -e "display notification \"Still waiting!\" with title \"Claude Code\" sound name \"Hero\""
fi
```

### Custom Notification Sound
Edit `delayed-notification.sh` line 29:
```bash
# Available sounds: Glass, Hero, Submarine, Tink, Pop, Basso, Blow, Bottle, Frog, Funk, Ping, Purr
osascript -e "display notification \"${MESSAGE}\" with title \"${TITLE}\" sound name \"Hero\""
```

## Verified Working ✅

- ✅ Delayed notifications (45+ seconds with no response)
- ✅ Automatic cancellation (respond within delay)
- ✅ Session cleanup
- ✅ Multiple rapid notifications
- ✅ Session isolation via session_id
- ✅ Glass sound notification
- ✅ Context detection (tmux session/pane or shell name)

## Requirements

- **macOS** (uses `osascript` for notifications)
- **jq** (JSON parsing) - Install with: `brew install jq`
- **bash** (standard on macOS)

---

**Created:** 2026-02-08
**Last Tested:** 2026-02-08 ✅
