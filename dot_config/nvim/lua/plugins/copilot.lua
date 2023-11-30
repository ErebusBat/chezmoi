return {
  'github/copilot.vim',
  enabled = true,
  lazy = false,
  init = function()
    vim.g.copilot_no_tab_map = true
  end,
  config = function()
    vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
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
    vim.keymap.set("i", "<C-q>", '<Plug>(copilot-previous)')
    vim.keymap.set("i", "<C-w>", '<Plug>(copilot-next)')
  end,
}

