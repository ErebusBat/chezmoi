return {
  'rmagatti/auto-session',
  lazy = false,
  config = function()
    require("auto-session").setup {
      log_level = "error",
      auto_save_enabled = false,
      auto_restore_enabled = true,
      auto_session_allowed_dirs = {
        "~/src/*",
        "~/.config/*",
        "~/.local/*",
      },
      -- auto_session_suppress_dirs = {
      --   -- "~/",
      --   "~/Projects",
      --   "~/Downloads",
      --   "/",
      -- },
    }
  end,
  keys = {
    -- https://github.com/rmagatti/auto-session
    { '<leader>ss', ':SaveSession<CR>', { desc = '[S]ave [S]ession', noremap = true } },
    { '<leader>ls', ':RestoreSession<CR>', { desc = '[L]oad [S]ession', noremap = true } },
  },
  save_extra_cmds = {
    -- tabby: tabs name
    function()
      local cmds = {}
      for _, t in pairs(vim.api.nvim_list_tabpages()) do
        local tabname = require("tabby.feature.tab_name").get_raw(t)
        if tabname ~= "" then
          table.insert(cmds, 'require("tabby.feature.tab_name").set(' .. t .. ', "' .. tabname:gsub('"', '\\"') .. '")')
        end
      end

      if #cmds == 0 then
        return ""
      end

      return "lua " .. table.concat(cmds, ";")
    end,
  },
}
