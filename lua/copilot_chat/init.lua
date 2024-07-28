local Config = require("copilot_chat.config")
local Copilot = require("copilot_chat.copilot")
local CopilotChat = require("copilot_chat.copilot.chat")
local UserCommands = require("copilot_chat.user_commands")

---@class CopilotChat
---@field setup_done boolean
---@field config ConfigOptions?
---@field user_commands UserCommands?
---@field setup function
local M = {
  config = nil,
  user_commands = nil,
  setup_done = false,
}

---@param opts table?
M.setup = function(opts)
  if M.setup_done then
    return
  end

  M.config = Config.setup(opts)
  M.user_commands = UserCommands:new(CopilotChat:new(Copilot:new()))
  M.user_commands:init()

  M.setup_done = true
end

return M
