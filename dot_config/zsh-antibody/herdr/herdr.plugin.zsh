if ! command -v herdr 2>&1 >/dev/null; then return 0; fi

alias hr='herdr'
# alias hrr='herdr --remote'
function hrr() {
  local server=$1
  local title=$2

  case "$title:$server" in
    ?*:*)
      # Use the title the user gave us.
      ;;
    :outpost*)
      title="🏰Outpost"
      ;;
    :maze*|:nuc02*)
      title="🌽Maze"
      ;;
    :nuc*)
      title="🍿nuc01"
      ;;
    :dormouse*)
      title="🐭dormouse"
      ;;
    *)
      title=$server
      ;;
  esac

  if [[ -n $WEZTERM_PANE ]]; then
    wezterm cli set-tab-title "$title"
  fi
  echo "*** INFO: Connecting herdr session ($title) on $server"
  herdr --remote $server
}

function herdr-split() {
  local dir=${1:-right}
  case "$dir" in
    r*|R*)
      dir=right
      ;;
    d*|D*|v|V)
      dir=down
      ;;
    *)
      printf "FATAL: Unknown direction '$dir'\n" >&2
      return 1
  esac

  command herdr pane split --direction $dir
}
alias hrsp=herdr-split
alias hrvsp='herdr-split down'
