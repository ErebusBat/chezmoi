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
  return {
    background = {
      {
        source = { Color = "#000000" },
        -- width/height required: Color layers default to 0×0 without explicit dimensions
        width = "100%",
        height = "100%",
      },
    },
  }
end
