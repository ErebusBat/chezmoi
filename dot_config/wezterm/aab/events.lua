local wezterm = require 'wezterm'
local hostname = wezterm.hostname()
local background_hsb = {
  brightness = 0.0125,
}

-- helper function
local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function calc_set_font_size(window)
  local overrides = window:get_config_overrides() or {}
  local monitor_count = tablelength(wezterm.gui.screens()["by_name"])
  overrides.font_size = 10
  wezterm.log_info(hostname .. " monitor_count: " .. monitor_count)

  if (hostname == 'm4mbp.local') then
    -- This can fail on linux, and we don't need it there so only call here
    -- Depends if we are docked or not
    if (monitor_count == 2)
    then
      background_hsb["brightness"] = 0.02 -- Note: This likely does nothing in current config, but keep logic or define local table.
      overrides.font_size = 10
    else
      overrides.font_size = 14
    end
  elseif (hostname == 'USMB-JVK937H909')  then
      overrides.font_size = 14
  elseif (hostname == 'thelio')  then
    overrides.font_size = 8
  elseif (hostname == 'dartp6')  then
    overrides.font_size = 10
  end
  wezterm.log_info("Setting font_size to " .. overrides.font_size .. " for " .. hostname .. " monitors=" .. monitor_count)

  window:set_config_overrides(overrides)
end

wezterm.on('window-config-reloaded', function(window)
  calc_set_font_size(window)
end)

wezterm.on('window-resized', function(window, _pane)
  calc_set_font_size(window)
end)

wezterm.on('toggle-window-decorations', function(window, _pane)
  local overrides = window:get_config_overrides() or {}
  local current = window:effective_config().window_decorations
  if current:find('TITLE') then
    overrides.window_decorations = 'RESIZE'
  else
    overrides.window_decorations = 'TITLE | RESIZE'
  end
  window:set_config_overrides(overrides)
end)

return {}
