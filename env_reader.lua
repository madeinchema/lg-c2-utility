local function readEnvFile(filename)
  local env = {}
  for line in io.lines(filename) do
      local key, value = line:match("^([%w_]+)=(.+)$")
      if key and value then
          env[key] = value
      end
  end
  return env
end

return readEnvFile

-- -- Read the .env file
-- local env = readEnvFile(".env")

-- -- Access the value of the variable "MY_VARIABLE" from the .env file
-- local tv_ip = env["TV_IP"]

-- return {
--   tv_ip
-- }