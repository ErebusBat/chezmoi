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
  cmd = {
    'TestNearest',
    'TestFile',
    'TestLast',
    'TestSuite',
  },
  keys = {
    {'t<C-n>', '<cmd>TestNearest<CR>', desc = '[T]est [N]earest', remap = true },
    {'t<C-f>', '<cmd>TestFile<CR>', desc = '[T]est [F]ile', remap = true },
    {'t<C-l>', '<cmd>TestLast<CR>', desc = '[T]est [L]ast', remap = true },
    {'t<C-s>', '<cmd>TestSuite<CR>', desc = '[T]est [S]uite', remap = true },

    -- Leader versions which will start the test (using maps above) then switch back to
    -- code pane while preserving active/alt buffers using global marks Q (active),W (alt).
    -- Meant to be used with harpoon terminal
    {'<leader>tn', 'mQ<leader><leader>mW<leader><leader><C-s>t<C-n>`W`Q', desc = '[T]est [N]earest (harpoon)', remap = true },
    {'<leader>tf', 'mQ<leader><leader>mW<leader><leader><C-s>t<C-f>`W`Q', desc = '[T]est [F]ile (harpoon)', remap = true },
    {'<leader>tl', 'mQ<leader><leader>mW<leader><leader><C-s>t<C-l>`W`Q', desc = '[T]est [L]ast (harpoon)', remap = true },
  }
}
