#!/bin/sh

# Test to see if we should not run (i.e. for power saving)
if [ -f /tmp/lowpower ]; then
  exit 0
fi

LMS_MODEL_NAME="dictation"
LMS_BIN="$HOME/.lmstudio/bin/lms"
LMS_COMMAND_JSON="$LMS_BIN ps --json"
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

if [ ! -x "$LMS_BIN" ] && command -v lms >/dev/null 2>&1; then
  LMS_BIN="$(command -v lms)"
  LMS_COMMAND_JSON="$LMS_BIN ps --json"
fi

if [ ! -x "$LMS_BIN" ] || ! command -v jq >/dev/null 2>&1; then
  print_status "$LMS_FAIL_COLOR" "$LMS_FAIL_CHAR"
  exit 0
fi

if ! output="$(sh -c "$LMS_COMMAND_JSON" 2>/dev/null)"; then
  print_status "$LMS_FAIL_COLOR" "$LMS_FAIL_CHAR"
  exit 0
fi

if printf '%s
' "$output" | jq -e --arg model "$LMS_MODEL_NAME" '
  def strings_or_empty:
    if type == "string" then ascii_downcase else empty end;

  def identifiers:
    [
      .id?,
      .identifier?,
      .modelKey?,
      .name?,
      .displayName?,
      .model?,
      .model_id?,
      .modelId?,
      .indexedModelIdentifier?,
      .path?
    ]
    | map(strings_or_empty);

  def status_text:
    [
      .status?,
      .state?,
      .lifecycle?,
      .phase?
    ]
    | map(strings_or_empty)
    | join(" ");

  def model_matches:
    (.identifier? | strings_or_empty) == ($model | ascii_downcase);

  def status_is_running:
    (status_text) as $status
    | ($status == "")
      or ($status | test("idle|running|loaded|started|ready|active|serving"));

  def status_is_bad:
    status_text | test("stopped|stop|exited|failed|error|dead|unloaded|not running");

  any(
    .. | objects;
    model_matches and status_is_running and (status_is_bad | not)
  )
' >/dev/null; then
  print_status "$LMS_OK_COLOR" "$LMS_OK_CHAR"
else
  print_status "$LMS_FAIL_COLOR" "$LMS_FAIL_CHAR"
fi
