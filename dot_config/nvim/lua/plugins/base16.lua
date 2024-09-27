return {
  "RRethy/nvim-base16",
  init = function ()
    vim.opt.termguicolors = true
  end,
  config = function()
    local cmd = vim.cmd
    local set_theme_path = "$HOME/.config/tinted-theming/set_theme.lua"
    local is_set_theme_file_readable = vim.fn.filereadable(vim.fn.expand(set_theme_path)) == 1 and true or false

    if is_set_theme_file_readable then
      cmd("let base16colorspace=256")
      cmd("source " .. set_theme_path)
    else
      cmd('colorscheme base16-onedark')
    end
  end,
}
