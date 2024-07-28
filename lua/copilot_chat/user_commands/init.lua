local CopilotChatCommand = require("copilot_chat.user_commands.copilot_chat")

---@class UserCommands
---@field created boolean Commands were created
---@field copilot_chat CopilotChatCommand Command for chat
local UserCommands = {}

---@param copilot_chat CopilotChat
function UserCommands:new(copilot_chat)
  vim.validate({
    ["UserCommands.copilot_chat"] = { copilot_chat, "table", false },
  })

  local object = {
    created = false,
    copilot_chat = CopilotChatCommand:new(copilot_chat),
  }

  setmetatable(object, self)
  self.__index = self
  return object
end

function UserCommands:init()
  if self.created then
    return
  end

  self.copilot_chat:init()

  self.created = true
end

return UserCommands
