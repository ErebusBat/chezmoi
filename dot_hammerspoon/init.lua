-- Keep the pointer with the active app when switching focus across displays.
local function centerMouseOnFocusedWindow()
  local window = hs.window.focusedWindow()

  if window then
    hs.mouse.absolutePosition(window:frame().center)
  end
end

appFocusWatcher = hs.application.watcher.new(function(_, event)
  if event == hs.application.watcher.activated then
    -- Let macOS finish assigning the app's focused window before moving the pointer.
    hs.timer.doAfter(0.05, centerMouseOnFocusedWindow)
  end
end)

appFocusWatcher:start()
hs.autoLaunch(true)
