function get_setup(name)
  return string.format('require("setup/%s")', name)
end

vim.cmd [[ let g:gitsessions_disable_auto_load = 1 ]]

return function(use)
  -- System / Session Management
  use({ "christoomey/vim-tmux-navigator" })
  use({ "qpkorr/vim-bufkill" })
  use({ "wting/gitsessions.vim" })

  -- Spelling / Auto Complete
  use({
    "micarmst/vim-spellsync",
    config = get_setup("spellsync"),
  })
  use({
    'f3fora/cmp-spell'
  })

  -- Appearance
  use({
    "RRethy/nvim-base16",
    config = get_setup('base16'),
  })
  use({
    'nvim-lualine/lualine.nvim', -- Fancier statusline
    config = get_setup('lualine'),
  })

  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    tag = 'nightly', -- optional, updated every week. (see issue #1193)
    config = get_setup('tree'),
  }

  -- Code Formatting
  use({ "tpope/vim-surround" })
  use({
    "windwp/nvim-autopairs",
    requires = { 'nvim-cmp' },
    config = get_setup('autopairs'),
  })
  use({
    'numToStr/Comment.nvim',
    config = get_setup('comment'),
  })

  -- Testing
  use({ 'vim-test/vim-test' })
  use({ 'jgdavey/tslime.vim' })

  -- Languages
  use({ 'othree/html5.vim'  })
  use({ 'pangloss/vim-javascript' })
  use({ 'evanleck/vim-svelte' })

  use { 'mihyaeru21/nvim-lspconfig-bundler', requires = 'neovim/nvim-lspconfig' }
end

