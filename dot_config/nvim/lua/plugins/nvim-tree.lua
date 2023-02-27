return {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons', -- optional, for file icons
  },
  tag = 'nightly', -- optional, updated every week. (see issue #1193)
  init = function ()
    -- disable netrw at the very start of your init.lua (strongly advised)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- Because netrw is disabled we need our own :Browse command so that :GBrowse will work
    vim.cmd [[command! -nargs=1 Browse silent execute '!open' shellescape(<q-args>,1)]]
  end,
  config = function ()
    -- empty setup using defaults
    require("nvim-tree").setup()

    -- https://github.com/nvim-tree/nvim-tree.lua#setup
    -- OR setup with some options
    -- require("nvim-tree").setup({
    --   sort_by = "case_sensitive",
    --   view = {
    --     width = 30,
    --     mappings = {
    --       list = {
    --         { key = "u", action = "dir_up" },
    --       },
    --     },
    --   },
    --   renderer = {
    --     group_empty = true,
    --   },
    --   filters = {
    --     dotfiles = true,
    --   },
    -- })
  end,
  keys = {
    -- vim.keymap.set('n', '<leader><F7>', ':NvimTreeFindFileToggle<CR>', { desc = 'Toggle Tree View for current file', noremap = true })
    {'<leader><F7>', ':NvimTreeFindFileToggle<CR>', { desc = 'Toggle Tree View for current file', noremap = true }},
  }
}
