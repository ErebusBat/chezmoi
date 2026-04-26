#!/bin/sh

# Test to see if we should not run (i.e. for power saving)
if [ -f /tmp/lowpower ]; then
  exit 0
fi

LMS_MODEL_NAME="dictation"
LMS_COMMAND="lms ps"
LMS_OK_CHAR="●"
LMS_FAIL_CHAR="●"
LMS_OK_COLOR="green"
LMS_FAIL_COLOR="red"
LMS_SEPARATOR="#[fg=brightblack, bg=default]|"
USER_SETTINGS_PATH="$HOME/.config/tmux/widgets/lm-studio-dictation.conf.sh"

if [ -f "$USER_SETTINGS_PATH" ]; then
  # shellcheck disable=SC1090
  . "$USER_SETTINGS_PATH"
fi

print_status() {
  color="$1"
  char="$2"
  printf '%s#[fg=%s, bg=default]%s' "$LMS_SEPARATOR" "$color" "$char"
}

if ! command -v lms >/dev/null 2>&1; then
  print_status "$LMS_FAIL_COLOR" "$LMS_FAIL_CHAR"
  exit 0
fi

if ! output="$(sh -c "$LMS_COMMAND" 2>/dev/null)"; then
  print_status "$LMS_FAIL_COLOR" "$LMS_FAIL_CHAR"
  exit 0
fi

if printf '%s
' "$output" | awk -v model="$LMS_MODEL_NAME" '
  BEGIN {
    wanted = tolower(model)
    found = 0
  }
  {
    line = tolower($0)
    if (index(line, wanted) > 0) {
      if (line ~ /(stopped|stop|exited|failed|error|dead|unloaded|not running)/) {
        next
      }
      found = 1
    }
  }
  END {
    exit found ? 0 : 1
  }
'; then
  print_status "$LMS_OK_COLOR" "$LMS_OK_CHAR"
else
  print_status "$LMS_FAIL_COLOR" "$LMS_FAIL_CHAR"
fi
