local Config = require("copilot_chat.config")
local Context = require("copilot_chat.context")
local ContinueExistingChat = require("copilot_chat.services.continue_existing_chat")
local CreateNewChat = require("copilot_chat.services.create_new_chat")

---@class CopilotChatCommand
---@field name string Command name
---@field opts string Command options
---@field copilot_chat CopilotChat
---@field create_new_chat CreateNewChat
---@field continue_existing_chat ContinueExistingChat
local CopilotChatCommand = {}

---@param copilot_chat CopilotChat
function CopilotChatCommand:new(copilot_chat)
  local object = {
    name = "CC",
    opts = {
      bang = true,
      desc = "Chat with Copilot",
      nargs = "*",
      range = true,
      complete = CopilotChatCommand.complete,
    },
    copilot_chat = copilot_chat,
    create_new_chat = CreateNewChat:new(copilot_chat),
    continue_existing_chat = ContinueExistingChat:new(copilot_chat),
  }

  setmetatable(object, self)
  self.__index = self
  return object
end

---@param arglead string
function CopilotChatCommand.complete(arglead)
  if #arglead == 0 then
    return Config.options.kinds
  end

  return vim.fn.matchfuzzy(Config.options.kinds, arglead)
end

function CopilotChatCommand:init()
  self.copilot_chat:init()

  local function command(params)
    self:execute(params)
  end
  vim.api.nvim_create_user_command(self.name, command, self.opts)
end

---@return string
function CopilotChatCommand.buffer_name()
  local date = os.date("%Y-%m-%d %H:%M:%S")
  return string.format("chat started at %s.md", date)
end

---@param params table
function CopilotChatCommand:execute(params)
  local context = Context.from_params(params)

  if context:chat_exists_and_kind_provided() then
    self.create_new_chat:execute(context)
  elseif context.chat_exists() then
    self.continue_existing_chat:execute(context)
  else
    self.create_new_chat:execute(context)
  end
end

return CopilotChatCommand
