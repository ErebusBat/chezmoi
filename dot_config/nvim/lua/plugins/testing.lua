return {
  'vim-test/vim-test',
  dependencies = { 'jgdavey/tslime.vim' },
  config = function()
    -- vim.cmd [[ let test#ruby#rspec#executable = 'clear; bundle exec spring rspec -f d' ]]
    vim.cmd [[ let test#ruby#rspec#executable = 'clear; bundle exec  rspec -f d' ]]
    vim.cmd [[
        " Leader versions which will start the test (using maps above) then switch back to
        " code pane (via <leader><leader> shortcut).  Meant to be used with harpoon terminal
        nmap <silent> <leader>tn <C-s>t<C-n><leader><leader>
        nmap <silent> <leader>tl <C-s>t<C-l><leader><leader>
        nmap <silent> <leader>tf <C-s>t<C-f><leader><leader>
        ]]
  end,
  keys = {
    {'t<C-n>', ':TestNearest<CR>', { noremap = true } },
    {'t<C-f>', ':TestFile<CR>', { noremap = true } },
    {'t<C-s>', ':TestSuite<CR>', { noremap = true } },
    {'t<C-l>', ':TestLast<CR>', { noremap = true } },
    {'t<C-g>', ':TestVisit<CR>', { noremap = true } },
  }
}
