
# list Starship tasks
[group('Starship')]
starship-ls:
  just --list --group Starship

# Show colors and their codes
[group('Starship')]
starship-colors:
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
