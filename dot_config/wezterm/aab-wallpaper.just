WEZTERM_CFG_DIR := env('HOME') + "/.config/wezterm"
WALLPAPER_OVERRIDE := 'wallpaper.jpg'
WALLPAPER_SRC_DIR := WEZTERM_CFG_DIR + "/wallpaper"
WALLPAPER_OVERRIDE_FULL_PATH := WEZTERM_CFG_DIR + '/' + WALLPAPER_OVERRIDE
WALLPAPER_CONFIG := WEZTERM_CFG_DIR + "/wallpaper.yaml"
NO_ROTATE_MARKER_FILE := '/tmp/wezterm-wallpaper.static'
LOG_FILE := '/tmp/wallpaper.log'

alias build := rotate

[default]
_safe: random
  just group-disable ah
  just group-disable ddlg
  just rotate

_unsafe: random
  just group-enable ah
  just group-enable ddlg
  just rotate

_link_static src parent_dir=(WALLPAPER_SRC_DIR + "/"): random
  ln -s "{{ parent_dir }}{{ src }}" "{{ WALLPAPER_OVERRIDE }}"

_link_static_and_pause src parent_dir=(WALLPAPER_SRC_DIR + "/"): random
  just _link_static "{{ src }}" "{{ parent_dir }}"
  just pause-rotate

# Set a specific file as the wallpaper
[group('Set Wallpaper')]
set path:
  #!/usr/bin/env zsh
  pic="{{ path }}"
  if [[ ! -e $pic ]]; then
    echo "FATAL: $pic not found!"
    exit 1
  fi
  override_file="{{ WALLPAPER_OVERRIDE_FULL_PATH }}"
  if [[ -L $override_file ]]; then
    rm $override_file || true
  fi
  ln -s $pic $override_file

  log_file="{{ LOG_FILE }}"
  echo "[$(date)]" > $log_file
  echo "SET -> $pic"

# Remove wallpaper
[group('Set Wallpaper')]
none:
  #!/usr/bin/env zsh
  # override_file="{{ WALLPAPER_OVERRIDE }}"
  override_file="{{ WALLPAPER_OVERRIDE_FULL_PATH }}"
  if [[ -L $override_file ]]; then
    rm $override_file || true
  elif [[ -e $override_file ]]; then
    hash=$(shasum $override_file | awk '{ print $1 }')
    backup_file="${override_file:r}.${hash}.bak.${override_file:e}"
    echo "⚠️ WARNING: wallpaper is not a symlink!\n\tBacking up to $backup_file" >&2
    mv -vf $override_file $backup_file
  else
    echo "No ${override_file:t} found, nothing to be done."
  fi

# Rotate the wallpaper now, optional group(s) to use (comma-separated)
[group('Set Wallpaper')]
rotate group="": random
  #!/usr/bin/env zsh
  # Use the helper tool, if avilable as it will handle (re)building the
  # wallpapers.lua file
  if command -v mise &>/dev/null; then
    mise x ruby -- ./rotate-wallpaper {{ if group == "" { '' } else { '--group=' + group } }}
  elif [[ -x $HOME/bin/rotate-wezterm-wallpaper ]]; then
    echo "Calling ~/bin/rotate-wezterm-wallpaper..."
    $HOME/bin/rotate-wezterm-wallpaper {{ group }}
  else
    if [[ -z "{{ group }}" ]]; then
      # If not... just use poor mans
      touch wezterm.lua
    else
      echo "ERROR: You can not specify a group if you do not have the helper scripts installed!"
      exit 1
    fi
  fi

# Use a random wallpaper from one or more groups (comma-separated)
[group('Set Wallpaper')]
@set-group groups: allow-rotate
  #!/usr/bin/env zsh
  mise exec -- ruby rotate-wallpaper --group "{{ groups }}"

# Allow rotate script to change wallpaper.
[group('Random')]
@allow-rotate:
  [[ -f "{{ NO_ROTATE_MARKER_FILE }}" ]] && rm "{{ NO_ROTATE_MARKER_FILE }}" || true

# Temporarily prevent rotate script from changing wallpaper.
[group('Random')]
pause-rotate:
  touch "{{ NO_ROTATE_MARKER_FILE }}"
  just rotate-status

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
  just none

# STATIC: Abstract - Triangle
[group('Set Wallpaper')]
@set-abs-triangle:
  just _link_static_and_pause "abstract/cool-futuristic-abstract-background-with-shining-neon-lights.jpg"


# STATIC: Abstract - Triangle
[group('Set Wallpaper')]
@set-abs-grid:
  just _link_static_and_pause "abstract/vecteezy_futuristic-technological-grid-background-digital-futurist_7207818.jpg"

# STATIC: SR71-space
[group('Set Wallpaper')]
@set-sr71:
  just _link_static_and_pause "photos/SR71-Blackbird-Front.jpg"

# STATIC: DooM Slayer Mark
[group('Set Wallpaper')]
@set-slayer-mark:
  just _link_static_and_pause "doom/slayer_mark_neon.jpg"

# Show last log
[group('Maintenance')]
log:
  cat {{ LOG_FILE }}

# Show/parse config can specify 0-n groups (comma-separated)
[group('Maintenance')]
show-config group="":
  mise x ruby -- ./rotate-wallpaper -v --dry-run {{ if group == "" { '' } else { '--group=' + group } }}

# Modify config to enable given group
[group('Maintenance')]
group-enable name: random
  just _set-group-enabled "{{ name }}" "true"

# Modify config to disable given group
[group('Maintenance')]
group-disable name: random
  just _set-group-enabled "{{ name }}" "false"
  just rotate

_set-group-enabled name value:
  #!/usr/bin/env python3
  from pathlib import Path
  import re

  path = Path("{{ WALLPAPER_CONFIG }}")
  text = path.read_text()

  group_name = "{{ name }}"
  value = "{{ value }}"

  lines = text.splitlines(keepends=True)

  groups_start = None
  for i, line in enumerate(lines):
      if re.match(r"^groups:\s*$", line):
          groups_start = i
          break

  if groups_start is None:
      raise SystemExit(f"Could not find top-level 'groups:' block in {path}")

  group_start = None
  group_end = None

  i = groups_start + 1
  while i < len(lines):
      line = lines[i]

      if line and not line.startswith(" "):
          break

      if re.match(rf"^  {re.escape(group_name)}:\s*$", line):
          group_start = i
          j = i + 1
          while j < len(lines):
              next_line = lines[j]
              if next_line and not next_line.startswith(" "):
                  break
              if re.match(r"^  [^\s].*:\s*$", next_line):
                  break
              j += 1
          group_end = j
          break

      i += 1

  if group_start is None:
      raise SystemExit(f"Group '{group_name}' not found in {path}")

  enabled_index = None
  for k in range(group_start + 1, group_end):
      if re.match(r"^    enabled:\s+(true|false)\b", lines[k]):
          enabled_index = k
          break

  if enabled_index is not None:
      lines[enabled_index] = re.sub(
          r"(^    enabled:\s+)(true|false)\b",
          rf"\1{value}",
          lines[enabled_index],
          count=1,
      )
  else:
      lines.insert(group_end, f"    enabled: {value}\n")

  path.write_text("".join(lines))
