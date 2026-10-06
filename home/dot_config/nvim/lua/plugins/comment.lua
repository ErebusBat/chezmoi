-- Native NeoVim commenting (0.10+) with \\ keybinding
-- Replaces numToStr/Comment.nvim which broke on NeoVim 0.12
vim.keymap.set('n', [[\\]], 'gcc', { remap = true, desc = 'Toggle comment (line)' })
vim.keymap.set('v', [[\\]], 'gc', { remap = true, desc = 'Toggle comment (selection)' })

return {}
