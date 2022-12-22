let mapleader = "\<Space>"

" Zap line (delete w/o putting in a buffer
nnoremap <Leader>zl "_dd

" Remap search, join ops to keep centered
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

" Undo break points (i.e. create a new "undo" block when one of these characters are typed)
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ; ;<c-g>u
inoremap ( (<c-g>u
inoremap ) )<c-g>u
inoremap [ [<c-g>u
inoremap ] ]<c-g>u

" Relative Jumplist Mutations
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'

" Line Numbering
" See init.vim for hotkeys for toggling line numbers

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Search
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <Leader>/ :set nohlsearch!<CR>
nnoremap <Leader>rv :source ~/.config/nvim/init.vim<CR>
nnoremap <leader>rc :source ~/.config/nvim/color.vim<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pasteboard
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>p "+p
nnoremap <Leader>c "+y
nnoremap <Leader>Y "+y$
nnoremap <Leader>yG "+yG
nnoremap <Leader>YF gg"+yG
nnoremap <F7> gg"+yG
nnoremap Y y$
nnoremap <F12> :set paste<CR>"+p:set nopaste<CR>
inoremap <F12> <ESC>:set paste<CR>"+p:set nopaste<CR>
vnoremap <F12> "+y

" Alice copy block (see tguest/logs/2021-11-12.md#vim) and [[2022-04-20-Wed#Alice VIM]]
autocmd FileType vimwiki nnoremap <leader>fal :set ts=2 sts=2 noet<CR>gv:retab!<CR>:set ts=4 sts=4 shiftwidth=4 et<CR>gv:retab<CR>
autocmd FileType vimwiki nnoremap <leader>ald :set ts=2 sts=2 shiftwidth=2 et<CR>
autocmd FileType vimwiki vnoremap <leader>al <gv"+ygv>gv<ESC>jj0ww
autocmd FileType vimwiki nnoremap <leader>al V<gv"+ygv>gv<ESC>jj0ww

" List Toggle
autocmd FileType vimwiki nnoremap <leader>cc :VimwikiToggleListItem<CR>

" Remove column highlights
"   as they are messedup with link collapsing
autocmd FileType vimwiki set colorcolumn=

" Set tabsize (so coping to slack works correctly)
autocmd FileType vimwiki setlocal shiftwidth=4

"
" Method
"
" select current method
nmap <Leader>sm [mV]M
" Yank current method to system pasteboard (restore position using mark `T`)
nmap <Leader>ym mT[mV]M"+y`T

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Navigation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if g:aab_search == 'fzf'
  nnoremap <Leader>b :Buffers<CR>
  nnoremap <F5> :Buffers<CR>
  " nnoremap <F7> :FzfSwitchProject<CR>

  nnoremap <Leader>e :Files<CR>
  nnoremap <F8> :Files<CR>

  nnoremap <Leader>h :History<CR>

  nnoremap <Leader>r :BTags<CR>
  nnoremap <F6> :BTags<CR>
  nnoremap <Leader>R :Tags<CR>
  nnoremap <Leader>l :BLines!<CR>
  nnoremap <Leader>L :Lines!<CR>
  nnoremap <Leader>? :Helptags!<CR>
  " nnoremap <Leader>M :Maps!<CR>
  nnoremap <Leader>s :Filetypes<CR>
elseif g:aab_search == 'telescope'
  source ~/.config/nvim/telescope/hotkeys.vim
endif

nnoremap <Leader>F :GFiles<CR>


" Quicly toggle last pane/split
nnoremap <Tab> <C-w><C-p>
nnoremap <Leader><Space> :e #<CR>

" Vertical Split and edit alt file
nnoremap <C-w>6 :vsp<CR>:e #<CR>

" vim-easymotion
" (https://github.com/easymotion/vim-easymotion#minimal-configuration-tutorial)
" let g:EasyMotion_do_mapping = 0
" let g:EasyMotion_smartcase = 1
" nmap <Leader>jj <Plug>(easymotion-overwin-f)
" nmap <Leader>j <Plug>(easymotion-j)
" nmap <Leader>k <Plug>(easymotion-k)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Buffers / Windows
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <Leader>w :BD<CR>
nnoremap <C-s> :wa<CR>
inoremap <C-s> <Esc>:w<CR>
nnoremap <F9> :set wrap!<CR>
" nnoremap <F10> :setlocal spell!<CR>  SEE file.vim for keybinding for spelling


" Daily Log Commands
" nnoremap <Leader>ll :edit ~/daily-log.md<CR>
nnoremap <F4> Go<ESC>0C- [ ] <C-R>=strftime("%H:%M")<CR> -<Space>
inoremap <F3> <C-R>=strftime("%H:%M")<CR><Space>
inoremap <F4> <C-R>=strftime("%c")<CR><Space>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Dev
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <Leader>ph orequire 'pry'; binding.pry<ESC>
" // is technically correct, but \\ is easier to hit on my code keyboard
vnoremap \\ :Commentary<CR>
nnoremap \\ :Commentary<CR>
nnoremap // :Commentary<CR>

" Make Tags
nnoremap <Leader>mt :!/usr/local/bin/ctags --languages=ruby -R --exclude=node_modules --exclude=public/assets --exclude=tmp --exclude=vendor/assets --exclude=.git --exclude=public/packs-test --exclude=public/javascripts .<CR>

" vim-test
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

" QuickFix List
nnoremap <leader>] :cnext<CR>
nnoremap <leader>[ :cprev<CR>

" " Use <Tab> and <S-Tab> to navigate through popup menu
" inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" " use <Tab> as trigger keys
" imap <Tab> <Plug>(completion_smart_tab)
" imap <S-Tab> <Plug>(completion_smart_s_tab)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text Manipulation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Moving Text (w/o messing up registers)
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" inoremap <C-j> <esc>:m .+1<CR>==
" inoremap <C-k> <esc>:m .-2<CR>==
" nnoremap <leader>j :m .+1<CR>==
" nnoremap <leader>k :m .-2<CR>==

" Insert Spaces to col 80  https://vi.stackexchange.com/a/10501
function! SpacePadRight (len)
  exec 'norm '.(a:len - strlen(getline('.'))).'A '
endfunction
" &cc is the first color column
" command! SpacePadRight :call SpacePadRight(&cc)
command! SpacePadRight :call SpacePadRight(80)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Insert Mode
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
inoremap kj <ESC>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COC
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GoTo code navigation.
" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)
