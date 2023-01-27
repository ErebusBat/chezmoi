set termguicolors

" [tinted-theming/base16-shell](https://github.com/tinted-theming/base16-shell)
lua <<EOF
local fn = vim.fn
local cmd = vim.cmd
local set_theme_path = "$HOME/.config/tinted-theming/set_theme.lua"
local is_set_theme_file_readable = fn.filereadable(fn.expand(set_theme_path)) == 1 and true or false

if is_set_theme_file_readable then
  cmd("let base16colorspace=256")
  cmd("source " .. set_theme_path)
end
EOF

highlight Comment cterm=italic gui=italic

" set colorcolumn=80,120
set cursorline

"" Allow transparent bg
highlight Normal ctermbg=NONE guibg=NONE
" highlight CursorLine ctermbg=NONE guibg=NONE
highlight LineNr ctermbg=NONE guibg=NONE
"" highlight StatusLine ctermbg=NONE guibg=NONE

