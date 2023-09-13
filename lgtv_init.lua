local config = require("config")
local utils = require("utils")
local systemWatcher = require("system_watcher")
local screenWatcher = require("screen_watcher")

-- Init
utils.handleInputSettings()
systemWatcher:start()
screenWatcher:start()

-- Debug mode
local debug,
TV_IP,
tv_name,
lgtv_path,
lgtv_cmd,
lgtv_ssl =
    config.debug,
    config.TV_IP,
    config.tv_name,
    config.lgtv_path,
    config.lgtv_cmd,
    config.lgtv_ssl

local exec_command,
lgtv_disabled,
dump_table,
tv_is_connected,
app_id =
    utils.exec_command,
    utils.lgtv_disabled,
    utils.dump_table,
    utils.tv_is_connected,
    utils.app_id

if debug then
  print("TV name: " .. tv_name)
  print("TV IP: " .. TV_IP)
  print("LGTV path: " .. lgtv_path)
  print("LGTV command: " .. lgtv_cmd)
  print("SSL: " .. tostring(lgtv_ssl))
  print("App ID: " .. app_id)
  print("lgtv_disabled: " .. tostring(lgtv_disabled()))
  if not lgtv_disabled() then
    print(exec_command("swInfo"))
    print(exec_command("getForegroundAppInfo"))
    print("Connected screens: " .. dump_table(hs.screen.allScreens()))
    print("TV is connected? " .. tostring(tv_is_connected()))
  end
end
