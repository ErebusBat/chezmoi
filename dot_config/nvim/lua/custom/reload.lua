-- Inspired by https://stackoverflow.com/a/72504767

function _G.ReloadConfig()
  -- Clear lua Cache
  for name,_ in pairs(package.loaded) do
    if name:match('^custom') and not name:match('nvim-tree') then
      package.loaded[name] = nil
    end
  end

  -- Now source init.lua
  dofile(vim.env.MYVIMRC)

  -- Make sure packer is up to date
  require('packer').sync()

  vim.notify("Reloading config...", vim.log.levels.INFO)
  -- vim.defer_fn(function ()
    -- Clear notification area
    -- vim.notify("", vim.log.levels.INFO)
  -- end, 10000)
end
