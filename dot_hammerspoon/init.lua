-- Keep the pointer with the focused window without disrupting mouse-driven focus.
local function mouseIsInsideWindow(window)
  local mouse = hs.mouse.absolutePosition()
  local frame = window:frame()

  return mouse.x >= frame.x
    and mouse.x < frame.x + frame.w
    and mouse.y >= frame.y
    and mouse.y < frame.y + frame.h
end

local function moveMouseToFocusedWindow(window)
  if not mouseIsInsideWindow(window) then
    hs.mouse.absolutePosition(window:frame().center)
  end
end

windowFocusWatcher = hs.window.filter.new()
windowFocusWatcher:subscribe(
  hs.window.filter.windowFocused,
  moveMouseToFocusedWindow
)

hs.autoLaunch(true)
