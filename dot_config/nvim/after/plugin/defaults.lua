vim.opt.relativenumber = true

vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- 
-- Hotkeys
-- 

-- Pasteboard / Clipboard
vim.keymap.set('i', '<F12>', '<Esc>:set paste<CR>"+p:set nopaste<CR>', { desc = 'Paste' })
vim.keymap.set('v', '<F12>', '"+y', { desc = 'Copy selection' })
-- vim.keymap.set('n', '<F12>', ':set paste<CR>"+p:set nopaste<CR>', { desc = 'Paste' })

-- Save
vim.keymap.set('n', '<C-s>', ':wa<CR>', { desc = 'Save' })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>', { desc = 'Save' })

-- Comments
vim.keymap.set('n', '\\\\', ':normal gcc<CR>', { desc = 'Toogle Comment Line' }) -- Literal `\\` 
vim.keymap.set('v', '\\\\', ':normal gcc<CR>', { desc = 'Toogle Comment Block' }) -- Literal `\\` 

-- Viewport
vim.keymap.set('n', '<F9>', ':set wrap!<CR>', { desc = 'Toogle Word Wrap' })
vim.keymap.set('i', 'kj', '<Esc>', { desc = 'Exit insert mode' }) 

-- Window Management
vim.keymap.set('n', '<tab>', '<C-w><C-p>', { desc = 'Toggle last split' })
vim.keymap.set('n', '<leader><space>', ':e #<CR>', { desc = 'Toggle last buffer' })
vim.keymap.set('n', '<leader>w', ':BD<CR>', { desc = 'Close current buffer' })

--
-- Colors / Appearance / Themes
--

