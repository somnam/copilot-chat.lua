local Config = require("copilot_chat.config")
local Context = require("copilot_chat.context")
local Copilot = require("copilot_chat.copilot")
local CopilotChat = require("copilot_chat.copilot.chat")
local CopilotChatCommand = require("copilot_chat.user_commands.copilot_chat")
local UserCommands = require("copilot_chat.user_commands")
local buffer = require("copilot_chat.util.buffer")
local mock = require("luassert.mock")
local spy = require("luassert.spy")

describe("UserCommands.copilot_chat", function()
  Config.setup()
  local buffer_mock = mock(buffer, true)
  buffer_mock.all_lines.returns({ "" })
  buffer_mock.filetype.returns("")

  local copilot_mock = mock(Copilot, true)
  copilot_mock.api_key = { token = "token", expires_at = 1111111111 }

  local context_spy = spy.on(Context, "new")

  local copilot_chat = CopilotChat:new(copilot_mock)
  local user_commands = UserCommands:new(copilot_chat)
  user_commands:init()

  it("runs_without_args", function()
    local copilot_chat_command = user_commands.copilot_chat
    local ok, result = pcall(vim.cmd[copilot_chat_command.name])

    assert(ok == true, vim.inspect(result))
    context_spy:returned_with(Context:new({
      kind = "default",
      position = "horizontal",
      filetype = "",
    }))

    context_spy:clear()
  end)

  it("runs_with_args", function()
    local copilot_chat_command = user_commands.copilot_chat
    local ok, result = pcall(vim.cmd[copilot_chat_command.name], "Multiply six by seven")

    assert(ok == true, vim.inspect(result))
    context_spy:returned_with(Context:new({
      kind = "default",
      args = "Multiply six by seven",
      position = "horizontal",
      filetype = "",
    }))

    context_spy:clear()
  end)

  it("runs_with_kind_and_args", function()
    local copilot_chat_command = user_commands.copilot_chat
    local ok, result = pcall(vim.cmd[copilot_chat_command.name], "explain", "But why?")

    assert(ok == true, vim.inspect(result))
    context_spy:returned_with(Context:new({
      kind = "explain",
      args = "But why?",
      position = "horizontal",
      filetype = "",
    }))

    context_spy:clear()
  end)

  context_spy:revert()
  mock.revert(buffer_mock)
  mock.revert(copilot_mock)
  Config.reset()
end)

describe("CopilotChatCommand.complete", function()
  Config.setup({
    chats = {
      {
        kind = "make-sandwich",
        instruction = "Make a sandwich",
        builder = CopilotChat.user_args,
      },
      {
        kind = "suggest-sandwich",
        instruction = "Suggest a sandwich from these ingredients",
      },
    },
  })

  it("returns all options", function()
    local results = CopilotChatCommand.complete("")

    table.sort(results)
    assert(vim.inspect(results) == vim.inspect({
      "commit",
      "default",
      "default!",
      "explain",
      "explain!",
      "fix",
      "fix!",
      "make-sandwich",
      "new",
      "refactor",
      "refactor!",
      "suggest-sandwich",
      "tests",
      "tests!",
      "workspace",
    }))
  end)

  it("returns selected options", function()
    local results = CopilotChatCommand.complete("san")

    table.sort(results)
    assert(vim.inspect(results) == vim.inspect({
      "make-sandwich",
      "suggest-sandwich",
    }))
  end)

  Config.reset()
end)
