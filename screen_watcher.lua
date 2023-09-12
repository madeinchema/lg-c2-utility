local config = require("config")
local utils = require("utils")

local screenWatcher = hs.screen.watcher.new(function()
  local screens = hs.screen.allScreens()
  local hdmiConnected = false

  for _, screen in ipairs(screens) do
    if utils.tv_is_connected() then
      hdmiConnected = true
      break
    end
  end

  if hdmiConnected then
    print("LG TV display connected")
    utils.handleInputSettings()
  else
    print("LG TV display disconnected")
  end
end)


return screenWatcher