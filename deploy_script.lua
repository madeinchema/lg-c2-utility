local readEnvFile = require("env_reader")

-- Load the .env file
local env = readEnvFile("./.env")

-- Define the list of files to process
local filesToProcess = {
  "lgtv_init.lua",
  "config.lua",
  "screen_watcher.lua",
  "system_watcher.lua",
  "utils.lua"
  -- Add other filenames as needed
}

-- Base output directory
local baseOutputDir = "../../.hammerspoon/"

for _, filename in ipairs(filesToProcess) do
  -- Load the current script
  local scriptContent = io.open("./" .. filename, "r"):read("*all")

  -- Replace placeholders with actual env values
  for key, value in pairs(env) do
    scriptContent = scriptContent:gsub("${" .. key .. "}", value)
  end

  -- Define your output path for the current file
  local outputPath = baseOutputDir .. filename

  -- Write the modified script to the desired location
  local outputFile = io.open(outputPath, "w")
  outputFile:write(scriptContent)
  outputFile:close()

  print("Script " .. filename .. " deployed to: " .. outputPath)
end
