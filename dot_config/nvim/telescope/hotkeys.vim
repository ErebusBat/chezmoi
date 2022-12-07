" See https://github.com/nvim-telescope/telescope.nvim#vim-pickers
nnoremap <F5> <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>b <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>bb <cmd>lua require('telescope.builtin').buffers()<cr>

nnoremap <F8> <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>f <cmd>lua require('telescope.builtin').find_files()<cr>
" nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>

" nnoremap <F6> <cmd>lua require('telescope.builtin').current_buffer_tags()<cr>
" nnoremap <leader>r <cmd>lua require('telescope.builtin').current_buffer_tags()<cr>
" nnoremap <leader>tt <cmd>lua require('telescope.builtin').current_buffer_tags()<cr>
nnoremap <F6> <cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>
nnoremap <leader>r <cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>
nnoremap <leader>tt <cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>

nnoremap <leader>tp <cmd>lua require('telescope.builtin').builtin()<cr>

nnoremap <leader>gg <cmd>lua require('telescope.builtin').live_grep()<cr>

nnoremap <leader>qq <cmd>lua require('telescope.builtin').quickfix()<cr>

nnoremap <leader>mm <cmd>lua require('telescope.builtin').marks()<cr>

"
" LSP Pickers
" nnoremap <leader>lr <cmd>lua require('telescope.builtin').lsp_references()<cr>
" nnoremap <leader>lt <cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>

"
" Misc
nnoremap z= <cmd>lua require('telescope.builtin').spell_suggest()<cr>

"
" See Also
" git/after.vim
