return {
  'nvim-lualine/lualine.nvim', -- Fancier statusline
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = vim.g.x_lualine_theme,
        -- theme = 'base16',
        component_separators = '|',
        section_separators = '',
      },
    }
  end,
}
