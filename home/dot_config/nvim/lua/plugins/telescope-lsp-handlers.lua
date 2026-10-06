return {
  'gbrlsnchs/telescope-lsp-handlers.nvim',
  enabled = false,
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require("telescope").load_extension('lsp_handlers')
  end,
}
