" https://github.com/ThePrimeagen/harpoon

" Run tests via harpoon
let g:test#strategy = "harpoon"
let g:test#harpoon_term = 1
nnoremap <leader>ht  :lua require("harpoon.term").gotoTerminal(1)<CR>

"Keymaps
nnoremap <leader>ha :lua require("harpoon.mark").add_file()<CR>
if g:aab_search == 'telescopeBROKEN'
  nnoremap <leader>hl :lua require('telescope').extensions.harpoon.marks{}<CR>
else
  nnoremap <leader>hl :lua require("harpoon.ui").toggle_quick_menu()<CR>
endif

nnoremap <leader>h1 :lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <leader>h2 :lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <leader>h3 :lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <leader>h4 :lua require("harpoon.ui").nav_file(4)<CR>
nnoremap <leader>h5 :lua require("harpoon.ui").nav_file(5)<CR>

