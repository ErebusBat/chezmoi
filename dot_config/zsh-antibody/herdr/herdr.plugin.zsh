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
