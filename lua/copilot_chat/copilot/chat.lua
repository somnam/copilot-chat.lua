local consts = require("copilot_chat.copilot.consts")
local curl = require("plenary.curl")
local json = require("copilot_chat.util.json")
local log = require("plenary.log")
local markdown = require("copilot_chat.markdown")

---@class CopilotChat
---@field copilot Copilot Copilot
---@field url string Copilot Chat API url
---@field endpoint string Copilot Chat API endpoint
---@field headers table Copilot Chat API headers
---@field params table Copilot Chat model params
---@field instructions table Copilot Chat model instructions
---@field system string Copilot Chat default instruction
local CopilotChat = {}

---@param copilot Copilot
function CopilotChat:new(copilot)
  vim.validate({
    ["CopilotChat.copilot"] = { copilot, "table", true },
  })
  local object = {
    copilot = copilot,
    url = "https://api.githubcopilot.com/",
    endpoint = "chat/completions",
    headers = {
      ["Editor-Version"] = consts.EDITOR_VERSION,
      ["Editor-Plugin-Version"] = consts.EDITOR_PLUGIN_VERSION,
      ["User-Agent"] = consts.USER_AGENT,
      ["Openai-Organization"] = consts.OPENAI_ORGANIZATION,
      ["Openai-Intent"] = consts.OPENAI_INTENT,
      ["Content-Type"] = "application/json",
    },
    params = {
      intent = true,
      stream = true,
      n = 1,
      temperature = 0.1,
      top_p = 1,
    },
  }

  setmetatable(object, self)
  self.__index = self
  return object
end

function CopilotChat:init()
  self.copilot:init()
end

function CopilotChat:ensure_api_key_valid()
  local api_key = self.copilot.api_key or self.copilot:read_api_key_file()

  if self.copilot:should_generate_new_api_key() then
    local function on_result(body)
      api_key = { token = body.token, expires_at = body.expires_at }
      self.copilot:write_api_key_file(api_key)
    end
    self.copilot:generate_new_api_key(on_result, log.error)
  end

  self.copilot.api_key = api_key
end

---@return table
function CopilotChat:get_completion_request_headers()
  local authorization = string.format("Bearer %s", self.copilot.api_key.token)
  return vim.tbl_deep_extend("force", self.headers, { Authorization = authorization })
end

---@return string
function CopilotChat:get_completion_request_url()
  return string.format("%s%s", self.url, self.endpoint)
end

---@param params table
---@return string
function CopilotChat:get_completion_request_body(params)
  local request_params = vim.tbl_deep_extend("force", vim.deepcopy(self.params), params)

  local body, err = json.encode(request_params)
  if not body then
    error("Could not encode request params due to: " .. err)
  end

  return body
end

function CopilotChat:complete(params, on_chunk, on_finish, on_error)
  self:ensure_api_key_valid()

  local headers = self:get_completion_request_headers()
  local url = self:get_completion_request_url()
  local body = self:get_completion_request_body(params)

  local completion = ""

  curl.post(url, {
    headers = headers,
    body = body,
    stream = function(err, response)
      if err ~= nil then
        on_error(err)
        error("Copilot Chat API error: " .. err)
      end

      if response == consts.BAD_REQUEST then
        on_error(response)
        error("Copilot Chat API client error: " .. response)
      end

      local result = self:decode_completion_response(response)
      if result.error ~= nil then
        local err = vim.inspect(result.error)
        on_error(err)
        error("Copilot Chat API error result: " .. err)
      end

      local message = self:extract_chat_data(result)
      if message.content ~= nil then
        completion = completion .. message.content
        vim.schedule(function()
          on_chunk(message.content)
        end)
      end

      if message.finish_reason ~= nil then
        vim.schedule(function()
          on_finish(completion, message.finish_reason)
        end)
      end
    end,
    on_error = function(err)
      on_error(err.message)
      error("Copilot Chat API error: " .. err.message)
    end,
  })
end

---@param response string
---@return table
function CopilotChat:decode_completion_response(response)
  response = string.gsub(response, "data: ", "")
  if #response == 0 or response == consts.END_OF_RESPONSE then
    return {}
  end

  local result, err = json.decode(response)
  if result == nil then
    error("Unable to decode completion response: " .. response)
  end

  return result
end

---@param response table
---@return table
function CopilotChat:extract_chat_data(response)
  if response.choices ~= nil and #response.choices > 0 then
    return {
      content = (response.choices[1].delta or {}).content,
      finish_reason = response.choices[1].finish_reason,
    }
  else
    return { content = nil, finish_reason = nil }
  end
end

---@param context Context
---@return string?
function CopilotChat.user_args(context)
  return context.args
end

---@param selection table
---@return string?
function CopilotChat.user_selection_to_markdown(selection)
  if selection then
    local filetype = vim.bo.filetype or ""
    return markdown.format_active_selection_list(selection, filetype)
  end
end

---@param context Context
---@return string[]
function CopilotChat.user_selection_and_args(context)
  local content = {}
  local user_args = context.args
  if user_args ~= nil then
    table.insert(content, user_args)
  end

  local user_selection = CopilotChat.user_selection_to_markdown(context.selection)
  if user_selection ~= nil then
    table.insert(content, user_selection)
  end

  return content
end

return CopilotChat
