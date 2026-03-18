#!/usr/bin/env zsh

# Enable alias expansion in this script
setopt aliases

# Source the tinted-shell profile helper to make base16_* aliases available
TINTED_SHELL_PATH="/Users/andrew.burns/.local/share/tinted-theming/tinty/repos/tinted-shell"
if [[ -f "$TINTED_SHELL_PATH/profile_helper.sh" ]]; then
  BASE16_SHELL_PATH="$TINTED_SHELL_PATH"
  source "$TINTED_SHELL_PATH/profile_helper.sh"
fi

# Save current theme and set up restoration
current_theme=""
if [[ -f "${BASE16_CONFIG_PATH:-$HOME/.config/tinted-theming}/theme_name" ]]; then
  current_theme=$(cat "${BASE16_CONFIG_PATH:-$HOME/.config/tinted-theming}/theme_name" 2>/dev/null)
fi

restore_theme() {
  if [[ -n "$current_theme" ]]; then
    local restore_cmd="base16_$current_theme"
    eval "$restore_cmd" 2>/dev/null || true
    echo ""
    echo "Restored theme: $current_theme"
  fi
}

# Set trap to restore theme on exit
trap restore_theme EXIT INT TERM

usage() {
  cat <<'EOF'
Usage: preview-base16-themes.sh [options] [theme1 theme2 ...]

Preview base16 themes interactively with visual feedback.

Options:
  -l, --list              List all available themes (no preview)
  -d, --dark-only         Preview only dark themes (no "light" in name)
  -L, --light-only        Preview only light themes (has "light" in name)
  -f, --filter=PATTERN    Filter themes by name pattern
  -h, --help              Show this help message

Arguments:
  theme1 theme2 ...       Specific themes to preview (if none, all are shown)

Examples:
  preview-base16-themes.sh                    # Preview all themes
  preview-base16-themes.sh -l                 # List all themes
  preview-base16-themes.sh terracotta embers  # Preview specific themes
  preview-base16-themes.sh -d                 # Preview only dark themes
  preview-base16-themes.sh -f orange          # Preview themes matching "orange"
EOF
}

discover_themes() {
  local script_dir="/Users/andrew.burns/.local/share/tinted-theming/tinty/repos/tinted-shell/scripts"
  local themes=""
  
  for f in "$script_dir"/base16-*.sh; do
    [[ -f "$f" ]] || continue
    local basename="${f##*/}"
    local theme="${basename#base16-}"
    theme="${theme%.sh}"
    if [[ -z "$themes" ]]; then
      themes="$theme"
    else
      themes="$themes
$theme"
    fi
  done
  
  echo "$themes" | sort -u
}

filter_themes() {
  local themes="$1"
  local pattern="$2"
  echo "$themes" | grep -i "$pattern" || true
}

filter_dark_only() {
  echo "$1" | grep -v "\-light$" | grep -v "light\-" | grep -v "Light" || true
}

filter_light_only() {
  echo "$1" | grep -E "(light|Light)" || true
}

preview_themes() {
  local themes="$1"
  local theme_list=(${(@f)themes})
  local total=${#theme_list}
  
  if [[ $total -eq 0 ]]; then
    echo "No themes to preview." >&2
    return 1
  fi
  
  echo ""
  echo "Previewing $total theme(s)."
  echo "Press Enter for next, 'b' then Enter to go back, 'q' then Enter to quit."
  echo ""
  sleep 1
  
  local i=1
  while [[ $i -le $total ]]; do
    local theme="${theme_list[$i]}"
    local cmd="base16_$theme"
    
    # Clear screen and show banner
    clear 2>/dev/null || printf '\033[2J\033[H'
    
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    printf "║   THEME: %-52s║\n" "$theme"
    echo "║                                                                ║"
    printf "║   Progress: %d of %d%-40s║\n" "$i" "$total" ""
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Apply the theme - just execute directly, the alias should be available
    eval "$cmd" 2>/dev/null || echo "Warning: Could not apply theme '$theme'" >&2
    
    # Show color samples
    echo ""
    echo "Color samples:"
    for c in {0..7}; do
      printf '\033[48;5;%dm  %d  \033[0m ' "$c" "$c"
    done
    echo ""
    for c in {8..15}; do
      printf '\033[48;5;%dm  %d  \033[0m ' "$c" "$c"
    done
    echo ""
    echo ""
    
    # Wait for user input
    printf "[Enter]=next, [b]=back, [q]=quit: "
    local key=""
    read -r key
    
    case "$key" in
      q|Q)
        echo "Quitting preview."
        return 0
        ;;
      b|B)
        if [[ $i -gt 1 ]]; then
          ((i = i - 1))
        else
          echo "Already at first theme."
          sleep 1
        fi
        ;;
      *)
        ((i = i + 1))
        ;;
    esac
  done
  
  echo ""
  echo "Finished previewing all themes."
}

list_themes() {
  local themes="$1"
  echo "$themes"
}

# Main
list_mode=0
dark_only=0
light_only=0
filter_pattern=""
specific_themes=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -l|--list)
      list_mode=1
      shift
      ;;
    -d|--dark-only)
      dark_only=1
      shift
      ;;
    -L|--light-only)
      light_only=1
      shift
      ;;
    -f|--filter)
      shift
      if [[ -z "$1" ]]; then
        echo "Error: --filter requires a pattern" >&2
        exit 2
      fi
      filter_pattern="$1"
      shift
      ;;
    --filter=*)
      filter_pattern="${1#--filter=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      specific_themes+=("$1")
      shift
      ;;
  esac
done

# Get themes
themes=""
if [[ ${#specific_themes[@]} -gt 0 ]]; then
  for t in "${specific_themes[@]}"; do
    if [[ -z "$themes" ]]; then
      themes="$t"
    else
      themes="$themes
$t"
    fi
  done
else
  themes=$(discover_themes)
fi

# Apply filters
if [[ -n "$filter_pattern" ]]; then
  themes=$(filter_themes "$themes" "$filter_pattern")
fi

if [[ $dark_only -eq 1 ]]; then
  themes=$(filter_dark_only "$themes")
fi

if [[ $light_only -eq 1 ]]; then
  themes=$(filter_light_only "$themes")
fi

# Execute
if [[ $list_mode -eq 1 ]]; then
  list_themes "$themes"
else
  preview_themes "$themes"
fi
