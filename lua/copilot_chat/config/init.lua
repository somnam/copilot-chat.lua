local ChatConfig = require("copilot_chat.config.chat")
local consts = require("copilot_chat.config.consts")
local defaults = require("copilot_chat.config.defaults")

---@class ConfigOptions
---@field chats ChatConfig[]
---@field kinds string[]

---@class Config
---@field options ConfigOptions
local Config = {
  consts = consts,
  ---@type ConfigOptions
  options = {
    chats = {},
    kinds = {},
  },
}

---@param opts table?
function Config.setup(opts)
  opts = opts or {}
  vim.validate({
    ["Config.chats"] = { opts.chats, "table", true },
  })

  Config.options.chats = Config._build_chats(opts.chats)
  Config.options.kinds = vim.tbl_keys(Config.options.chats)

  return Config.options
end

function Config.reset()
  Config.options = { chats = {}, kinds = {} }
end

---@param chats table?
function Config._build_chats(chats)
  local results = {}

  for _, chat in ipairs(defaults.chats) do
    results[chat.kind] = chat
  end

  for _, chat in ipairs(chats or {}) do
    if results[chat.kind] ~= nil then
      results[chat.kind]:update(chat)
    else
      results[chat.kind] = ChatConfig:new(chat)
    end
  end

  return results
end

---@param chat_kind string
function Config.get_chat_config(chat_kind)
  local chat_config = Config.options.chats[chat_kind]
  if chat_config == nil then
    error("Incorrect chat kind: " .. chat_kind)
  end

  return chat_config
end

return Config
