return function(use)
  use({ "christoomey/vim-tmux-navigator" })
  use({ "qpkorr/vim-bufkill" })
  use({ "tpope/vim-surround" })

  use({ "wting/gitsessions.vim" })

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
      -- vim.cmd('colorscheme base16-ayu-dark')
      -- vim.cmd('colorscheme base16-ayu-light')

      -- local fn = vim.fn
      local cmd = vim.cmd
      local set_theme_path = "$HOME/.config/tinted-theming/set_theme.lua"
      local is_set_theme_file_readable = vim.fn.filereadable(vim.fn.expand(set_theme_path)) == 1 and true or false

      if is_set_theme_file_readable then
        vim.cmd("let base16colorspace=256")
        vim.cmd("source " .. set_theme_path)
      else
        vim.cmd('colorscheme base16-ayu-dark')
      end
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
    requires = { 'nvim-cmp' },
    config = function()
      -- https://github.com/windwp/nvim-autopairs
      require("nvim-autopairs").setup({})

      -- If you want insert `(` after select function or method item
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      -- cmp.event:on(
        -- 'confirm_done',
        -- cmp_autopairs.on_confirm_done()
      -- )

      local handlers = require('nvim-autopairs.completion.handlers')

      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done({
          filetypes = {
            -- "*" is a alias to all filetypes
            ["*"] = {
              ["("] = {
                kind = {
                  cmp.lsp.CompletionItemKind.Function,
                  cmp.lsp.CompletionItemKind.Method,
                },
                handler = handlers["*"]
              }
            },
            lua = {
              ["("] = {
                kind = {
                  cmp.lsp.CompletionItemKind.Function,
                  cmp.lsp.CompletionItemKind.Method
                },
                ---@param char string
                ---@param item table item completion
                ---@param bufnr number buffer number
                ---@param rules table
                ---@param commit_character table<string>
                handler = function(char, item, bufnr, rules, commit_character)
                  -- Your handler function. Inpect with print(vim.inspect{char, item, bufnr, rules, commit_character})
                end
              }
            },
            -- Disable for tex
            tex = false
          }
        })
      )
    end
  })
  use({
    'numToStr/Comment.nvim',
    require('Comment').setup({
      toggler = {
        line = [[\\]],
        block = 'gbc',
      },
      opleader = {
        line = [[\\]],
        block = 'gb',
      },
      extra = {
        above = 'gcO',  ---Add comment on the line above
        below = 'gco',  ---Add comment on the line below
        eol = 'gcA',    ---Add comment at the end of line
      },
    }),
  })
  use({ 'vim-test/vim-test' })
  use({ 'jgdavey/tslime.vim' })
end

