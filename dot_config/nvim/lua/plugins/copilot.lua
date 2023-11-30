return {
  'github/copilot.vim',
  enabled = true,
  lazy = false,
  init = function()
    vim.g.copilot_no_tab_map = true
  end,
  config = function()
    vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
    -- vim.api.nvim_set_keymap("i", "<C-q>", '<Plug>(copilot-previous)', { silent = true, expr = true })
    -- vim.api.nvim_set_keymap("i", "<C-w>", '<Plug>(copilot-next)', { silent = true, expr = true })
    vim.g.copilot_filetypes = {
      ["*"] = false,
      ["javascript"] = true,
      ["typescript"] = true,
      ["lua"] = false,
      ["rust"] = true,
      ["c"] = true,
      ["c#"] = true,
      ["c++"] = true,
      ["go"] = true,
      ["python"] = true,
    }
  end,
}

