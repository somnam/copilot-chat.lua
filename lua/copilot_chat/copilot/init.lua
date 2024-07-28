local consts = require("copilot_chat.copilot.consts")
local curl = require("plenary.curl")
local file = require("copilot_chat.util.file")
local json = require("copilot_chat.util.json")

---@class Copilot
---@field config_paths table Github Copilot config possible paths
---@field config_path string Github Copilot config path
---@field hosts_file string Github Copilot config file with oauth token
---@field oauth_token string Github oauth token
---@field api_key_file string Github Copilot api key file
---@field api_key_headers table Github Copilot api key request headers
---@field api_key_url string Github Copilot api key request url
---@field api_key_endpoint string Github Copilot api key request endpoint
---@field api_key table? Github Copilot api key data
local Copilot = {}

function Copilot:new()
  local object = {
    config_paths = {
      "$XDG_CONFIG_HOME/github-copilot",
      "~/.config/github-copilot",
      "~/AppData/Local/github-copilot",
    },
    hosts_file = "hosts.json",
    api_key_file = "api-key.json",
    api_key_headers = {
      ["Editor-Version"] = consts.EDITOR_VERSION,
      ["Editor-Plugin-Version"] = consts.EDITOR_PLUGIN_VERSION,
      ["User-Agent"] = consts.USER_AGENT,
    },
    api_key_url = "https://api.github.com/copilot_internal/v2/",
    api_key_endpoint = "token",
    api_key = nil,
  }

  setmetatable(object, self)
  self.__index = self
  return object
end

function Copilot:init()
  if self.config_path == nil then
    self.config_path = self:get_config_path()
  end

  if self.oauth_token == nil then
    self.oauth_token = self:get_oauth_token()
  end
end

---@return string
function Copilot:get_config_path()
  for _, path in ipairs(self.config_paths) do
    local expanded = vim.fn.expand(path)
    if expanded and file.dir_exists(expanded) then
      return expanded
    end
  end
  error("Could not find Copilot config. Copilot plugin not authenticated?")
end

---@return string
function Copilot:get_oauth_token()
  local hosts_data = self:read_hosts_file()
  if hosts_data["github.com"] ~= nil and type(hosts_data["github.com"]) == "table" then
    local oauth_token = hosts_data["github.com"].oauth_token
    if oauth_token ~= nil then
      return oauth_token
    end
  end
  error("Could not retrieve Github oauth token. Copilot plugin not authenticated?")
end

---@return table
function Copilot:read_hosts_file()
  local hosts_file = string.format("%s/%s", self.config_path, self.hosts_file)
  local content, err = file.read_json_file(hosts_file)

  if not content and not err then
    error("Could not find Github hosts file: " .. hosts_file)
  end

  if not content then
    error("Could not read Github hosts file: " .. err)
  end

  return content
end

function Copilot:api_key_path()
  return string.format("%s/%s", self.config_path, self.api_key_file)
end

---@return table?
function Copilot:read_api_key_file()
  return file.read_json_file(self:api_key_path())
end

function Copilot:write_api_key_file(api_key)
  local err = file.write_json_file(self:api_key_path(), api_key)
  if err then
    error("Could not write Copilot api key: " .. err)
  end
end

---@return boolean
function Copilot:should_generate_new_api_key()
  if self.api_key == nil then
    return true
  end

  if self.api_key.expires_at == nil or self.api_key.token == nil then
    return true
  end

  return self.api_key.expires_at <= os.time()
end

function Copilot:generate_new_api_key(on_result, on_error)
  local headers = vim.tbl_deep_extend(
    "force",
    self.api_key_headers,
    { Authorization = string.format("token %s", self.oauth_token) }
  )
  local url = string.format("%s%s", self.api_key_url, self.api_key_endpoint)

  local response = curl.get(url, {
    headers = headers,
    on_error = function(err)
      on_error(err.message)
      error("Could not generate Copilot api key: " .. err.message)
    end,
  })

  if response.status ~= 200 then
    on_error(response.body)
    error("Could not generate Copilot api key: " .. response.body)
  end

  local result, err = json.decode(response.body)
  if not result then
    on_error(err)
    error("Could not generate Copilot api key: " .. err)
  end

  on_result(result)
end

return Copilot
