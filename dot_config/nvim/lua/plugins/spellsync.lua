return {
  "micarmst/vim-spellsync",
  init = function ()
    -- vim: ts=2 sts=2 sw=2 et
    -- vim.opt.spellfile = vim.fn.expand('$HOME/.config/nivm/spell.en.utf-8.add') .. '@' .. '~/.config/nvim/spell/tractionguest.utf-8.add'
    -- vim.opt.spellfile = vim.fn.expand('$HOME/.config/nivm/spell.en.utf-8.add')
    vim.cmd([[
      set spellfile+=~/.config/nvim/spell/en.utf-8.add
      set spellfile+=~/.config/nvim/spell/tractionguest.utf-8.add
      set spellfile+=~/.config/nvim/spell/personal.utf-8.add
    ]])
  end,
}
