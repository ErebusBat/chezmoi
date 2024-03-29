return {
  'ThePrimeagen/harpoon',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  keys ={
    { '<C-t><C-t>', '<leader>ht', desc = 'Open Harpoon Terminal', remap = true },
    { '<leader>ht', ':lua require("harpoon.term").gotoTerminal(1)<CR>', desc = 'Open Harpoon Terminal', remap = true },
    { '<leader>hm', ':Telescope harpoon marks<CR>', desc = 'Open Harpoon Marks', remap = true },
    { '<leader>ha', ':lua require("harpoon.mark").add_file()<CR>', desc = 'Add file to harpoon', remap = true },
    { '<leader>hl', ':lua require("harpoon.ui").toggle_quick_menu()<CR>', desc = 'Show Harpoon List', remap = true },
    { '<leader>h1', ':lua require("harpoon.ui").nav_file(1)<CR>', desc = 'Navigate to Harpoon File 1', remap = true },
    { '<leader>h2', ':lua require("harpoon.ui").nav_file(2)<CR>', desc = 'Navigate to Harpoon File 2', remap = true },
    { '<leader>h3', ':lua require("harpoon.ui").nav_file(3)<CR>', desc = 'Navigate to Harpoon File 3', remap = true },
    { '<leader>h4', ':lua require("harpoon.ui").nav_file(4)<CR>', desc = 'Navigate to Harpoon File 4', remap = true },
    { '<leader>h5', ':lua require("harpoon.ui").nav_file(5)<CR>', desc = 'Navigate to Harpoon File 5', remap = true },
    { '<leader>h6', ':lua require("harpoon.ui").nav_file(6)<CR>', desc = 'Navigate to Harpoon File 6', remap = true },
    { '<leader>h7', ':lua require("harpoon.ui").nav_file(7)<CR>', desc = 'Navigate to Harpoon File 7', remap = true },
    { '<leader>h8', ':lua require("harpoon.ui").nav_file(8)<CR>', desc = 'Navigate to Harpoon File 8', remap = true },
    { '<leader>h9', ':lua require("harpoon.ui").nav_file(9)<CR>', desc = 'Navigate to Harpoon File 9', remap = true },
    { '<leader>h0', ':lua require("harpoon.ui").nav_file(10)<CR>', desc = 'Navigate to Harpoon File 10', remap = true },
  },
  config = function()
    require("telescope").load_extension('harpoon')
    require("harpoon").setup({
      menu = {
        -- On vertical screen we needed a +20 adjustment, not a -20... weird
        width = vim.api.nvim_win_get_width(0) + 20,
      }
    })
  end,
}
