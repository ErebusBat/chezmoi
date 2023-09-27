return {
  'nanozuki/tabby.nvim',
  lazy = false,
  config = function ()
    vim.o.showtabline = 2
    vim.opt.sessionoptions:append('tabpages')
    vim.opt.sessionoptions:append('terminal')
    require('tabby.tabline').use_preset('tab_only', {
      nerdfont = true, -- whether use nerdfont
      -- lualine_theme = 'base16' -- lualine theme named
      lualine_theme = vim.g.x_tabby_theme -- see custom/theming.lua
    })
    end,
  keys = {
    { '<leader>]', "gt", { desc = 'Goto Next Tab', silent = false } },
    { '<leader>[', "gT", { desc = 'Goto Prev Tab', silent = false } },
  }
}
