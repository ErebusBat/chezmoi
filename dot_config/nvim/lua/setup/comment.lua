require('Comment').setup({
  toggler = {
    line = [[\\]],
    block = 'gbc',
  },
  opleader = {
    line = [[\\]],
    block = 'gb',
  },
  extra = {
    above = 'gcO',  ---Add comment on the line above
    below = 'gco',  ---Add comment on the line below
    eol = 'gcA',    ---Add comment at the end of line
  },
})

