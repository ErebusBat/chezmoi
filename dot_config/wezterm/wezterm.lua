function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- https://wezfurlong.org/wezterm/config/lua/wezterm/index.html
local wezterm = require 'wezterm';
local monitor_count = tablelength(wezterm.gui.screens()["by_name"])
local hostname = wezterm.hostname()

if (hostname == 'MBP-ABURNS') then
  -- Depends if we are docked or not
  if (monitor_count == 2)
  then
    My_font_size = 16
  else
    My_font_size = 12
  end
elseif (hostname == 'thelio')  then
    My_font_size = 14
else
  My_font_size = 12
end

return {
  hide_tab_bar_if_only_one_tab = true,
  default_prog = { "/bin/zsh" },
  set_environment_variables = {
    shell = "/bin/zsh",
  },

  --
  -- Background
  --
  window_background_opacity = 0.5,
  background = {
    {
      source = {
        File = wezterm.home_dir .. '/.config/wezterm/wallpaper/doom/slayer_mark_neon.jpg',
        -- File = wezterm.home_dir .. '/.config/wezterm/wallpaper/lar/denver_hp_001.jpeg',
        -- File = wezterm.home_dir .. '/.config/wezterm/wallpaper/abstract/1ub6r4ns7eopdsol.jpg',
        -- File = wezterm.home_dir .. '/.config/wezterm/wallpaper/abstract/pexels-anni-roenkae-2156881.jpg',
      },
      -- repeat_x = 'Mirror',
      horizontal_align = "Center",
      vertical_align = "Middle",
      -- height = 'Contain',
      -- width = 'Contain',
      hsb = {
        -- brightness = 0.01, -- Photos
        brightness = 0.0125, -- Abstract
      },
      -- opacity = 0.99,
    },
  },

  -- Color schme should be overriden by base16 shell settings,
  -- but this provides a good default until that
  color_scheme = "Gruvbox Dark",

  -- Font Info

  font = wezterm.font({
    -- family="Comic Code",
    -- family="Comic Code Ligatures",
    family="ComicCodeLigatures Nerd Font",
    weight="Regular",
    harfbuzz_features={"calt=1", "clig=1", "liga=1"},
  }),
  -- => == !=

  font_size = My_font_size,

  mouse_bindings = {
    -- Change the default click behavior so that it populates
    -- the Clipboard rather the PrimarySelection.
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor 'Clipboard',
    },
  }
}
