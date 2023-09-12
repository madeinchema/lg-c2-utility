local config = require("config")
local utils = require("utils")
local systemWatcher = require("system_watcher")
local screenWatcher = require("screen_watcher")

-- Init
utils.handleInputSettings()
systemWatcher:start()
screenWatcher:start()
