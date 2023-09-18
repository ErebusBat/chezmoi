return {
  "superDross/ticket.vim",
  lazy = false, -- Can't lazy load or `vimls` script doesn't work
  enabled = true,
  init = function()
    vim.g.auto_ticket = 0
    vim.g.auto_ticket_save = 0
    vim.g.auto_ticket_open = 0
    vim.g.auto_ticket_git_only = 1
    vim.g.ticket_use_fzf_default = 1
  end,
  keys = {
    { '<leader>ss', ':SaveSession<CR>',     { desc = '[S]ave [S]ession', noremap = true } },
    { '<leader>ls', ':OpenSession<CR>',     { desc = '[L]oad [S]ession', noremap = true } },
    { '<leader>cs', ':CleanupSessions<CR>', { desc = '[C]leanup [S]essions', noremap = true } },
  },
}
