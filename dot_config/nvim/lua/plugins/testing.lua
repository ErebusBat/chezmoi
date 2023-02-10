return {
  'vim-test/vim-test',
  dependencies = {
    'jgdavey/tslime.vim',
    'ThePrimeagen/harpoon',
  },
  init = function()
    vim.keymap.del('n', 't<C-n>')
    vim.keymap.del('n', 't<C-f>')
    vim.keymap.del('n', 't<C-l>')
    vim.keymap.del('n', 't<C-s>')
  end,
  config = function()
    vim.cmd [[
      let g:test#strategy = "harpoon"
      let g:test#harpoon_term = 1
    ]]

    -- vim.cmd [[ let test#ruby#rspec#executable = 'clear; bundle exec spring rspec -f d' ]]
    vim.cmd [[ let test#ruby#rspec#executable = 'clear; bundle exec  rspec -f d' ]]
  end,
  keys = {
    {'t<C-n>', '<cmd>TestNearest<CR>', desc = '[T]est [N]earest', remap = true },
    {'t<C-f>', ':TestFile<CR>', desc = '[T]est [F]ile', remap = true },
    {'t<C-l>', ':TestLast<CR>', desc = '[T]est [L]ast', remap = true },
    {'t<C-s>', ':TestSuite<CR>', desc = '[T]est [S]uite', remap = true },

    -- Leader versions which will start the test (using maps above) then switch back to
    -- code pane (via <leader><leader> shortcut).  Meant to be used with harpoon terminal
    {'<leader>tn', '<C-s>t<C-n><leader><leader>', desc = '[T]est [N]earest (harpoon)', remap = true },
    {'<leader>tf', '<C-s>t<C-f><leader><leader>', desc = '[T]est [F]ile (harpoon)', remap = true },
    {'<leader>tl', '<C-s>t<C-l><leader><leader>', desc = '[T]est [L]ast (harpoon)', remap = true },
  }
}
