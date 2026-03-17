WALLPAPER_OVERRIDE := 'wallpaper.jpg'
WALLPAPER_SRC_DIR := env('HOME') + "/.config/wezterm/wallpaper"
WALLPAPER_CONFIG := env('HOME') + "/.config/wezterm/wallpaper.yaml"
NO_ROTATE_MARKER_FILE := '/tmp/wezterm-wallpaper.static'

alias build := rotate

[default]
_safe: disable-ah-common random

_link_static src parent_dir=(WALLPAPER_SRC_DIR + "/"): random
  ln -s "{{ parent_dir }}{{ src }}" "{{ WALLPAPER_OVERRIDE }}"

# Rotate the wallpaper now
[group('Set Wallpaper')]
rotate: random
  #!/usr/bin/env zsh
  # Use the helper tool, if avilable as it will handle (re)building the
  # wallpapers.lua file
  if [[ -x $HOME/bin/rotate-wezterm-wallpaper ]]; then
    $HOME/bin/rotate-wezterm-wallpaper
  else
    # If not... just use poor mans
    touch wezterm.lua
  fi

# Allow rotate script to change wallpaper.
[group('Random')]
allow-rotate:
  [[ -f "{{ NO_ROTATE_MARKER_FILE }}" ]] && rm "{{ NO_ROTATE_MARKER_FILE }}" || true

# Temporarily prevent rotate script from changing wallpaper.
[group('Random')]
pause-rotate:
  touch "{{ NO_ROTATE_MARKER_FILE }}"

# Show if rotation script can rotate wallpapers or not
[group('Random')]
rotate-status:
  #!/bin/zsh
  if [[ -f "{{ NO_ROTATE_MARKER_FILE }}" ]]; then
    echo "Wallpaper Rotation is paused"
  else
    echo "Wallpaper Rotation is not paused"
  fi

# Use a random wallpaper
[group('Random')]
random: allow-rotate
  #!/usr/bin/env zsh
  override_file="{{ WALLPAPER_OVERRIDE }}"
  if [[ -L $override_file ]]; then
    rm $override_file || true
  elif [[ -e $override_file ]]; then
    echo "⚠️ WARNING: wallpaper is not a symlink, not removing!" >&2
  fi

# STATIC: Abstract - Triangle
[group('Set Wallpaper')]
@set-abs-triangle:
  just _link_static "abstract/cool-futuristic-abstract-background-with-shining-neon-lights.jpg"


# STATIC: Abstract - Triangle
[group('Set Wallpaper')]
@set-abs-grid:
  just _link_static "abstract/vecteezy_futuristic-technological-grid-background-digital-futurist_7207818.jpg"

# STATIC: SR71-space
[group('Set Wallpaper')]
@set-sr71:
  just _link_static "photos/SR71-Blackbird-Front.jpg"

# STATIC: DooM Slayer Mark
[group('Set Wallpaper')]
@set-slayer-mark:
  just _link_static "doom/slayer_mark_neon.jpg"

[group('Maintenance')]
enable-ah-common: random _enable-ah-common rotate

_enable-ah-common:
  #!/usr/bin/env python3
  from pathlib import Path
  import re
  path = Path("{{ WALLPAPER_CONFIG }}")
  text = path.read_text()
  updated, count = re.subn(r'(^ah_common: &ah_common\n\s+enabled:\s+)(true|false)\b', r'\1true', text, count=1, flags=re.MULTILINE)
  if count != 1:
      raise SystemExit(f"Could not update ah_common.enabled in {path}")
  path.write_text(updated)

[group('Maintenance')]
disable-ah-common: random _disable-ah-common rotate

_disable-ah-common:
  #!/usr/bin/env python3
  from pathlib import Path
  import re
  path = Path("{{ WALLPAPER_CONFIG }}")
  text = path.read_text()
  updated, count = re.subn(r'(^ah_common: &ah_common\n\s+enabled:\s+)(true|false)\b', r'\1false', text, count=1, flags=re.MULTILINE)
  if count != 1:
      raise SystemExit(f"Could not update ah_common.enabled in {path}")
  path.write_text(updated)
