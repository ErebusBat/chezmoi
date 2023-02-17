function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- https://wezfurlong.org/wezterm/config/lua/wezterm/index.html
local wezterm = require 'wezterm';
local hostname = wezterm.hostname()
local wallpaper_enabled = true
local my_font_size = 14

--
-- Randomized Wallpaper
--
local wallpapers = {
  wezterm.home_dir .. '/.config/wezterm/wallpaper/abstract/1ub6r4ns7eopdsol.jpg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/abstract/pexels-anni-roenkae-2156881.jpg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/doom-doom-slayer-4k-xm.jpg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/doom-ed-slayer-3h-1800x1169.jpg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/doom-vfr-5k-sg-1800x1169.jpg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/slayer_mark_neon.jpg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_hp_001.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_hp_002.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_hp_003.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_hp_004.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_lights_01.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_lights_02.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/dk_signs.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/ny22_001.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/ny22_002.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ah_20220918a.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ah_20230208.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ah_20230216.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ifly.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/linux_001.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/linux_002.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/van01.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/van02.jpeg',

  wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ah_20230208.jpeg',
  wezterm.home_dir .. '/.config/wezterm/wallpaper/photos/ah_20230216.jpeg',
}
local wallpaper_to_use = wallpapers[math.random(#wallpapers)]

--
-- Host Specific Settings
--
if (hostname == 'MBP-ABURNS') then
  -- wallpaper_enabled = false
  -- wallpaper_to_use =   wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/doom-vfr-5k-sg-1800x1169.jpg'
  -- wallpaper_to_use = wallpapers[#wallpapers]

  -- wallpaper_enabled = false
  -- This can fail on linux, and we don't need it there so only call here
  local monitor_count = tablelength(wezterm.gui.screens()["by_name"])
  -- Depends if we are docked or not
  if (monitor_count == 2)
  then
    my_font_size = 16
  else
    my_font_size = 14
  end
elseif (hostname == 'thelio')  then
  my_font_size = 12

  -- Don't use random wallpaper on thelio
  wallpaper_to_use = wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/slayer_mark_neon.jpg'
end

--
-- Build Base Config
--
local config = {
  hide_tab_bar_if_only_one_tab = true,
  default_prog = { "/bin/zsh" },
  set_environment_variables = {
    shell = "/bin/zsh",
  },

  keys = {
    {
      key = 'F12',
      mods = 'SUPER|CTRL|SHIFT|ALT',
      action = wezterm.action.ReloadConfiguration,
    },
    {
      key = 'n',
      mods = 'SHIFT|CTRL',
      action = wezterm.action.ToggleFullScreen,
    },
  },

  -- See below for background

  -- Color schme should be overriden by base16 shell settings,
  -- but this provides a good default until that
  color_scheme = "Gruvbox Dark",

  -- Font Info => == !=
  font = wezterm.font({
    -- family="Comic Code",
    -- family="Comic Code Ligatures",
    family="ComicCodeLigatures Nerd Font",
    weight="Regular",
    harfbuzz_features={"calt=1", "clig=1", "liga=1"},
  }),

  font_size = my_font_size,

  mouse_bindings = {
    -- Change the default click behavior so that it populates
    -- the Clipboard rather the PrimarySelection.
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection',
    },
  }
}

--
-- Add in Background, if configured
--
if wallpaper_enabled then
  config["window_background_opacity"] = 0.5
  config["background"] = {
    {
      source = {
        File = wallpaper_to_use,
      },
      horizontal_align = "Center",
      vertical_align = "Middle",
      hsb = {
        -- brightness = 0.0125,  -- Abstract
        -- brightness = 0.01, -- Photos
        brightness = 0.05, -- Travel
      },
    }
  }
end

return config
