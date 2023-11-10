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
  -- brightness = 0.05, -- Travel
  brightness = 0.0,
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
  color_scheme = "catppuccin-mocha",

  -- Font Info => == !=
  -- font = wezterm.font({
  --   family="Comic Code Ligatures",
  --   -- family="Fira Code",
  --   weight="Regular",
  --   harfbuzz_features={"calt=1", "clig=1", "liga=1"},
  -- }),
  -- font = wezterm.font 'Comic Code Ligatures',


  font = wezterm.font({
    -- family='Monaspace Neon',
    family='Monaspace Argon',
    -- family='Monaspace Xenon',
    -- family='Monaspace Radon',
    -- family='Monaspace Krypton',
    weight='Regular',
    harfbuzz_features={ 'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08' },
  }),

  -- https://wezfurlong.org/wezterm/config/lua/config/font_rules.html
  -- wezterm ls-fonts
  -- wezterm ls-fonts --list-system
  font_rules = {
    --
    -- Italic (comments)
    --
    {
      intensity = 'Normal',
      italic = true,
      font = wezterm.font({
        family="Monaspace Radon",
        weight="Light",
        stretch="Normal",
        style="Normal",
        harfbuzz_features={ 'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08' },
      })
    },

    --
    -- Bold (highlighting)
    --
    {
      intensity = 'Bold',
      italic = false,
      font = wezterm.font({
        family="Monaspace Krypton",
        weight="Light",
        stretch="Normal",
        style="Normal",
        harfbuzz_features={ 'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08' },
      })
    },
  },

  -- See below for font size overriding based on machine we are on
  -- font_size = 14,

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
-- Clipboard
--
config.selection_word_boundary = "|│ \t\n{}[]()\"'`<>=:;"


--
-- Font Size / Host Specific Settings
--
config["text_background_opacity"] = 0.9
function calc_set_font_size(window)
  local overrides = window:get_config_overrides() or {}
  local monitor_count = tablelength(wezterm.gui.screens()["by_name"])
  overrides.font_size = 10
  print(hostname .. " monitor_count: " .. monitor_count)

  if (hostname == 'MBP-ABURNS') then
    -- This can fail on linux, and we don't need it there so only call here
    -- Depends if we are docked or not
    if (monitor_count == 2)
    then
      background_hsb["brightness"] = 0.02
      overrides.font_size = 12
    else
      overrides.font_size = 14
    end
  elseif (hostname == 'thelio')  then
    overrides.font_size = 8
  elseif (hostname == 'dartp6')  then
    overrides.font_size = 10
  end
  print("Setting font_size to " .. overrides.font_size .. " for " .. hostname .. " monitors=" .. monitor_count)

  window:set_config_overrides(overrides)
end
wezterm.on('window-config-reloaded', function(window)
  calc_set_font_size(window)
end)
wezterm.on('window-resized', function(window, _pane)
  calc_set_font_size(window)
end)

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
