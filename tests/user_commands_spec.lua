local Config = require("copilot_chat.config")
local Copilot = require("copilot_chat.copilot")
local CopilotChat = require("copilot_chat.copilot.chat")
local UserCommands = require("copilot_chat.user_commands")
local mock = require("luassert.mock")

describe("UserCommands", function()
  Config.setup()
  local copilot_mock = mock(Copilot, true)
  local copilot_chat = CopilotChat:new(copilot_mock)
  local user_commands = UserCommands:new(copilot_chat)

  it("is_not_initialized", function()
    assert(user_commands.created == false)
  end)

  it("is_initialized", function()
    user_commands:init()

    assert(user_commands.created == true)
  end)

  mock.revert(copilot_mock)
  Config.reset()
end)
