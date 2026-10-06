--------------------------------------------------------------------------------
-- Theme AFTER PLUGIN
--
-- This file is included after the vim environment has been setup and plugins
-- have been loaded.
-- See lua/custom/theme-init.lua for variables that can be used to setup and
-- configure plugins.
--------------------------------------------------------------------------------

local function apply_highlights()
  vim.cmd('highlight Comment cterm=italic gui=italic')
  vim.cmd('set cursorline')

  -- For further Highlight Groups see:
  -- https://neovim.io/doc/user/syntax.html#highlight-groups
  vim.cmd('highlight Normal ctermbg=NONE guibg=NONE')
  vim.cmd('highlight NormalNC ctermbg=NONE guibg=NONE')
  vim.cmd('highlight LineNr ctermbg=NONE guibg=NONE')
  vim.cmd('highlight SignColumn ctermbg=NONE guibg=NONE')
  vim.cmd('highlight EndOfBuffer ctermbg=NONE guibg=NONE')
end

local group = vim.api.nvim_create_augroup('theme-after-plugin', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = apply_highlights,
  desc = 'Reapply local highlights after a theme change',
})

apply_highlights()
