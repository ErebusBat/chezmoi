-- https://wezfurlong.org/wezterm/config/lua/wezterm/index.html
local wezterm = require 'wezterm';
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
        -- File = '/Users/andrew.burns/.config/wezterm/wallpaper/doom/slayer_mark_neon.jpg',
        -- File = '/Users/andrew.burns/.config/wezterm/wallpaper/lar/denver_hp_001.jpeg',
        File = '/Users/andrew.burns/.config/wezterm/wallpaper/abstract/pexels-anni-roenkae-2156881.jpg',
      },
      -- repeat_x = 'Mirror',
      horizontal_align = "Center",
      vertical_align = "Middle",
      -- height = 'Contain',
      -- width = 'Contain',
      hsb = {
        brightness = 0.01,
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
  font_size = 14,

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
