return {
  "ThePrimeagen/git-worktree.nvim",
  enabled = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  keys = {
    {
      '<leader>Wc',
      ":lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>",
      desc = 'Git [W]orktree [C]reate',
      remap = true
    },
    {
      '<leader>Ws',
      ":lua require('telescope').extensions.git_worktree.git_worktrees()<CR>",
      desc = 'Git [W]orktree [S]witch',
      remap = true
    },
  },
  -- config = function ()
  -- end,
}
