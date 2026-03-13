WALLPAPER_OVERRIDE := 'wallpaper.jpg'
WALLPAPER_SRC_DIR := env('HOME') + "/.config/wezterm/wallpaper"

@random:
  #!/usr/bin/env zsh
  override_file="{{ WALLPAPER_OVERRIDE }}"
  #[[ -f $override_file ]] && rm $override_file || true
  rm $override_file || true

@abs-triangle: random
  ln -s "{{ WALLPAPER_SRC_DIR }}/abstract/cool-futuristic-abstract-background-with-shining-neon-lights.jpg" "{{ WALLPAPER_OVERRIDE }}"
