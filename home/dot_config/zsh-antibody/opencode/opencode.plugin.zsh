if [[ -d $HOME/.opencode/bin ]]; then
  export PATH=$HOME/.opencode/bin:$PATH
fi

# Keep OCX PATH handling with the OpenCode shell integration rather than
# spreading closely related tooling across separate plugins.
# The official OCX installer prefers /usr/local/bin or ~/.local/bin, both of
# which are already covered elsewhere. This only handles a direct ~/.ocx install.
if [[ -x $HOME/.ocx/ocx ]]; then
  export PATH=$HOME/.ocx:$PATH
fi

if ! command -v opencode >/dev/null 2>&1; then
  return
fi

# Helper Function
# ------------------------------------------------------------------------------

_tmux_oc_can_use_tmux() {
  local tmux_socket

  if [[ -z "$TMUX" || -z "$TMUX_PANE" ]]; then
    return 1
  fi

  tmux_socket="${TMUX%%,*}"
  if [[ -n "$tmux_socket" && ! -S "$tmux_socket" ]]; then
    return 1
  fi

  tmux has-session >/dev/null 2>&1
}

# Function that will auto "tag" a tmux window with a robot for cycling purposes
oc() {
  local script="$HOME/.config/tmux/scripts/set-window-prefix.sh"

  if [[ -x "$script" ]] && _tmux_oc_can_use_tmux; then
    "$script" set
    opencode "$@"
    "$script" clear
  else
    opencode "$@"
  fi
}
alias ocn=oc

# Select an OpenCode session via fzf
oc_session_select() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found"
    return 1
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 not found"
    return 1
  fi

  local selection max_count tmpfile errfile listfile fetching_shown
  local use_global=0 profile_override=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        echo "Usage: oc_session_select [options] [max_count]" >&2
        echo "" >&2
        echo "Options:" >&2
        echo "  -h, --help        Show this help" >&2
        echo "  -g, --global      Query the global opencode database" >&2
        echo "  -a, --all         Same as --global" >&2
        echo "  -p, --profile     Query a specific OpenCode profile's database" >&2
        echo "" >&2
        echo "Examples:" >&2
        echo "  oc_session_select          Current project sessions (profile-aware)" >&2
        echo "  oc_session_select 10       Limit to 10 sessions" >&2
        echo "  oc_session_select --global All global sessions" >&2
        echo "  oc_session_select -p upserve  All work profile sessions" >&2
        return 1
        ;;
      -g|--global)  use_global=1; shift ;;
      -a|--all)     use_global=1; shift ;;
      -p|--profile) shift; profile_override="$1"; shift ;;
      *)            max_count="$1"; shift ;;
    esac
  done

  local -a cmd
  if [[ -n "$profile_override" ]]; then
    case "$profile_override" in
      personal) cmd=(opencode-personal session list --format json --print-logs --log-level ERROR) ;;
      work|lshq|upserve) cmd=(opencode-work session list --format json --print-logs --log-level ERROR) ;;
      *) echo "Unknown profile: $profile_override" >&2; return 1 ;;
    esac
  elif [[ $use_global -eq 1 ]]; then
    cmd=(command opencode session list --format json --print-logs --log-level ERROR)
  else
    cmd=(opencode session list --format json --print-logs --log-level ERROR)
  fi
  if [[ -n "$max_count" ]]; then
    cmd+=(--max-count "$max_count")
  fi

  tmpfile=$(mktemp -t opencode_sessions.XXXXXX)
  errfile=$(mktemp -t opencode_sessions_err.XXXXXX)
  listfile=$(mktemp -t opencode_sessions_list.XXXXXX)
  fetching_shown=0
  if [[ -t 2 ]]; then
    printf '%s' "Fetching OpenCode sessions..." >&2
    fetching_shown=1
  fi
  if ! "${cmd[@]}" >"$tmpfile" 2>"$errfile"; then
    echo "Failed to fetch OpenCode sessions"
    if [[ -s "$errfile" ]]; then
      cat "$errfile"
    fi
    rm -f "$tmpfile" "$errfile"
    return 1
  fi

  if [[ ! -s "$tmpfile" ]] && command -v script >/dev/null 2>&1; then
    if ! script -q /dev/null "${cmd[@]}" >"$tmpfile" 2>"$errfile"; then
      echo "Failed to fetch OpenCode sessions"
      if [[ -s "$errfile" ]]; then
        cat "$errfile"
      fi
      rm -f "$tmpfile" "$errfile"
      return 1
    fi
    if [[ -s "$tmpfile" ]]; then
      tr -d '\r' <"$tmpfile" >"${tmpfile}.clean" && mv "${tmpfile}.clean" "$tmpfile"
    fi
  fi

  if [[ $fetching_shown -eq 1 ]]; then
    printf '\r\u001b[2K' >&2
  fi

  if ! python3 -c 'import json,sys,time
raw=sys.stdin.read()
start=raw.find("[")
end=raw.rfind("]")
if start == -1 or end == -1 or end < start:
    print("Invalid JSON from opencode session list", file=sys.stderr)
    sys.exit(1)
raw=raw[start:end+1]
data=json.loads(raw)
now_ms=int(time.time()*1000)
def rel_time(updated_ms):
    if not isinstance(updated_ms, (int, float)) or not updated_ms:
        return ""
    delta_min=max(0, int((now_ms-updated_ms)/60000))
    if delta_min < 60:
        return f"{delta_min}m"
    delta_hr=delta_min//60
    if delta_hr < 24:
        return f"{delta_hr}h"
    delta_day=delta_hr//24
    if delta_day < 7:
        return f"{delta_day}d"
    if delta_day < 30:
        return f"{delta_day//7}w"
    return f"{delta_day//30}mo"

rows=[]
for item in sorted(data, key=lambda x: x.get("updated", 0), reverse=True):
    sid=item.get("id", "")
    title=item.get("title", "")
    updated_ms=item.get("updated", 0)
    updated=rel_time(updated_ms)
    rows.append((sid, updated, title, updated_ms))

if not rows:
    print("No sessions found", file=sys.stderr)
    sys.exit(1)

idw=max((len(r[0]) for r in rows), default=0)
upw=max((len(r[1]) for r in rows), default=0)
reset="\u001b[0m"
blue="\u001b[34m"
yellow="\u001b[33m"
green="\u001b[32m"
red="\u001b[31m"
magenta="\u001b[35m"
cyan="\u001b[36m"
header="{}  {}  Title".format("Session ID".ljust(idw), "Age".rjust(upw))
header=f"{cyan}{header}{reset}"
print(f"\t\t\t{header}")
for sid, updated, title, updated_ms in rows:
    age_color=yellow
    if isinstance(updated_ms, (int, float)) and updated_ms:
        delta_min=max(0, int((now_ms-updated_ms)/60000))
        if delta_min < 60:
            age_color=green
        elif delta_min < 1440:
            age_color=yellow
        elif delta_min < 10080:
            age_color=red
        else:
            age_color=magenta

    display=f"{blue}{sid:<{idw}}{reset}  {age_color}{updated:>{upw}}{reset}  {reset}{title}{reset}"
    print(f"{sid}\t{updated}\t{title}\t{display}")
' <"$tmpfile" >"$listfile" 2>"$errfile"; then
    if [[ -s "$errfile" ]]; then
      cat "$errfile"
    else
      echo "Failed to build session list"
    fi
    rm -f "$tmpfile" "$errfile" "$listfile"
    return 1
  fi

  if [[ $(wc -l <"$listfile") -lt 2 ]]; then
    echo "No sessions to display"
    if [[ -s "$errfile" ]]; then
      cat "$errfile"
    fi
    rm -f "$tmpfile" "$errfile" "$listfile"
    return 1
  fi

  selection=$(FZF_DEFAULT_OPTS= FZF_DEFAULT_OPTS_FILE=/dev/null FZF_OPTS= \
    fzf --ansi --prompt='' --with-nth=4 --delimiter='\t' --header-lines=1 --header-first --layout=reverse <"$listfile" || true)
  rm -f "$tmpfile" "$errfile" "$listfile"

  if [[ -z "$selection" ]]; then
    return 1
  fi

  echo "$selection"
}

# Select an OpenCode session via fzf and copy its ID
oc_session_pick() {
  local selection id title updated
  selection=$(oc_session_select "$@") || return 1

  id=$(printf '%s\n' "$selection" | awk -F '\t' '{print $1}')
  updated=$(printf '%s\n' "$selection" | awk -F '\t' '{print $2}')
  title=$(printf '%s\n' "$selection" | awk -F '\t' '{print $3}')

  if command -v pbcopy >/dev/null 2>&1; then
    printf '%s' "$id" | pbcopy
  elif command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$id" | wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    printf '%s' "$id" | xclip -selection clipboard
  else
    echo "No clipboard tool found (pbcopy, wl-copy, xclip)"
    return 1
  fi

  local id_display
  if [[ -t 1 ]]; then
    id_display=$'\u001b[34m'"$id"$'\u001b[0m'
  else
    id_display="$id"
  fi

  if [[ -n "$updated" ]]; then
    echo "Copied session $id_display — $title ($updated)"
  else
    echo "Copied session $id_display — $title"
  fi
}

# Select an OpenCode session via fzf and continue it
oc_session_continue() {
  local selection id title updated
  selection=$(oc_session_select "$@") || return 1

  id=$(printf '%s\n' "$selection" | awk -F '\t' '{print $1}')
  updated=$(printf '%s\n' "$selection" | awk -F '\t' '{print $2}')
  title=$(printf '%s\n' "$selection" | awk -F '\t' '{print $3}')

  oc -s "$id"
}
alias ocsls=oc_session_pick
alias occ=oc_session_continue

# Tmux Operations
# ------------------------------------------------------------------------------

# _tmux_oc_prepare() {
#   if ! _tmux_oc_can_use_tmux; then
#     printf '\033[31m❌ Error: This command requires a local TMUX session.\033[0m\n' >&2
#     return 1
#   fi
#
#   (
#     local window_name="${PWD:t}"
#     if [[ -f .AAB ]]; then
#       # shellcheck disable=SC1091
#       source .AAB
#       if [[ -n "$TMUX_WINDOW_NAME" ]]; then
#         window_name="$TMUX_WINDOW_NAME"
#       fi
#     fi
#     tmux rename-window "$window_name"
#   )
#   tmux split-window -v
#   tmux select-pane -t "$TMUX_PANE"
# }
#
# tmux_oc_new_session() {
#   _tmux_oc_prepare || return 1
#   oc "$@"
# }
# alias tocsn=tmux_oc_new_session
# alias tocn=tmux_oc_new_session
#
# tmux_oc_continue_session() {
#   _tmux_oc_prepare || return 1
#   oc_session_continue "$@"
# }
# alias tocc=tmux_oc_continue_session

# Shell completions
# ------------------------------------------------------------------------------
# only in interactive shells
# if [[ -o interactive ]]; then
#   _opencode_load_completions() {
#     source <(opencode completion)
#     add-zsh-hook -d precmd _opencode_load_completions
#     unfunction _opencode_load_completions
#   }
#   # Defer until after compinit has run by using a precmd hook
#   autoload -Uz add-zsh-hook
#   add-zsh-hook precmd _opencode_load_completions
# fi



# Explicit OpenCode profiles; environment changes stay inside the launcher.
_opencode_profile() (
  local profile="$1"
  shift
  unset OCP_PROFILE OCP_PROFILE_FILE OCP_PATH
  unset OPENCODE_CONFIG OPENCODE_CONFIG_DIR OPENCODE_CONFIG_CONTENT
  export XDG_CONFIG_HOME="$HOME/.config/opencode-profiles/$profile/config"
  export XDG_DATA_HOME="$HOME/.local/share/opencode-profiles/$profile"
  export XDG_STATE_HOME="$HOME/.local/state/opencode-profiles/$profile"
  export XDG_CACHE_HOME="$HOME/.cache/opencode-profiles/$profile"
  if [[ "$profile" == personal ]]; then
    [[ ! -f "$HOME/.config/erebusbat/agent-personal-api-keys.sh" ]] || source "$HOME/.config/erebusbat/agent-personal-api-keys.sh"
  else
    unset OPENAI_API_KEY
  fi
  command opencode "$@"
)
opencode-personal() { _opencode_profile personal "$@"; }
opencode-work() { _opencode_profile upserve "$@"; }
alias ocp=opencode-personal
alias ocw=opencode-work
