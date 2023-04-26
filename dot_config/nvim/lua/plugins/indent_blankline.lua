return {
  'lukas-reineke/indent-blankline.nvim',
  enabled = false,
  config = function ()

    require('indent_blankline').setup {
      char = '┊',
      show_trailing_blankline_indent = false,
      show_end_of_line = true,
    }
  end,
}
