return {
  "micarmst/vim-spellsync",
  init = function ()
    vim.g.spellsync_enable_git_union_merge = 0
    vim.g.spellsync_enable_git_ignore = 0
    vim.cmd([[
      set spellfile+=~/.config/nvim/spell/en.utf-8.add
      set spellfile+=~/.config/nvim/spell/tractionguest.utf-8.add
      set spellfile+=~/.config/nvim/spell/personal.utf-8.add
    ]])
  end,
}
