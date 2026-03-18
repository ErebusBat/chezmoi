-- WezTerm Configuration
-- https://wezfurlong.org/wezterm/config/lua/wezterm/index.html

local wezterm = require 'wezterm'

-- Determine hostname and os
local hostname = wezterm.hostname():lower()
local os_name = 'unknown'
if wezterm.target_triple:find("windows") then
  os_name = 'windows'
elseif wezterm.target_triple:find("linux") then
  os_name = 'linux'
elseif wezterm.target_triple:find("darwin") then
  os_name = 'darwin'
end

-- Function to load modules based on priority (First Match Wins)
-- The loader checks these paths in order. The FIRST one found is used; others are ignored.
-- See docs/MODULE_SYSTEM.md for details.
-- 1. aab.<name>.local       (Local overrides, ignored by git)
-- 2. aab.<name>-<hostname> (Machine-specific settings)
-- 3. aab.<name>-<os>       (OS-specific settings)
-- 4. aab.<name>            (Default / Base settings)
local function load_module(name)
  local modules_to_try = {
    'aab.' .. name .. '.local',
    'aab.' .. name .. '-' .. hostname,
    'aab.' .. name .. '-' .. os_name,
    'aab.' .. name,
  }

  for _, mod in ipairs(modules_to_try) do
    local success, result = pcall(require, mod)
    if success then
      wezterm.log_info('Loaded module: ' .. mod)
      return result
    end
  end

  wezterm.log_info('No module found for: ' .. name)
  return {}
end

-- Initialize config
local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Base configuration
config.default_prog = { "/bin/zsh" }
config.set_environment_variables = {
  shell = "/bin/zsh",
}

-- Load and merge modules
local function merge_config(source)
  if type(source) == 'table' then
    for k, v in pairs(source) do
      config[k] = v
    end
  end
end

-- Configuration Modules
-- These modules return a table of settings (e.g., font, keys) that are merged into the main config.
-- To add a new module:
-- 1. Create aab/<name>.lua
-- 2. Add '<name>' to this list.
local modules = {'appearance', 'keys', 'wallpaper'}
for _, name in ipairs(modules) do
  merge_config(load_module(name))
end

-- Event Modules
-- These modules don't return configuration settings to merge.
-- Instead, they register event listeners (wezterm.on) for side effects like dynamic resizing.
load_module('events')

return config
