-- This works in conjunction with plugin/relativenum.vim
vim.opt.relativenumber = true
vim.keymap.set('n', '==', ':set relativenumber!<CR>', { desc = 'Toggle Relative Number', noremap = true })

