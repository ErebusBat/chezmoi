local M= {
  follow_link = function()
    if require('obsidian').util.cursor_on_markdown_link() then
      return "<cmd>ObsidianFollowLink<CR>"
    else
      return "gf"
    end
  end,
}

return {
  'epwalsh/obsidian.nvim',
  enabled = false,
  config = function()
    require("obsidian").setup({
      dir = "/Users/andrew.burns/Documents/Obsidian/vimwiki",
      completion = {
        nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
      }
    })
  end,
  ft = { 'markdown' },
  keys = {
    {'n', 'gf', M.follow_link, desc = 'Obsidian [F]ollow Link'}
  },
}
