" let g:fzf_preview_window = ''
call plug#begin('~/.vim/plugged')

let g:aab_search='telescope'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Behaviour
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This has to be here or PlugInstall will un-install it :/
source ~/.config/nvim/firevim/plugin.vim
if !exists('g:started_by_firenvim')
  Plug 'jremmen/vim-ripgrep'
  " Plug 'benwainwright/fzf-switch-project'
  if g:aab_search == 'fzf'
    Plug 'stsewd/fzf-checkout.vim'
  endif
  Plug 'christoomey/vim-tmux-navigator'

  Plug 'wting/gitsessions.vim'

  source ~/.config/nvim/open-browser/plugin.vim

  " Plug 'thoughtbot/vim-rspec'
  Plug 'vim-test/vim-test'
  Plug 'jgdavey/tslime.vim'
  source ~/.config/nvim/git/plugin.vim

  " Plug 'ycm-core/YouCompleteMe'
  " Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " let g:coc_node_path = '/usr/local/opt/node@12/bin/node'

  Plug 'vimwiki/vimwiki'
  let g:vimwiki_list = [{'path': '~/vimwiki/',
                        \ 'syntax': 'markdown', 'ext': '.md'}]
  let g:vimwiki_listsyms = ' x' " other: ' ○◐●✓'

  " LSP Related Extensions
  Plug 'neovim/nvim-lspconfig'
  " Plug 'nvim-lua/lsp_extensions.nvim'
  " Plug 'nvim-lua/completion-nvim'
  Plug 'ray-x/guihua.lua', {'do': 'cd lua/fzy && make' }
  Plug 'ray-x/navigator.lua'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  source ~/.config/nvim/nvim-cmp/plugin.vim
endif

if g:aab_search == 'fzf'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
elseif g:aab_search == 'telescope'
  source ~/.config/nvim/telescope/plugin.vim
endif
Plug 'tpope/vim-commentary'
" Plug 'easymotion/vim-easymotion'
Plug 'justinmk/vim-sneak'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-surround'
Plug 'unblevable/quick-scope'

source ~/.config/nvim/lualine/plugin.vim

Plug 'osyo-manga/vim-brightest'

source ~/.config/nvim/harpoon/plugin.vim
source ~/.config/nvim/snip/plugin.vim

" Do not delete splits when :BUN, :BD, :BW
Plug 'qpkorr/vim-bufkill'

source ~/.config/nvim/spell/plugin.vim

" Plug 'liuchengxu/vim-which-key'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Appearance
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plug 'junegunn/limelight.vim'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Color Schemes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 'color' and 'bg=light|dark' in color.vim, it will break if here
" Plug 'crusoexia/vim-dracula'
" Plug 'rakr/vim-one'
Plug 'morhetz/gruvbox'
" Plug 'preservim/vim-colors-pencil'
" Plug 'altercation/vim-colors-solarized'
Plug 'chriskempson/base16-vim'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntaxes / FileTypes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'plasticboy/vim-markdown'

Plug 'vim-ruby/vim-ruby'
" Plug 'posva/vim-vue'
Plug 'slim-template/vim-slim'

Plug 'fgsch/vim-varnish'

Plug 'hashivim/vim-terraform'
Plug 'glench/vim-jinja2-syntax'

Plug 'kchmck/vim-coffee-script'

Plug 'tpope/vim-endwise'
Plug 'jiangmiao/auto-pairs'

source ~/.config/nvim/lang_rust/plugin.vim
source ~/.config/nvim/lang_go/plugin.vim

call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" test#strategy is set in harpoon/after.vim
" let test#strategy = "tslime"
" let g:tslime_always_current_session = 1
" let g:tslime_always_current_window = 1
" let test#ruby#rspec#executable = 'rbenv exec rspec -f d'
let test#ruby#rspec#executable = 'clear; bundle exec rspec -f d'
