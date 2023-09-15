function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local wallpapers = require('wallpapers')
local wallpaper_to_use = wallpapers[math.random(#wallpapers)]

return {
  File = wallpaper_to_use,
  Enabled = false,
}
