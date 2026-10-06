return {
  'L3MON4D3/LuaSnip',
  -- enabled = false,
  config = function ()
    require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/snippets"})

    vim.cmd [[ command! LuaSnipEdit :lua require("luasnip.loaders").edit_snippet_files() ]]
  end
}
