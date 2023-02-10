return {
  'ThePrimeagen/harpoon',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys ={
    { '<C-t><C-t>', '<leader>ht', desc = 'Open Harpoon Terminal', remap = true },
    { '<leader>ht', ':lua require("harpoon.term").gotoTerminal(1)<CR>', desc = 'Open Harpoon Terminal', remap = true },
    { '<leader>ha', ':lua require("harpoon.mark").add_file()<CR>', desc = 'Add file to harpoon', remap = true },
    { '<leader>hl', ':lua require("harpoon.ui").toggle_quick_menu()<CR>', desc = 'Show Harpoon List', remap = true },
    { '<leader>h1', ':lua require("harpoon.ui").nav_file(1)<CR>', desc = 'Navigate to Harpoon File 1', remap = true },
    { '<leader>h2', ':lua require("harpoon.ui").nav_file(2)<CR>', desc = 'Navigate to Harpoon File 2', remap = true },
    { '<leader>h3', ':lua require("harpoon.ui").nav_file(3)<CR>', desc = 'Navigate to Harpoon File 3', remap = true },
    { '<leader>h4', ':lua require("harpoon.ui").nav_file(4)<CR>', desc = 'Navigate to Harpoon File 4', remap = true },
    { '<leader>h5', ':lua require("harpoon.ui").nav_file(5)<CR>', desc = 'Navigate to Harpoon File 5', remap = true },
  },
}
