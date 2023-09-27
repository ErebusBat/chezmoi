--------------------------------------------------------------------------------
-- Theme INIT
--
-- This file is included BEFORE any plugins are loaded.  Its purpose is to set
-- variables that will be used _during_ the plugins configuration
-- See lua/custom/theme-after-plugin.lua for code that will run after the vim
-- environment is up and running
--------------------------------------------------------------------------------


vim.g.x_darkmode = true
-- vim.g.x_darkmode = false

-- Specific Logic
if vim.g.x_darkmode then
  -- vim.g.x_vim_colorscheme = 'base16-catppuccin'
  vim.g.x_vim_colorscheme = 'catppuccin-mocha'
  vim.g.x_lualine_theme = 'base16'
  vim.g.x_tabby_theme = 'base16'
else
  -- catppuccin catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
  vim.g.x_vim_colorscheme = 'catppuccin-latte'
  vim.g.x_lualine_theme = 'catppuccin-latte'
  vim.g.x_tabby_theme = 'catppuccin-latte'
end

-- See lua/custom/theme-after-plugin.lua for code that runs after plugins are up and running

