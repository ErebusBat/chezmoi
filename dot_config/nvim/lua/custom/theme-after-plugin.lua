--------------------------------------------------------------------------------
-- Theme AFTER PLUGIN
--
-- This file is included after the vim environment has been setup and plugins
-- have been loaded.
-- See lua/custom/theme-init.lua for variables that can be used to setup and
-- configure plugins.
--------------------------------------------------------------------------------


vim.cmd('highlight Comment cterm=italic gui=italic')

-- vim.cmd('set colorcolumn=80,120')
vim.cmd('set cursorline')

-- Allow transparent bg, but only in darkmode otherwise it overrides light theme
if vim.g.x_darkmode then
  -- for further Highlight Groups see: https://neovim.io/doc/user/syntax.html#highlight-groups
  vim.cmd('highlight Normal ctermbg=NONE guibg=NONE')
  vim.cmd('highlight NormalNC ctermbg=NONE guibg=NONE')
  vim.cmd('highlight LineNr ctermbg=NONE guibg=NONE')
  vim.cmd('highlight SignColumn ctermbg=NONE guibg=NONE')
  vim.cmd('highlight EndOfBuffer ctermbg=NONE guibg=NONE')
  -- vim.cmd('highlight CursorLine ctermbg=NONE guibg=NONE')
  -- vim.cmd('highlight StatusLine ctermbg=NONE guibg=NONE')
end
vim.cmd.colorscheme(vim.g.x_vim_colorscheme)

