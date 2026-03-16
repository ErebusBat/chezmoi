WALLPAPER_OVERRIDE := 'wallpaper.jpg'
WALLPAPER_SRC_DIR := env('HOME') + "/.config/wezterm/wallpaper"

# Use a random wallpaper
@random:
  #!/usr/bin/env zsh
  override_file="{{ WALLPAPER_OVERRIDE }}"
  #[[ -f $override_file ]] && rm $override_file || true
  rm $override_file || true

# STATIC: Abstract - Triangle
@set-abs-triangle: random
  ln -s "{{ WALLPAPER_SRC_DIR }}/abstract/cool-futuristic-abstract-background-with-shining-neon-lights.jpg" "{{ WALLPAPER_OVERRIDE }}"

# STATIC: SR71-space
@set-sr71: random
  ln -s "{{ WALLPAPER_SRC_DIR }}/photos/SR71-Blackbird-Front.jpg" "{{ WALLPAPER_OVERRIDE }}"
