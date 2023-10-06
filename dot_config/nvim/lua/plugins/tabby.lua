return {
  'nanozuki/tabby.nvim',
  enabled = not vim.g.started_by_firenvim,
  lazy = false,
  config = function ()
    vim.o.showtabline = 2
    vim.opt.sessionoptions:append('tabpages')
    vim.opt.sessionoptions:append('terminal')
    require('tabby.tabline').use_preset('tab_only', {
      nerdfont = true,
      lualine_theme = vim.g.x_lualine_theme -- see custom/theme-init.lua
    })
    end,
  keys = {
    { '<leader>]', "gt", { desc = 'Goto Next Tab', silent = false } },
    { '<leader>[', "gT", { desc = 'Goto Prev Tab', silent = false } },
  }
}
