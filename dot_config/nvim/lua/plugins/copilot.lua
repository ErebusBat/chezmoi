return {
  'github/copilot.vim',
  enabled = true,
  lazy = false,
  init = function()
    vim.g.copilot_no_tab_map = true
  end,
  config = function()
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
    vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

    vim.keymap.set("i", "<C-t>", '<Plug>(copilot-previous)')
    vim.keymap.set("i", "<C-y>", '<Plug>(copilot-next)')
    -- vim.keymap.set("i", "<C-q>", 'copilot#Accept("")', { silent = true, expr = true })
    vim.api.nvim_set_keymap("i", "<C-q>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
    vim.keymap.set("i", "<C-w>", 'copilot#AcceptWord("")', { silent = true, expr = true })
  end,
}

