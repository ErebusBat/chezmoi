return function(use)
  use({ "christoomey/vim-tmux-navigator" })
  use({ "qpkorr/vim-bufkill" })
  use({ "tpope/vim-surround" })

  use({
    "micarmst/vim-spellsync",
    config = function()
      -- vim.opt.spellfile = vim.fn.expand('$HOME/.config/nivm/spell.en.utf-8.add') .. '@' .. '~/.config/nvim/spell/tractionguest.utf-8.add' 
      -- vim.opt.spellfile = vim.fn.expand('$HOME/.config/nivm/spell.en.utf-8.add')
      vim.cmd([[
        set spellfile+=~/.config/nvim/spell/en.utf-8.add
        set spellfile+=~/.config/nvim/spell/tractionguest.utf-8.add
        set spellfile+=~/.config/nvim/spell/personal.utf-8.add
      ]])
    end,
  })

  -- Appearance
  -- use({ 
    -- "base16-project/base16-vim",
    -- config = function()
      -- local fn = vim.fn
      -- local cmd = vim.cmd
      -- local set_theme_path = "$HOME/.config/tinted-theming/set_theme.lua"
      -- local is_set_theme_file_readable = fn.filereadable(fn.expand(set_theme_path)) == 1 and true or false
--
      -- if is_set_theme_file_readable then
        -- cmd("let base16colorspace=256")
        -- cmd("source " .. set_theme_path)
      -- end
    -- end,
  -- })
  use({
    "RRethy/nvim-base16",
    config = function()
      vim.cmd('colorscheme base16-ayu-dark')
      -- vim.cmd('colorscheme base16-ayu-light')
    end
  })
  use({
    'nvim-lualine/lualine.nvim', -- Fancier statusline
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'base16',
          component_separators = '|',
          section_separators = '',
        },
      }
    end
  })

  use({
    'f3fora/cmp-spell'
  })

  use({
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup({}) end
  })
end

