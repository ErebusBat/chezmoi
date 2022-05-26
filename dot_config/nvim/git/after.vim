set diffopt+=vertical
let g:gitsessions_disable_auto_load = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc / fugitive
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Git Status
nnoremap <leader>gs :G<CR>

" Git Diff Options
nmap <leader>gf :diffget //2<CR>
nmap <leader>gj :diffget //3<CR>

" Git Push (intentionally meant to be harder to push)
autocmd FileType fugitive nnoremap g<C-p> :Git push<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Telescope
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" See also telescope/setup.lua: - Hotkeys to delete branches
if g:aab_search == 'telescope'
  nnoremap <leader>GG <cmd>lua require('telescope.builtin').git_files()<cr>

  nnoremap <leader>gb <cmd>lua require('telescope.builtin').git_branches()<cr>
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GitSessions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sessions (see wting/gitsessions.vim)
nnoremap <Leader>ss :GitSessionSave<CR>
nnoremap <Leader>ls :GitSessionLoad<CR>
