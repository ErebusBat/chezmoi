-- In Lua, `[[...]]` is a **raw string literal** (long string). Inside a regular quoted string like `"\\"`, the backslash is an escape character, so you'd need `"\\\\"` to get a literal `\\`.
--
-- With `[[\\]]`, no escaping is applied — what you see is what you get. It's just a cleaner way to write the two-character string `\\` without escape gymnastics.

-- Native NeoVim commenting (0.10+) with \\ keybinding
-- Replaces numToStr/Comment.nvim which broke on NeoVim 0.12
vim.keymap.set('n', [[\\]], 'gcc', { remap = true, desc = 'Toggle comment (line)' })
vim.keymap.set('v', [[\\]], 'gc', { remap = true, desc = 'Toggle comment (selection)' })

return {}
