return {
  "wting/gitsessions.vim",
  lazy = false,  -- Can't lazy load or `vimls` script doesn't work
  enabled = false,
  init = function()
    vim.g.gitsessions_disable_auto_load = 1
  end,
  keys = {
    { '<leader>ss', ':GitSessionSave<CR>', { desc = '[S]ave [S]ession', noremap = true } },
    { '<leader>ls', ':GitSessionLoad<CR>', { desc = '[L]oad [S]ession', noremap = true } },
  },
}
