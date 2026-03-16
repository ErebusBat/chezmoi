WALLPAPER_OVERRIDE := 'wallpaper.jpg'
WALLPAPER_SRC_DIR := env('HOME') + "/.config/wezterm/wallpaper"
WALLPAPER_CONFIG := env('HOME') + "/.config/wezterm/wallpaper.yaml"

# Use a random wallpaper
@random:
  #!/usr/bin/env zsh
  override_file="{{ WALLPAPER_OVERRIDE }}"
  #[[ -f $override_file ]] && rm $override_file || true
  rm $override_file || true

# STATIC: Abstract - Triangle
@set-abs-triangle: random
  ln -s "{{ WALLPAPER_SRC_DIR }}/abstract/cool-futuristic-abstract-background-with-shining-neon-lights.jpg" "{{ WALLPAPER_OVERRIDE }}"

# STATIC: Abstract - Triangle
@set-abs-grid: random
  ln -s "{{ WALLPAPER_SRC_DIR }}/abstract/vecteezy_futuristic-technological-grid-background-digital-futurist_7207818.jpg" "{{ WALLPAPER_OVERRIDE }}"

# STATIC: SR71-space
@set-sr71: random
  ln -s "{{ WALLPAPER_SRC_DIR }}/photos/SR71-Blackbird-Front.jpg" "{{ WALLPAPER_OVERRIDE }}"

@enable-ah-common:
  #!/usr/bin/env python3
  from pathlib import Path
  import re
  path = Path("{{ WALLPAPER_CONFIG }}")
  text = path.read_text()
  updated, count = re.subn(r'(^ah_common: &ah_common\n\s+enabled:\s+)(true|false)\b', r'\1true', text, count=1, flags=re.MULTILINE)
  if count != 1:
      raise SystemExit(f"Could not update ah_common.enabled in {path}")
  path.write_text(updated)

@disable-ah-common:
  #!/usr/bin/env python3
  from pathlib import Path
  import re
  path = Path("{{ WALLPAPER_CONFIG }}")
  text = path.read_text()
  updated, count = re.subn(r'(^ah_common: &ah_common\n\s+enabled:\s+)(true|false)\b', r'\1false', text, count=1, flags=re.MULTILINE)
  if count != 1:
      raise SystemExit(f"Could not update ah_common.enabled in {path}")
  path.write_text(updated)
