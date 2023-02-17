-- vim: ts=2 sts=2 sw=2 et
return {
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  },

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically


  -- System / Session Management
  "christoomey/vim-tmux-navigator",

  -- Spelling / Auto Complete
  'f3fora/cmp-spell',

  -- Code Formatting
  "tpope/vim-surround",

  -- Testing
  { 'mihyaeru21/nvim-lspconfig-bundler', dependencies = 'neovim/nvim-lspconfig' },

  -- Languages
  'othree/html5.vim',
  'pangloss/vim-javascript',
  'evanleck/vim-svelte',

}
