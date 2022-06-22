let g:go_use_lsp=1

if g:go_use_lsp == 1
  " LSP Config, should be handled elsewhere
  " Plug 'nvim-lua/plenary.nvim'
  " Plug 'crispgm/nvim-go'
  " Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

  " Plug 'wbthomason/packer.nvim'
  " Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  " Plug 'nvim-treesitter/nvim-treesitter'
  Plug 'ray-x/go.nvim'
else
  Plug 'fatih/vim-go'
endif

