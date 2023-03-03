function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- local wezterm = require 'wezterm';
-- local wallpaper_enabled = true

local wallpapers = require('wallpapers')
local wallpaper_to_use = wallpapers[math.random(#wallpapers)]

return {
  File = wallpaper_to_use,
  Enabled = true,
}
