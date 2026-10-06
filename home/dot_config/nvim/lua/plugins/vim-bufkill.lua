return {
  "qpkorr/vim-bufkill",
  lazy = false,
  keys = {
    -- vim.keymap.set('n', '<leader>w', ':BD<CR>', { desc = 'Close current buffer', noremap = true })
    { '<leader>w', ':BD<CR>', { desc = 'Close current buffer', noremap = true } },
  }
}
