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
  use({
    'vim-test/vim-test',

    requires = { 'jgdavey/tslime.vim' },

    config = function()
      -- vim.cmd [[ let test#ruby#rspec#executable = 'clear; bundle exec spring rspec -f d' ]]
      vim.cmd [[ let test#ruby#rspec#executable = 'clear; bundle exec  rspec -f d' ]]
      vim.cmd [[
        nmap <silent> t<C-n> :TestNearest<CR>
        nmap <silent> t<C-f> :TestFile<CR>
        nmap <silent> t<C-s> :TestSuite<CR>
        nmap <silent> t<C-l> :TestLast<CR>
        nmap <silent> t<C-g> :TestVisit<CR>
        " Leader versions which will start the test (using maps above) then switch back to
        " code pane (via <leader><leader> shortcut).  Meant to be used with harpoon terminal
        nmap <silent> <leader>tn <C-s>t<C-n><leader><leader>
        nmap <silent> <leader>tl <C-s>t<C-l><leader><leader>
        nmap <silent> <leader>tf <C-s>t<C-f><leader><leader>
      ]]
    end,

  })
  -- use({ 'jgdavey/tslime.vim' })

  -- Languages
  use({ 'othree/html5.vim'  })
  use({ 'pangloss/vim-javascript' })
  use({ 'evanleck/vim-svelte' })

  use { 'mihyaeru21/nvim-lspconfig-bundler', requires = 'neovim/nvim-lspconfig' }
end

