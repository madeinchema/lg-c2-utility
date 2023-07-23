local tv_ip = require("env_reader")

-- local tv_input = "HDMI_1" -- Input to which your Mac is connected
local switch_input_on_wake = true -- Switch input to Mac when waking the TV
local prevent_sleep_when_using_other_input = true -- Prevent sleep when TV is set to other input (ie: you're watching Netflix and your Mac goes to sleep)
local debug = true  -- If you run into issues, set to true to enable debug messages
local IP = tv_ip -- IP address for TV
local mode = "pc" -- Mode for HDMI input
local name = '"MacBook Pro"' -- Name for HDMI input
local bscpylgtv = "/opt/homebrew/bin/bscpylgtvcommand" -- -- Full path to "bscpylgtvcommand" executable
local disable_lgtv = false
-- NOTE: You can disable this script by setting the above variable to true, or by creating a file named
-- `disable_lgtv` in the same directory as this file, or at ~/.disable_lgtv.

-- You likely will not need to change anything below this line
local tv_name = "MyTV" -- Name of your TV, set when you run `lgtv auth`
local connected_tv_identifiers = {"LG TV", "LG TV SSCR2"} -- Used to identify the TV when it's connected to this computer
local screen_off_command = "off" -- use "screenOff" to keep the TV on, but turn off the screen.
local lgtv_path = "~/opt/lgtv/bin/lgtv" -- Full path to lgtv executable
local lgtv_cmd = lgtv_path.." "..tv_name
-- local app_id = "com.webos.app."..tv_input:lower():gsub("_", "")
local lgtv_ssl = true -- Required for firmware 03.30.16 and up. Also requires LGWebOSRemote version 2023-01-27 or newer.


function exec_command(command)
  if lgtv_ssl then
    command = command.." ssl"
  end

  command = lgtv_cmd.." "..command

  if debug then
    print("Executing command: "..command)
  end

  return hs.execute(command)
end

function lgtv_current_app_id()
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

-- Get the current active HDMI port
function extractAppNameHdmi(inputString)
  -- Find the last occurrence of a dot in the string
  local lastDotIndex = inputString:find("[^.]*$")

  -- Extract the substring after the last dot
  local appName = inputString:sub(lastDotIndex)

  print("EXECUTED extractAppName "..appName)
  return appName
end

function getCurrentHdmiPort()
  local current_app_id = lgtv_current_app_id()
  local current_hdmi_port = extractAppNameHdmi(current_app_id)
  print("EXECUTED getCurrentHdmiPort "..current_hdmi_port)
  return current_hdmi_port
end

-- Test the function with the provided input string
-- currentHdmiPort = getCurrentHdmiPort()
-- print("currentHdmiPort")
-- print(currentHdmiPort)
currentHdmiPort = nil

-- (TV) HDMI input the mac is connected to
function getTvInput(input)
  local hdmiNumber = input:sub(string.len(input), -1)
  print(hdmiNumber)
  local tvInput = input:upper():sub(1, -2).."_"..hdmiNumber
  print("EXECUTED getTvInput "..tvInput)
  return tvInput
end

tv_input = nil
-- tv_input = getTvInput(currentHdmiPort)

-- Get a list of audio devices connected by HDMI
function getHDMIAudioDevices()
  local devices = hs.audiodevice.allDevices()
  local hdmiDevices = {}

  for _, device in ipairs(devices) do
      if device:transportType() == "HDMI" then
          table.insert(hdmiDevices, device:name())
      end
  end

  return hdmiDevices
end

function change_input_settings()
  -- hs.execute(bscpylgtv.." "..IP.." set_device_info "..tv_input.." "..mode.." "..name)
  local command = bscpylgtv.." "..IP.." set_device_info "..tv_input.." "..mode.." PC"
  print("COMMAND "..command)
  hs.execute(command)
end

function tv_is_connected()
  for i, v in ipairs(connected_tv_identifiers) do
    if hs.screen.find(v) ~= nil then
      return true
    end
  end

  return false
end

function dump_table(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump_table(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function execute(command)
  command = lgtv_cmd.." "..command

  if debug then
    print("Executing command: "..command)
  end

  return hs.execute(command)
end



-- Source: https://stackoverflow.com/a/4991602
function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then
    io.close(f)
    return true
  else
    return false
  end
end

function lgtv_disabled()
  return disable_lgtv or file_exists("./disable_lgtv") or file_exists(os.getenv('HOME') .. "/.disable_lgtv")
end

if debug then
  print ("TV name: "..tv_name)
  if tv_input then
    print ("TV input: "..tv_input)
  end
  print ("LGTV path: "..lgtv_path)
  print ("LGTV command: "..lgtv_cmd)
  print ("SSL: "..tostring(lgtv_ssl))
  print ("App ID: "..app_id)
  print("lgtv_disabled: "..tostring(lgtv_disabled()))
  if not lgtv_disabled() then
    print (exec_command("swInfo"))
    print (exec_command("getForegroundAppInfo"))
    print("Connected screens: "..dump_table(hs.screen.allScreens()))
    print("TV is connected? "..tostring(tv_is_connected()))
  end
end

-- System Watcher (Sleep, wake up...)
systemWatcher = hs.caffeinate.watcher.new(function(eventType)
  print("REACHED 1")
  if debug then print("Received event: "..(eventType or "")) end

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
      exec_command("on") -- wake on lan
      exec_command("screenOn") -- turn on screen
      if debug then print("TV was turned on") end

      if lgtv_current_app_id() ~= app_id and switch_input_on_wake then
        execute("startApp ssl com.webos.app."..tv_input:lower():gsub("_", ""))
        if debug then print("TV input switched to "..app_id) end
      end

      print("REACHED 2")
      change_input_settings()
    end

  end


  if (tv_is_connected() and (eventType == hs.caffeinate.watcher.screensDidSleep or
      eventType == hs.caffeinate.watcher.systemWillPowerOff) and not lgtv_disabled()) then

    if lgtv_current_app_id() ~= app_id and prevent_sleep_when_using_other_input then
      if debug then print("TV is currently on another input ("..lgtv_current_app_id().."). Skipping powering off.") end
      return
    end

    -- This puts the TV in standby mode.
    -- For true "power off" use `off` instead of `screenOff`.
    exec_command(screen_off_command)
    if debug then print("TV screen was turned off with command `"..screen_off_command.."`.") end
  end
end)

-- Coroutine
co = coroutine.create(function ()
  currentHdmiPort = getCurrentHdmiPort()
  coroutine.yield()
  tv_input = getTvInput(currentHdmiPort)
  coroutine.yield()
  change_input_settings()
  coroutine.yield()
end)

-- Screen Watcher (HDMI input)
screenWatcher = hs.screen.watcher.new(function()
  print("AAAAAAAAAAAAAAAAAAAAAAAAA")
  local screens = hs.screen.allScreens()
  local hdmiConnected = false

  for _, screen in ipairs(screens) do
    -- print(screen:name())
    if tv_is_connected() then
      hdmiConnected = true
      break
    end
  end

  if hdmiConnected then
    print("LG TV display connected")
    -- currentHdmiPort = getCurrentHdmiPort()
    -- tv_input = getTvInput(currentHdmiPort)
    -- change_input_settings()
    coroutine.resume(co)
    coroutine.resume(co)
    coroutine.resume(co)
    print(currentHdmiPort, tv_input)
  else
    currentHdmiPort = nil
    tv_input = nil
    print("LG TV display disconnected")
    print(currentHdmiPort, tv_input)
  end
end)

systemWatcher:start()
screenWatcher:start()