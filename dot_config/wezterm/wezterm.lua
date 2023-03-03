-- https://wezfurlong.org/wezterm/config/lua/wezterm/index.html
local wezterm = require 'wezterm';
local hostname = wezterm.hostname()
-- local wallpaper_enabled = true

local wallpaper_info = require('wallpaper')
local wallpaper_to_use = wallpaper_info.File
local wallpaper_enabled = wallpaper_info.Enabled

-- Defaults, can be overriden below in monitor setup
local background_hsb = {
  -- brightness = 0.00625,
  -- brightness = 0.0125,  -- Abstract
  -- brightness = 0.01, -- Photos
  brightness = 0.05, -- Travel
}

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

  font_size = 14,

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
-- Host Specific Settings
--
config["text_background_opacity"] = 0.9
if (hostname == 'MBP-ABURNS') then
  -- wallpaper_enabled = false
  -- wallpaper_to_use =   wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/doom-vfr-5k-sg-1800x1169.jpg'
  -- wallpaper_to_use = wallpapers[#wallpapers]

  -- wallpaper_enabled = false
  -- This can fail on linux, and we don't need it there so only call here
  local monitor_count = tablelength(wezterm.gui.screens()["by_name"])
  print("MBP-ABURNS monitor_count: " .. monitor_count)
  -- Depends if we are docked or not
  if (monitor_count == 2)
  then
    background_hsb["brightness"] = 0.02
    config["font_size"] = 14
  else
    config["font_size"] = 12
  end
elseif (hostname == 'thelio')  then
  config["font_size"] = 12

  -- Don't use random wallpaper on thelio
  -- wallpaper_to_use = wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/slayer_mark_neon.jpg'
  -- config["text_background_opacity"] = 0.5
end

--
-- Add in Background, if configured
--
-- CTRL-SHIFT-L
-- wezterm.GLOBAL.wallpaper
if wallpaper_enabled then
  wezterm.GLOBAL.wallpaper = wallpaper_to_use
  config["background"] = {
    {
      source = {
        File = wallpaper_to_use,
      },
      horizontal_align = "Center",
      vertical_align = "Middle",
      hsb = background_hsb,
    },
  }
else
  wezterm.GLOBAL.wallpaper = ""
  config["text_background_opacity"] = 1.0
end

wezterm.log_info("background:")
wezterm.log_info(config["background"])
wezterm.log_info("text_background_opacity:")
wezterm.log_info(config["text_background_opacity"])

return config
