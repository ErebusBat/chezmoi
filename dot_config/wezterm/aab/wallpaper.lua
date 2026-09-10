local wallpaper_enabled = false
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
  -- Do not restore this fallback: an explicit background masks color_scheme and forces a black window.
  -- source = { Color = "#000000" },
  -- Leave background unset so the selected color scheme supplies it.
  return {}
end
