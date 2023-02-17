vim.opt.relativenumber = true
require('custom.reload')
vim.keymap.set('n', '==', ':set relativenumber!<CR>', { desc = 'Toggle Relative Number', noremap = true })

