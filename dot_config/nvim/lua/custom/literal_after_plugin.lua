-- Setup autocmd so that we get our overrides after a PackerSync operation is complete
vim.cmd([[autocmd User PackerComplete source ~/.config/nvim/lua/custom/after_plugin.lua]])

vim.opt.relativenumber = true

vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume', noremap = true })

--------------------------------------------------------------------------------
-- Hotkeys
--------------------------------------------------------------------------------

-- Pasteboard / Clipboard
vim.keymap.set('i', '<F12>', '<Esc>:set paste<CR>"+p:set nopaste<CR>', { desc = 'Paste', noremap = true })
vim.keymap.set('v', '<F12>', '"+y', { desc = 'Copy selection', noremap = true })
-- vim.keymap.set('n', '<F12>', ':set paste<CR>"+p:set nopaste<CR>', { desc = 'Paste', noremap = true })

-- Save
vim.keymap.set('n', '<C-s>', ':wa<CR>', { desc = 'Save', noremap = true })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>', { desc = 'Save', noremap = true })

-- Comments
vim.keymap.set('n', '\\\\', ':normal gcc<CR>', { desc = 'Toogle Comment Line', noremap = true }) -- Literal `\\`
vim.keymap.set('v', '\\\\', ':normal gcc<CR>', { desc = 'Toogle Comment Block', noremap = true }) -- Literal `\\`

-- Viewport
vim.keymap.set('n', '<F9>', ':set wrap!<CR>', { desc = 'Toogle Word Wrap', noremap = true })
vim.keymap.set('i', 'kj', '<Esc>', { desc = 'Exit insert mode', noremap = true })

-- Window Management
vim.keymap.set('n', '<tab>', '<C-w><C-p>', { desc = 'Toggle last split', noremap = true })
vim.keymap.set('n', '<leader><space>', ':e #<CR>', { desc = 'Toggle last buffer', noremap = true })
vim.keymap.set('n', '<leader>w', ':BD<CR>', { desc = 'Close current buffer', noremap = true })

--------------------------------------------------------------------------------
-- Colors / Appearance / Themes
--------------------------------------------------------------------------------
vim.cmd('highlight Comment cterm=italic gui=italic')

-- vim.cmd('set colorcolumn=80,120')
vim.cmd('set cursorline')

-- Allow transparent bg
-- for further Highlight Groups see: https://neovim.io/doc/user/syntax.html#highlight-groups
vim.cmd('highlight Normal ctermbg=NONE guibg=NONE')
-- vim.cmd('highlight CursorLine ctermbg=NONE guibg=NONE')
vim.cmd('highlight LineNr ctermbg=NONE guibg=NONE')
vim.cmd('highlight SignColumn ctermbg=NONE guibg=NONE')
vim.cmd('highlight EndOfBuffer ctermbg=NONE guibg=NONE')
-- vim.cmd('highlight StatusLine ctermbg=NONE guibg=NONE')

-- Misc System
vim.api.nvim_set_keymap("n", "<leader>rv", "<cmd>lua ReloadConfig()<CR>", { noremap = true, silent = false })


--------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------

-- Disable auto comment continuation
vim.cmd('autocmd Filetype lua setlocal formatoptions-=cro')
vim.cmd('autocmd Filetype ruby setlocal formatoptions-=cro')
vim.cmd('autocmd Filetype sh setlocal formatoptions-=cro')
vim.cmd('autocmd Filetype zsh setlocal formatoptions-=cro')

-- Do some auto-endings
vim.cmd('au FileType lua inoremap <M-Space> <CR><CR>end<Esc>-cc')
vim.cmd('au FileType ruby inoremap <M-Space> <CR><CR>end<Esc>-cc')
vim.cmd('au FileType sh inoremap <M-Space> <CR><CR>fi<Esc>-cc')

-- Spelling
vim.cmd('autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_us')
vim.cmd('autocmd FileType gitcommit setlocal spell spelllang=en_us')
vim.cmd('autocmd BufRead,BufNewFile scratch.txt setlocal spell spelllang=en_us')
vim.cmd('set complete+=kspell')
vim.cmd('nnoremap <F10> :setlocal spell!<CR>')
-- Maybe see https://benfrain.com/refactor-your-neovim-init-lua-single-file-to-modules-with-packer/
--   and https://gist.github.com/benfrain/97f2b91087121b2d4ba0dcc4202d252f
-- require('cmp').setup({
    -- sources = {
        -- {
            -- name = 'spell',
            -- option = {
                -- keep_all_entries = false,
                -- enable_in_context = function()
                    -- return true
                -- end,
            -- },
        -- },
    -- },
-- })
vim.keymap.set("n", "z=", function()
  require("telescope.builtin").spell_suggest(require("telescope.themes").get_cursor({}))
end, { desc = "Spelling Suggestions" })

-- Re-read file on change
vim.cmd([[
    set autoread
    autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
                \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif
    autocmd FileChangedShellPost *
      \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None
]])

-- " Auto-save/read when losing/gaining foucs
vim.cmd([[
autocmd FocusGained * call AutoSaveLoadFocus('FocusGained')
autocmd FocusLost   * call AutoSaveLoadFocus('FocusLost')

function! AutoSaveLoadFocus(event)
  let curBufNum = winbufnr(winnr())
  let curBufName = bufname(curBufNum)
  let curBufHasFile = filereadable(curBufName)
  " echo "Current buffer readable: " . curBufHasFile
  " if curBufHasFile < 1
  "   echo "Current buffer does not have a backing file..."
  "   return
  " endif

  if mode() == 'n' && expand('%') != ''
    if a:event == 'FocusGained'
      " :edit
      " normal! mq
      " :edit
      " normal! `q
    elseif a:event == 'FocusLost'
      if &modified
        " Auto remove trailing whitespace and save
        sil! :%s/\s\+$//e
        :write
      endif
    else
      echo "Unknown event: " . a:event
    endif
  endif
endfunction
]])

print("after_plugin")
