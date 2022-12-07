-- https://wezfurlong.org/wezterm/config/lua/wezterm/index.html
local wezterm = require 'wezterm';
return {
  hide_tab_bar_if_only_one_tab = true,
  default_prog = { "/bin/zsh" },
  set_environment_variables = {
    shell = "/bin/zsh",
  },

  -- Font Info
  -- color_scheme = "Hipster Green",
  -- color_scheme = "HaX0R_GR33N",
  color_scheme = "Guezwhoz",
  color_scheme = "Hybrid",
  color_scheme = "Dracula",
  -- color_scheme = "Gruvbox Dark",

  font = wezterm.font({
    --family="Comic Code",
    -- family="Comic Code Ligatures",
    family="ComicCodeLigatures Nerd Font",
    weight="Regular",
    harfbuzz_features={"calt=1", "clig=1", "liga=1"},
  }),
  -- => == !=
  -- font = wezterm.font("JetBrainsMono Nerd Font Mono"),
  font_size = 15,
}
