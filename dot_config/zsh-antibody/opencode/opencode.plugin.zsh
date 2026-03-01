if [[ -d $HOME/.opencode/bin ]]; then
  export PATH=$HOME/.opencode/bin:$PATH
fi
if ! command -v opencode >/dev/null 2>&1; then
  return
fi

# Function that will auto "tag" a tmux window with a robot for cycling purposes
oc() {
  local script="$HOME/.config/tmux/scripts/set-window-prefix.sh"

  if [[ -x "$script" ]]; then
    "$script" set
    opencode "$@"
    "$script" clear
  else
    opencode "$@"
  fi
}

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

  local selection max_count tmpfile
  max_count="$1"

  local -a cmd
  cmd=(opencode session list --format json)
  if [[ -n "$max_count" ]]; then
    cmd+=(--max-count "$max_count")
  fi

  tmpfile=$(mktemp -t opencode_sessions.XXXXXX)
  echo "Fetching OpenCode sessions..."
  if ! "${cmd[@]}" >"$tmpfile"; then
    echo "Failed to fetch OpenCode sessions"
    rm -f "$tmpfile"
    return 1
  fi

  selection=$(python3 -c 'import json,sys,time
data=json.load(sys.stdin)
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
' <"$tmpfile" | FZF_DEFAULT_OPTS= FZF_DEFAULT_OPTS_FILE=/dev/null FZF_OPTS= \
  fzf --ansi --prompt='' --with-nth=4 --delimiter='\t' --header-lines=1 --header-first --layout=reverse)
  rm -f "$tmpfile"

  if [[ -z "$selection" ]]; then
    return 1
  fi

  echo "$selection"
}

# Select an OpenCode session via fzf and copy its ID
oc_session_pick() {
  local selection id title updated
  selection=$(oc_session_select "$1") || return 1

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

  if [[ -n "$updated" ]]; then
    echo "Copied session $id — $title ($updated)"
  else
    echo "Copied session $id — $title"
  fi
}

# Select an OpenCode session via fzf and continue it
oc_session_continue() {
  local selection id title updated
  selection=$(oc_session_select "$1") || return 1

  id=$(printf '%s\n' "$selection" | awk -F '\t' '{print $1}')
  updated=$(printf '%s\n' "$selection" | awk -F '\t' '{print $2}')
  title=$(printf '%s\n' "$selection" | awk -F '\t' '{print $3}')

  if [[ -n "$updated" ]]; then
    echo "Continuing session $id — $title ($updated)"
  else
    echo "Continuing session $id — $title"
  fi

  oc -s "$id"
}
alias ocsls=oc_session_pick
alias occ=oc_session_continue

# Load opencode completions (only in interactive shells)
# Defer until after compinit has run by using a precmd hook
if [[ -o interactive ]]; then
  _opencode_load_completions() {
    source <(opencode completion)
    add-zsh-hook -d precmd _opencode_load_completions
    unfunction _opencode_load_completions
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _opencode_load_completions
fi
