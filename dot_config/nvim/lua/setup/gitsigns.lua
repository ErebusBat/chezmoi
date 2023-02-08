-- Gitsigns
-- See `:help gitsigns.txt`
-- print 'gitsigns included'
return function()
  print 'gitsigns ran'
  require('gitsigns').setup {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
  }
end
