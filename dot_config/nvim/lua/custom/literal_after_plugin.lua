-- Setup autocmd so that we get our overrides after a PackerSync operation is complete
-- vim.cmd([[autocmd User PackerComplete source ~/.config/nvim/lua/custom/after_plugin.lua]])
-- vim.cmd([[autocmd User PackerCompileDone source ~/.config/nvim/lua/custom/after_plugin.lua]])

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume', noremap = true })
vim.keymap.set('n', '<leader>gb', require('telescope.builtin').git_branches, { desc = '[G]it [B]ranches', noremap = true })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = '[G]it [F]iles', noremap = true })

--------------------------------------------------------------------------------
-- Hotkeys
--------------------------------------------------------------------------------

-- Search
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Search next, keep centered', noremap = true })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Search prev, keep centered', noremap = true })
vim.keymap.set('n', 'J', 'mzJ`z', { desc = '', noremap = true })
vim.keymap.set('n', '<leader>/', ':set nohlsearch!<CR>', { desc = '', noremap = true })

-- Pasteboard / Clipboard
vim.keymap.set('i', '<F12>', '<Esc>:set paste<CR>"+p:set nopaste<CR>', { desc = 'Paste', noremap = true })
vim.keymap.set('v', '<F12>', '"+y', { desc = 'Copy selection', noremap = true })
vim.keymap.set('n', '<leader>yf', 'gg"+yG', { desc = 'Yank File', noremap = true })
vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank Line', noremap = true })
vim.keymap.set('n', '<F7>', 'gg"+yG', { desc = 'Yank File', noremap = true })
vim.keymap.set('n', '<leader>cp', '<CMD>let @+=expand("%")<CR><CMD>echo "Copied: " expand("%")<CR>', { desc = '[C]opy [P]roject path', noremap = true } )
vim.keymap.set('n', '<leader>cf', '<CMD>let @+=expand("%:p")<CR><CMD>echo "Copied: " expand("%:p")<CR>', { desc = '[C]opy [F]ull path', noremap = true } )

-- Save
vim.keymap.set('n', '<C-s>', ':wa<CR>', { desc = 'Save', noremap = true })
vim.keymap.set('i', '<C-s>', '<Esc>:wa<CR>', { desc = 'Save', noremap = true })

-- Viewport
vim.keymap.set('n', '<F9>', ':set wrap!<CR>', { desc = 'Toogle Word Wrap', noremap = true })
vim.keymap.set('i', 'kj', '<Esc>', { desc = 'Exit insert mode', noremap = true })

-- Window Management
-- vim.keymap.set('n', '<tab>', '<C-w><C-p>', { desc = 'Toggle last split', noremap = true })
vim.keymap.set('n', '<leader><space>', ':e #<CR>', { desc = 'Toggle last buffer', noremap = true })
vim.keymap.set('n', '<M-]>', ':bnext<CR>', { desc = 'Next Buffer', noremap = true })
vim.keymap.set('n', '<M-[>', ':bprev<CR>', { desc = 'Previous Buffer', noremap = true })

-- Line Movement
vim.keymap.set('v', 'J', [[ :move '>+1<CR>gv=gv ]], { desc = 'Move line(s) down', noremap = true })
vim.keymap.set('v', 'K', [[ :move '<-2<CR>gv=gv ]], { desc = 'Move line(s) up', noremap = true })

-- Source Code Related
vim.keymap.set('n', '<leader>sm', '[mV]M', { desc = '[S]elect [M]ethod', noremap = false })
vim.keymap.set('n', '<leader>ym', 'mT[mV]M"+y`T', { desc = '[Y]ank [M]ethod (System Pasteboard)', noremap = false })

-- vim.keymap.set('n', '<leader><F12>', [[ :set ft=ruby<CR> ]], { desc = 'Set FileType to Ruby', noremap = true })
--------------------------------------------------------------------------------
-- Colors / Appearance / Themes
--------------------------------------------------------------------------------
require("custom.theme-after-plugin")

--------------------------------------------------------------------------------
-- Source Control / Fugitive
--------------------------------------------------------------------------------
vim.cmd([[set diffopt+=vertical]])
vim.api.nvim_set_keymap("n", "<leader>gs", "<CMD>w<CR><CMD>Git<CR>", { noremap = true })

-- Diff options
-- vim.api.nvim_set_keymap("n", "<leader>gf", ":diffget //2<CR>", { noremap = true })
-- vim.api.nvim_set_keymap("n", "<leader>gj", ":diffget //3<CR>", { noremap = true })

-- Git Push (intentionally meant to be harder to push)
vim.cmd('autocmd FileType fugitive nnoremap g<C-p> :Git push<CR>')

--------------------------------------------------------------------------------
-- File Type Specifics
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

-- FileType setting
vim.cmd([[au BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,Thorfile,Procfile,Capfile,Guardfile,.Guardfile,config.ru,.railsrc,.irbrc,.pryrc,*.gemspec} set ft=ruby]])
vim.cmd([[au BufRead,BufNewFile *.zone set ft=bindzone]])
vim.cmd([[au BufRead,BufNewFile */tmux/*.conf set ft=tmux]])

-- Reset text width for gitcommits
vim.cmd([[au FileType gitcommit setlocal tw&]])

--------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------

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

-- Auto-save when losing foucs
vim.api.nvim_create_autocmd({ "FocusLost" }, {
  pattern = { "*" },
  -- Remove trailing spaces, then update(save):
  command = [[
    if &modifiable && expand('%') != ''
      %s/\s\+$//e
      update
    endif
  ]],
})


-- Session Management

-- " Undo break points (i.e. create a new "undo" block when one of these characters are typed)
vim.keymap.set('i', ',', ',<C-g>u', { desc = 'Create a undo block', noremap = true })
vim.keymap.set('i', '.', '.<C-g>u', { desc = 'Create a undo block', noremap = true })
vim.keymap.set('i', ';', ';<C-g>u', { desc = 'Create a undo block', noremap = true })
vim.keymap.set('i', '(', '(<C-g>u', { desc = 'Create a undo block', noremap = true })
vim.keymap.set('i', ')', ')<C-g>u', { desc = 'Create a undo block', noremap = true })
vim.keymap.set('i', '[', '[<C-g>u', { desc = 'Create a undo block', noremap = true })
vim.keymap.set('i', ']', ']<C-g>u', { desc = 'Create a undo block', noremap = true })


-- Alice copy block (see tguest/logs/2021-11-12.md#vim) and [[2022-04-20-Wed#Alice VIM]]
-- vim.cmd('autocmd FileType vimwiki nnoremap g<C-p> :Git push<CR>')
-- autocmd FileType vimwiki nnoremap <leader>fal :set ts=2 sts=2 noet<CR>gv:retab!<CR>:set ts=4 sts=4 shiftwidth=4 et<CR>gv:retab<CR>
-- autocmd FileType vimwiki nnoremap <leader>ald :set ts=2 sts=2 shiftwidth=2 et<CR>
-- autocmd FileType vimwiki vnoremap <leader>al <gv"+ygv>gv<ESC>jj0ww
-- autocmd FileType vimwiki nnoremap <leader>al V<gv"+ygv>gv<ESC>jj0ww

-- solargraph config

require('lspconfig').solargraph.setup(
  {
    solargraph = {
      useBundler = true,
      diagnostics = true
    }
  }
)

-- Folding
vim.cmd('set foldlevel=99')
vim.cmd('set foldmethod=expr')
vim.cmd('set foldexpr=nvim_treesitter#foldexpr()')

if vim.g.neovide then
  require('custom.neovide')
end

-- relativenumber

-- Blank vim notify area so we don't have Config Reloading...
vim.notify("", vim.log.levels.INFO)
