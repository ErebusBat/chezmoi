
# list color tasks
[group('Color')]
color-ls:
  just --list --group Color

# Show one foreground color on the default background, plus optional backgrounds
[group('Color')]
color fg *backgrounds:
  #!/usr/bin/env zsh
  validate_color() {
    local label=$1 code=$2
    if [[ ! $code =~ '^[0-9]+$' ]] || (( code < 0 || code > 255 )); then
      print -u2 -- "error: $label must be a color code from 0 to 255, got '$code'"
      exit 1
    fi
  }

  sample() {
    local fg=$1 bg=${2:-default}

    if [[ $bg == default ]]; then
      printf "fg %3d on default: " "$fg"
      printf "\e[38;05;%sm %s \e[0m\n" "$fg" "Color $fg: The quick brown fox 0123456789"
    else
      printf "fg %3d on bg %3d:  " "$fg" "$bg"
      printf "\e[38;05;%sm\e[48;05;%sm %s \e[0m\n" "$fg" "$bg" "Color $fg on $bg: The quick brown fox 0123456789"
    fi
  }

  fg={{fg}}
  backgrounds=({{backgrounds}})

  validate_color foreground "$fg"
  sample "$fg"

  for bg in $backgrounds; do
    validate_color background "$bg"
    sample "$fg" "$bg"
  done

# Show one foreground color on one background color
[group('Color')]
color-on fg bg:
  @just -f /Users/andrew.burns/.config/starship.just starship-color {{fg}} {{bg}}

# Show one foreground color on optional backgrounds, six samples per row
[group('Color')]
color-backgrounds fg *backgrounds:
  #!/usr/bin/env zsh
  validate_color() {
    local label=$1 code=$2
    if [[ ! $code =~ '^[0-9]+$' ]] || (( code < 0 || code > 255 )); then
      print -u2 -- "error: $label must be a color code from 0 to 255, got '$code'"
      exit 1
    fi
  }

  fg={{fg}}
  backgrounds=({{backgrounds}})
  validate_color foreground "$fg"

  if (( ${#backgrounds[@]} == 0 )); then
    backgrounds=({0..255})
  fi

  print -r -- "foreground $fg on default:"
  printf "\e[38;05;%sm %s \e[0m\n\n" "$fg" "Color $fg: The quick brown fox 0123456789"

  print -r -- "foreground $fg on backgrounds:"
  local column=0
  for bg in $backgrounds; do
    validate_color background "$bg"
    printf "\e[38;05;%sm\e[48;05;%sm fg %3d / bg %3d \e[0m " "$fg" "$bg" "$fg" "$bg"
    (( ++column % 6 == 0 )) && printf "\n"
  done
  if (( column % 6 != 0 )); then
    printf "\n"
  fi

# Show foreground colors starting at a code, six samples per row
[group('Color')]
color-grid start bg='default' count='6':
  #!/usr/bin/env zsh
  validate_color() {
    local label=$1 code=$2
    if [[ ! $code =~ '^[0-9]+$' ]] || (( code < 0 || code > 255 )); then
      print -u2 -- "error: $label must be a color code from 0 to 255, got '$code'"
      exit 1
    fi
  }

  validate_count() {
    local count=$1
    if [[ ! $count =~ '^[0-9]+$' ]] || (( count < 1 )); then
      print -u2 -- "error: count must be a positive number, got '$count'"
      exit 1
    fi
  }

  start={{start}}
  bg={{bg}}
  count={{count}}
  validate_color foreground "$start"
  validate_count "$count"

  if [[ $bg != default ]]; then
    validate_color background "$bg"
  fi

  end=$((start + count - 1))
  (( end > 255 )) && end=255

  if [[ $bg == default ]]; then
    print -r -- "foregrounds $start..$end on default:"
  else
    print -r -- "foregrounds $start..$end on background $bg:"
  fi

  local column=0 fg
  for fg in {$start..$end}; do
    if [[ $bg == default ]]; then
      printf "\e[38;05;%sm fg %3d / default \e[0m " "$fg" "$fg"
    else
      printf "\e[38;05;%sm\e[48;05;%sm fg %3d / bg %3d \e[0m " "$fg" "$bg" "$fg" "$bg"
    fi
    (( ++column % 6 == 0 )) && printf "\n"
  done
  if (( column % 6 != 0 )); then
    printf "\n"
  fi

# Show colors and their codes
[group('Color')]
colors:
  #!/usr/bin/env zsh
  color_rgb() {
    local code=$1 level index r g b

    if (( code < 16 )); then
      local -a ansi_rgb=(
        "0 0 0"       "128 0 0"     "0 128 0"     "128 128 0"
        "0 0 128"     "128 0 128"   "0 128 128"   "192 192 192"
        "128 128 128" "255 0 0"     "0 255 0"     "255 255 0"
        "0 0 255"     "255 0 255"   "0 255 255"   "255 255 255"
      )
      print -r -- "$ansi_rgb[$((code + 1))]"
    elif (( code < 232 )); then
      level=(0 95 135 175 215 255)
      index=$((code - 16))
      r=$level[$((index / 36 + 1))]
      g=$level[$(((index % 36) / 6 + 1))]
      b=$level[$((index % 6 + 1))]
      print -r -- "$r $g $b"
    else
      level=$((8 + (code - 232) * 10))
      print -r -- "$level $level $level"
    fi
  }

  contrast_color() {
    local code=$1 r g b brightness
    read r g b <<< "$(color_rgb "$code")"
    brightness=$(((r * 299 + g * 587 + b * 114) / 1000))
    (( brightness >= 140 )) && print 16 || print 231
  }

  print -P "%B16 ANSI colors%b"
  for code in {0..15}; do
    printf "\e[38;05;%sm\e[48;05;%sm %3d \e[0m " "$(contrast_color "$code")" "$code" "$code"
    (( (code + 1) % 8 == 0 )) && printf "\n"
  done

  print -P "\n%B216 color cube%b"
  for code in {16..231}; do
    printf "\e[38;05;%sm\e[48;05;%sm %3d \e[0m " "$(contrast_color "$code")" "$code" "$code"
    (( (code - 15) % 6 == 0 )) && printf "\n"
    (( (code - 15) % 36 == 0 )) && printf "\n"
  done

  print -P "%B24 grayscale colors%b"
  for code in {232..255}; do
    printf "\e[38;05;%sm\e[48;05;%sm %3d \e[0m " "$(contrast_color "$code")" "$code" "$code"
    (( (code - 231) % 12 == 0 )) && printf "\n"
  done
  printf "\n"
