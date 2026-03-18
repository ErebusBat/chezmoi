local wezterm = require 'wezterm'
local hostname = wezterm.hostname()

local eb_window_decorations = 'RESIZE'
if hostname == 'USMB-JVK937H909' then
  -- Default is fine for work
else
  eb_window_decorations = 'TITLE | ' .. eb_window_decorations
end

return {
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  window_decorations = eb_window_decorations,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  window_close_confirmation = 'NeverPrompt',

  color_scheme = "catppuccin-mocha",

  font = wezterm.font({
    family="ComicCodeLigatures Nerd Font",
    weight='Medium',
    harfbuzz_features={ 'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08' },
  }),

  font_rules = {},

  selection_word_boundary = "|│ \t\n{}[]()\"'`<>=:;",
  text_background_opacity = 0.9,
}
