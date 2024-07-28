local CopilotChat = require("copilot_chat.copilot.chat")
local ChatMode = require("copilot_chat.enums").ChatMode
local ChatModel = require("copilot_chat.enums").ChatModel
local ChatSelection = require("copilot_chat.enums").ChatSelection

---@class ChatConfig
---@field kind string
---@field instruction string
---@field prompt string?
---@field model ChatModel
---@field mode ChatMode
---@field selection ChatSelection
---@field builder function
local ChatConfig = {}

---@param opts table
function ChatConfig.validate(opts)
  vim.validate({
    ["ChatConfig.kind"] = { opts.kind, "string", false },
    ["ChatConfig.instruction"] = { opts.instruction, "string", true },
    ["ChatConfig.prompt"] = { opts.prompt, "string", true },
    ["ChatConfig.model"] = {
      opts.mode,
      function(value)
        return value and ChatModel[value] ~= nil or true
      end,
    },
    ["ChatConfig.mode"] = {
      opts.mode,
      function(value)
        return value and ChatMode[value] ~= nil or true
      end,
    },
    ["ChatConfig.selection"] = {
      opts.selection,
      function(value)
        return value and ChatSelection[value] ~= nil or true
      end,
    },
    ["ChatConfig.builder"] = { opts.builder, "function", true },
  })
end

---@param opts table?
function ChatConfig:new(opts)
  opts = opts or {}
  ChatConfig.validate(opts)

  local object = {
    kind = opts.kind,
    instruction = opts.instruction or "default",
    prompt = opts.prompt,
    model = opts.model or ChatModel["gpt-4"],
    mode = opts.mode or ChatMode.buffer,
    selection = opts.selection or ChatSelection.visual_or_buffer,
    builder = opts.builder or CopilotChat.user_selection_and_args,
  }

  setmetatable(object, self)
  self.__index = self
  return object
end

---@param opts table?
function ChatConfig:update(opts)
  opts = opts or {}
  ChatConfig.validate(opts)

  for key, opt in pairs(opts) do
    self[key] = opt
  end
end

return ChatConfig
