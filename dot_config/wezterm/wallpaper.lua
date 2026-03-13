local wezterm = require 'wezterm'
-- Config
local wallpapers_enabled = true
local override_path = wezterm.config_dir .. '/wallpaper.jpg'

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


local function file_exists(path)
  local f = io.open(path, "r")
  if f then f:close() end
  return f ~= nil
end

local wallpaper_to_use = ''

-- See if there is an override specified
local wallpaper_override_exists = file_exists(override_path)
if (wallpaper_override_exists) then
  wezterm.log_info("WALLPAPER: Override exists, setting: " .. override_path)
  wallpaper_to_use = override_path
else
  local wallpapers = require('wallpapers')
  wallpaper_to_use = wallpapers[math.random(#wallpapers)]
  wezterm.log_info("WALLPAPER: Random wallpaper selected! " .. wallpaper_to_use)
end

if not file_exists(wallpaper_to_use) then
  wezterm.log_info("WALLPAPER: Specified wallpaper doesn't exist! " .. wallpaper_to_use)
  wallpaper_to_use = ''
end


return {
  File = wallpaper_to_use,
  Enabled = wallpapers_enabled and wallpaper_to_use ~= '',
}
