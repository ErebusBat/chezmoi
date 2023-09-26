return {
  -- 'tpope/vim-endwise',
  'RRethy/nvim-treesitter-endwise',
  lazy = false,
  config = function ()
    require('nvim-treesitter.configs').setup {
      endwise = {
        enable = true,
      },
    }
  end,
}
