" enter the current millenium
set nocompatible
syntax enable
" filetype plugin indent on
filetype plugin on

set path+=**

" Setup timeouts so that <Leader>w and <Leader>ww don't fight as much
set timeoutlen=600
set ttimeoutlen=0

" Set lazyredraw to help with tmux split / redraw issue
set nolazyredraw

set splitbelow
set splitright

" Have to source this here so we can set/change items after plugins
" are loaded
source ~/.config/nvim/plugins.vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Appearance  (see also plugins.vim)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set termguicolors

" See plugins.vim for adding / remobing themes
source ~/.config/nvim/color.vim


" Whitespace
autocmd BufWritePre * %s/\s\+$//e
set list

" Rel/Line Numbers, but only focused pane + hotkeys
if !exists('g:started_by_firenvim')
  set number relativenumber
  source ~/.config/nvim/relativenum/after.vim
endif
nnoremap <Space>ln :set rnu! <CR>
nnoremap == :set rnu! <CR>

" Display all matching files when we tab complete on command line
set wildmenu

" Don't display whitespace by default
set nolist

" Tabs
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File Management
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" AutoSave
set hidden
" set autowrite
set autoread
" inoremap <Esc> <Esc>:w<CR>
" inoremap <C-s> <Esc>:w<CR>
" " nnoremap <Leader>. BufWritePre * %s/\s\+$//e

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Other files
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"" Firenvim / things that should NOT be in Firenvim
if exists('g:started_by_firenvim')
  source ~/.config/nvim/firevim/after.vim
else
  luafile ~/.config/nvim/navigator.lua

  source ~/.config/nvim/open-browser/after.vim
  " source ~/.config/nvim/coc.vim
  " luafile ~/.config/nvim/lspconfig.lua
  luafile ~/.config/nvim/nvim-cmp/setup.lua
  source ~/.config/nvim/lang_rust/lsp.vim
  if g:aab_search == 'telescope'
    luafile ~/.config/nvim/telescope/setup.lua
  endif
endif

" Common to both firenvim/regular
source ~/.config/nvim/hotkeys.vim
source ~/.config/nvim/file.vim
source ~/.config/nvim/git/after.vim
source ~/.config/nvim/harpoon/after.vim
source ~/.config/nvim/lang_go/after.vim
source ~/.config/nvim/snip/after.vim
source ~/.config/nvim/spell/after.vim
luafile ~/.config/nvim/lualine/after.lua

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editor / Client specific settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:is_gui_vim=0
if has("gui_vimr")
  let g:is_gui_vim=1
  source ~/.config/nvim/vimr.vim
endif
if exists('g:gnvim')
  let g:is_gui_vim=1
  source ~/.config/nvim/gnvim.vim
endif
if exists('g:neovide')
  let g:is_gui_vim=1
  source ~/.config/nvim/neovide.vim
endif

" Disable mouse in terminal so that clicking on terminal window won't
" affect cursor or anything like that
if g:is_gui_vim == 0
  set mouse=
endif
