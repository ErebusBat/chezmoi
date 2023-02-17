function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local wezterm = require 'wezterm';
-- local hostname = wezterm.hostname()
local wallpaper_enabled = true

local wallpapers = require('wallpapers')
-- local wallpapers = {
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/abstract/1ub6r4ns7eopdsol.jpg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/abstract/pexels-anni-roenkae-2156881.jpg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/doom-doom-slayer-4k-xm.jpg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/doom-ed-slayer-3h-1800x1169.jpg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/doom-vfr-5k-sg-1800x1169.jpg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/slayer_mark_neon.jpg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_hp_001.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_hp_002.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_hp_003.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_hp_004.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_lights_01.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_lights_02.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/dk_signs.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/ny22_001.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/ny22_002.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ah_20220918a.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ah_20230208.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ah_20230216.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ifly.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/linux_001.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/linux_002.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/van01.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/van02.jpeg',
--
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ah_20230208.jpeg',
--   wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ah_20230216.jpeg',
-- }
local wallpaper_to_use = wallpapers[math.random(#wallpapers)]
-- wallpaper_to_use = wallpapers[1]
-- wallpaper_to_use = wallpapers[#wallpapers]

return {
  File = wallpaper_to_use,
  Enabled = true,
}
