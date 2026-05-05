local wallpaper_enabled = true
local wezterm = require 'wezterm'
local os = require 'os'

local function file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then io.close(f) return true else return false end
end

local wallpaper_path = os.getenv("HOME") .. "/.config/wezterm/wallpaper.jpg"

if wallpaper_enabled and file_exists(wallpaper_path) then
  return {
    background = {
      {
        source = { File = wallpaper_path },
        horizontal_align = "Center",
        vertical_align = "Middle",
        hsb = {
          brightness = 0.0125,
        },
      },
    },
  }
else
  return {
    text_background_opacity = 1.0,
  }
end
