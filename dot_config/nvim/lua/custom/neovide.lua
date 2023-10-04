
function SetupGUIFont()
  vim.o.guifont = "Comic Code Ligatures,ComicCode Nerd Font,OpenDyslexic Nerd Font,ComicShannsMono Nerd Font Mono:h14"
  -- vim.o.guifont = "Fira Code,ComicCode Nerd Font,OpenDyslexic Nerd Font,ComicShannsMono Nerd Font Mono:h14"

  vim.g.neovide_hide_mouse_when_typing = true

  vim.g.neovide_scale_factor = 1.0
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set("n", "<C-0>", function()
    vim.g.neovide_scale_factor = 1.0
  end)
  vim.keymap.set("n", "<C-=>", function()
    change_scale_factor(1.25)
  end)
  vim.keymap.set("n", "<C-->", function()
    change_scale_factor(1/1.25)
  end)
end

function MakeTransparent()
  -- Helper function for transparency formatting
  local alpha = function()
    return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
  end
  -- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
  vim.g.neovide_transparency = 0.0
  vim.g.transparency = 0.9
  vim.g.neovide_background_color = "#0f1117" .. alpha()
end

function SetupNeovideGUI()
  vim.g.neovide_theme = 'auto'

  -- catppuccin catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
  -- vim.cmd.colorscheme 'catppuccin-latte'

  -- Cursor Behavior
  vim.g.neovide_cursor_animation_length = 0.13
  vim.g.neovide_cursor_trail_size = 0.3
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line = true
  vim.g.neovide_cursor_vfx_mode = "railgun"
end

function PasteboardIntegration()
  vim.keymap.set('i', '<D-s>', '<Esc>:wa<CR>') -- Save all - insert mode
  vim.keymap.set('n', '<D-s>', ':wa<CR>') -- Save all - normal mode
  vim.keymap.set('v', '<D-c>', '"+y') -- Copy
  -- vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
  vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
  vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
  vim.keymap.set('i', '<D-v>', '<Esc>:set paste<CR>"+p:set nopaste<CR>') -- Paste insert mode
end

PasteboardIntegration()
SetupGUIFont()
SetupNeovideGUI()
-- MakeTransparent()
