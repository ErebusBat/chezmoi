#!/bin/bash
# https://claude.ai/chat/56f06bad-56e3-4b98-9c4b-3f26c89f9b28

# Monitor for wake events and restart backrest
LOG_FILE="/opt/homebrew/var/log/backrest-wake-monitor.log"

log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
    echo "$(date): $1"
}

kill_backrest() {
  # Search for backrest
  log_message "Searching for backrest..."
  local backrest_pids=$(pgrep backrest)
  if [[ $backrest_pids ]]; then
    log_message "Found the following backrest processes, attempting to kill:"
    ps ${backrest_pids}
    killall backrest
    return 0
  else
    log_message "Didn't find any backrest processes running"
    return 1
  fi
}

# Cleanup Log file and log start up
: > "$LOG_FILE"
log_message "Truncating Log File"
log_message "Wake monitor started"

# Monitor power management log for wake events
log stream --predicate 'process == "kernel"' | while read -r line; do
# tail -f /tmp/fake | while read -r line; do
    # Look for wake events
    if echo "$line" | grep -q "PowerChangeDone: SLEEP_STATE->ON_STATE"; then
        log_message "Wake event detected: $line"

        log_message "Waiting for the system to stabilize"
        sleep 3

        # Restart backrest service
        log_message "Killing all Backrest Services (launchd will restart)"
        kill_backrest
        # while kill_backrest; do
        #   sleep 3
        # done
        # launchctl kickstart -k "gui/$(id -u)/homebrew.mxcl.backrest"

        # log_message "Restart command sent"
    # else
    #   log_message "NO match: $line"
    fi
done
