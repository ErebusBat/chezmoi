return {
  'rmagatti/auto-session',
  lazy = true,
  enabled = false,
  config = function()
    -- vim.cmd([[ let g:auto_session_root_dir = "." ]])
    vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions"
    require("auto-session").setup {
      log_level = "error",
      auto_session_use_git_branch = true,
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
  cmd = {
    'Autosession',
    'SessionDelete',
    'SessionRestore',
    'SessionRestoreFromFile',
    'SessionSave',
  },
  keys = {
    -- https://github.com/rmagatti/auto-session
    { '<leader>ss', ':SessionSave<CR>', { desc = '[S]ave [S]ession', noremap = true } },
    { '<leader>ls', ':SessionRestore<CR>', { desc = '[L]oad [S]ession', noremap = true } },
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
