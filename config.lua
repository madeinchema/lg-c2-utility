local config = {}

-- Switch input to Mac when waking the TV
config.switch_input_on_wake = true
-- Prevent sleep when TV is set to other input (ie: you're watching Netflix and your Mac goes to sleep)
config.prevent_sleep_when_using_other_input = true
-- If you run into issues, set to true to enable debug messages
config.debug = true
-- IP address for TV
config.TV_IP = "${TV_IP}"
-- Mode for HDMI input
config.mode = "pc"
-- Full path to "bscpylgtvcommand" executable
config.bscpylgtv = "/opt/homebrew/bin/bscpylgtvcommand"
-- NOTE: You can disable this script by setting the above variable to true, or by creating a file named `disable_lgtv` in the same directory as this file, or at ~/.disable_lgtv.
config.disable_lgtv = false
-- Name of your TV, set when you run `lgtv auth`
config.tv_name = "MyTV"
-- Used to identify the TV when it's connected to this computer
config.connected_tv_identifiers = { "LG TV", "LG TV SSCR2" }
-- use "screenOff" to keep the TV on, but turn off the screen.
config.screen_off_command = "off"
-- Full path to lgtv executable
config.lgtv_path = "~/opt/lgtv/bin/lgtv"
-- local app_id = "com.webos.app."..tv_input:lower():gsub("_", "")
config.lgtv_cmd = config.lgtv_path .. " " .. config.tv_name
-- Required for firmware 03.30.16 and up. Also requires LGWebOSRemote version 2023-01-27 or newer.
config.lgtv_ssl = true
config.tv_hdmi_ports = { "HDMI_1", "HDMI_2", "HDMI_3", "HDMI_4" }

return config
