local config = require("config")
local utils = require("utils")

local debug,
switch_input_on_wake,
screen_off_command =
    config.debug,
    config.switch_input_on_wake,
    config.screen_off_command

local tv_is_connected,
lgtv_disabled,
exec_command,
isTvReachable,
lgtv_current_app_id,
getHDMIAudioDevices,
handleInputSettings =
    utils.tv_is_connected,
    utils.lgtv_disabled,
    utils.exec_command,
    utils.isTvReachable,
    utils.lgtv_current_app_id,
    utils.getHDMIAudioDevices,
    utils.handleInputSettings

local systemWatcher = hs.caffeinate.watcher.new(function(eventType)
  local app_id = utils.lgtv_current_app_id()
  print("Received screenWatcher event. !!!!!!!!!!4")

  if debug then print("Received event: " .. (eventType or "")) end

  if not isTvReachable() then
    if debug then
      print("TV IP is not reachable. Skipping system watcher logic.")
    end
    return
  end

  if lgtv_disabled() then
    if debug then print("LGTV feature disabled. Skipping.") end
    return
  end

  if (eventType == hs.caffeinate.watcher.systemDidWake or
        eventType == hs.caffeinate.watcher.screensDidUnlock or
        eventType == hs.caffeinate.watcher.screensDidWake) and not lgtv_disabled() then
    local HDMI = getHDMIAudioDevices()
    local screen = HDMI[1]

    -- if string.sub(screen,1,2) == "LG" then -- check if LG TV is connected
    if tv_is_connected() then
      exec_command("on")       -- wake on lan
      exec_command("screenOn") -- turn on screen
      if debug then print("TV was turned on") end

      if lgtv_current_app_id() ~= app_id and switch_input_on_wake then
        execute("startApp ssl " .. app_id:lower():gsub("_", ""))
        if debug then print("TV input switched to " .. app_id) end
      end

      handleInputSettings()
    end
  end


  if (tv_is_connected() and (eventType == hs.caffeinate.watcher.screensDidSleep or
        eventType == hs.caffeinate.watcher.systemWillPowerOff) and not lgtv_disabled()) then
    if lgtv_current_app_id() ~= app_id and prevent_sleep_when_using_other_input then
      if debug then print("TV is currently on another input (" .. lgtv_current_app_id() .. "). Skipping powering off.") end
      return
    end

    -- This puts the TV in standby mode.
    -- For true "power off" use `off` instead of `screenOff`.
    exec_command(screen_off_command)
    if debug then print("TV screen was turned off with command `" .. screen_off_command .. "`.") end
  end
end)


return systemWatcher
