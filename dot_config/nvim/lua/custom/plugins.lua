return function(use)
  use({ "christoomey/vim-tmux-navigator" })
  use({ "qpkorr/vim-bufkill" })
  use({ "tpope/vim-surround" })

  use({
    "micarmst/vim-spellsync",
    config = function()
      -- vim.opt.spellfile = vim.fn.expand('$HOME/.config/nivm/spell.en.utf-8.add') .. '@' .. '~/.config/nvim/spell/tractionguest.utf-8.add' 
      vim.opt.spellfile = vim.fn.expand('$HOME/.config/nivm/spell.en.utf-8.add')
    end,
  })

  -- Appearance
  use({ 
    "base16-project/base16-vim",
    config = function()
    end,
  })
end
