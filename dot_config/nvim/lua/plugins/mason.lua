-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = desc })
    end
    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    -- https://github.com/nvim-telescope/telescope.nvim#pickers
    -- See also telescope.lua for other commands
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ps', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[P]roject [S]ymbols')

    -- Telescope - Live Grep BUFFER for Word under Cursor
    nmap('&', function()
      require('telescope.builtin').current_buffer_fuzzy_find({ default_text = vim.fn.expand('<cword>') })
    end, 'Search Current Buffer for Symbol Under Cursor')

    -- Telescope - Live Grep Project for Word under Cursor
    nmap('*', function()
      require('telescope.builtin').live_grep({ default_text = vim.fn.expand('<cword>') })
    end, 'Search Current Buffer for Symbol Under Cursor')

    vim.api.nvim_buf_create_user_command(ev.buf, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })

    -- Toggle Diagnostics
    -- local lspconfig = require('lspconfig')
    local function toggle_diagnostics()
      local current_state = vim.diagnostic.config().virtual_text
      vim.diagnostic.config({virtual_text = not current_state })
    end

    -- nmap('<leader>td', '<cmd>lua toggle_diagnostics()<CR>', '[T]oggle [D]iagnostics')
    nmap('<leader>td', toggle_diagnostics, '[T]oggle [D]iagnostics')
  end,
})

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
-- local on_attach = function(_, bufnr)
--   -- NOTE: Remember that lua is a real programming language, and as such it is possible
--   -- to define small helper and utility functions so you don't have to repeat yourself
--   -- many times.
--   --
--   -- In this case, we create a function that lets us more easily define mappings specific
--   -- for LSP related items. It sets the mode, buffer and description for us each time.
--   local nmap = function(keys, func, desc)
--     if desc then
--       desc = 'LSP: ' .. desc
--     end
--
--     vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
--   end
--
--   nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
--   nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
--
--   nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
--   nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
--   nmap('gR', vim.lsp.buf.references, '[G]oto Buffer [R]eferences')
--   nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
--   nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
--   nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
--   nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
--
--   -- See `:help K` for why this keymap
--   nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
--   -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
--
--   -- Lesser used LSP functionality
--   nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
--   nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
--   nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
--   nmap('<leader>wl', function()
--     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
--   end, '[W]orkspace [L]ist Folders')
--
--   -- Create a command `:Format` local to the LSP buffer
--   vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
--     vim.lsp.buf.format()
--   end, { desc = 'Format current buffer with LSP' })
-- end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},

  -- Fix for sumneko_lua: https://github.com/nvim-lua/kickstart.nvim/issues/179#issuecomment-1433664471
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = {
        globals = {'vim'},
      }
    },
  },

  -- solargraph = {
  --   useBundler = true,
  --   bundlerPath = "/Users/aburns/.rbenv/shims/bundler",
  --   solargraph = "/Users/aburns/.rbenv/shims/solargraph",
  --   commandPath = "/Users/aburns/.rbenv/versions/3.4.3/bin/solargraph",
  --   diagnostics = true,
  -- },
}

return {
  'mason-org/mason.nvim',
  -- enabled = false,

  dependencies = {
    'mason-org/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
  },
  init = function()
    -- vim.keymap.del('n', '<leader>ds')
  end,
  config = function()
    require('mason').setup()

    -- Ensure the servers above are installed
    local mason_lspconfig = require 'mason-lspconfig'

    mason_lspconfig.setup {
      ensure_installed = vim.tbl_keys(servers),
    }

    -- mason_lspconfig.setup_handlers {
    --   function(server_name)
    --     require('lspconfig')[server_name].setup {
    --       settings = servers[server_name],
    --     }
    --   end,
    -- }
  end,
  -- keys = {
  -- },
}
