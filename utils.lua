local config = require("config")

local debug,
TV_IP,
mode,
bscpylgtv,
disable_lgtv,
connected_tv_identifiers,
lgtv_cmd,
lgtv_ssl,
tv_hdmi_ports =
    config.debug,
    config.TV_IP,
    config.mode,
    config.bscpylgtv,
    config.disable_lgtv,
    config.connected_tv_identifiers,
    config.lgtv_cmd,
    config.lgtv_ssl,
    config.tv_hdmi_ports


local M = {}


local function exec_command(command)
  if lgtv_ssl then
    command = command .. " ssl"
  end

  command = lgtv_cmd .. " " .. command

  if debug then
    print("Executing command: " .. command)
  end

  return hs.execute(command)
end


local function lgtv_current_app_id()
  local foreground_app_info = exec_command("getForegroundAppInfo")
  for w in foreground_app_info:gmatch('%b{}') do
    if w:match('\"response\"') then
      local match = w:match('\"appId\"%s*:%s*\"([^\"]+)\"')
      if match then
        return match
      end
    end
  end
end
local app_id = lgtv_current_app_id()


-- Get a list of audio devices connected by HDMI
local function getHDMIAudioDevices()
  local devices = hs.audiodevice.allDevices()
  local hdmiDevices = {}

  for _, device in ipairs(devices) do
    if device:transportType() == "HDMI" then
      table.insert(hdmiDevices, device:name())
    end
  end

  return hdmiDevices
end


local function change_input_settings()
  for _, hdmi_port in ipairs(tv_hdmi_ports) do
    local command = bscpylgtv .. " " .. TV_IP .. " set_device_info " .. hdmi_port .. " " .. mode .. " PC"
    print("COMMAND " .. command)
    hs.execute(command)
  end
end

local function tv_is_connected()
  for i, v in ipairs(connected_tv_identifiers) do
    if hs.screen.find(v) ~= nil then
      return true
    end
  end

  return false
end


local function isTvReachable()
  local success, err = pcall(hs.execute("lgtv scan ssl"))

  if err then
    print("Error executing command: " .. err)
    return false
  end

  if success then
    local commandOutput = success
    local decodedOutput = hs.json.decode(commandOutput)
    print("decodedOutput " .. decodedOutput)

    if decodedOutput and decodedOutput.list then
      for _, tv in ipairs(decodedOutput.list) do
        if tv.address == TV_IP then
          print("TV is reachable")
          return true
        else
          print("TV is not reachable")
          return false
        end
      end
    end
  end
end


local function dump_table(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. dump_table(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

local function execute(command)
  command = lgtv_cmd .. " " .. command

  if debug then
    print("Executing command: " .. command)
  end

  return hs.execute(command)
end


-- Source: https://stackoverflow.com/a/4991602
local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local function lgtv_disabled()
  return disable_lgtv or file_exists("./disable_lgtv") or file_exists(os.getenv('HOME') .. "/.disable_lgtv")
end


local function handleInputSettings()
  if tv_is_connected() then
    change_input_settings()
  end
end


-- Execute and handle errors
local function executeInputSettingsHandler(eventType, retryCount)
  retryCount = retryCount or 0
  local MAX_RETRIES = 3

  local success, err = pcall(handleInputSettings, eventType)
  if success then
    retryCount = 0
  else
    if retryCount < MAX_RETRIES then
      print("Error encountered " .. err)
      print("Retrying in 3 seconds...")
      hs.timer.doAfter(3, function() executeInputSettingsHandler(eventType, retryCount + 1) end)
    else
      print("Error encountered after maximum retires: " .. err)
      hs.notify.new({
        title = "Hammerspoon Error - LG TV",
        informativeText = "Error encountered after maximum retries."
      }):send()
    end
  end
end


M.app_id = app_id
M.exec_command = exec_command
M.lgtv_current_app_id = lgtv_current_app_id
M.getHDMIAudioDevices = getHDMIAudioDevices
M.change_input_settings = change_input_settings
M.tv_is_connected = tv_is_connected
M.isTvReachable = isTvReachable
M.dump_table = dump_table
M.execute = execute
M.file_exists = file_exists
M.lgtv_disabled = lgtv_disabled
M.handleInputSettings = handleInputSettings
M.executeInputSettingsHandler = executeInputSettingsHandler

return M
