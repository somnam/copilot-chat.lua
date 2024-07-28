local ChatConfig = require("copilot_chat.config.chat")
local ChatSelection = require("copilot_chat.enums").ChatSelection
local Config = require("copilot_chat.config")
local CopilotChat = require("copilot_chat.copilot.chat")
local Instructions = require("copilot_chat.copilot.instructions")
local ChatMode = require("copilot_chat.enums").ChatMode

local function assert_default_chats()
  assert(vim.inspect(Config.options.chats["default"]) == vim.inspect(ChatConfig:new({
    kind = "default",
    instruction = Instructions.DEFAULT,
    selection = ChatSelection.visual_or_none,
  })))
  assert(vim.inspect(Config.options.chats["default!"]) == vim.inspect(ChatConfig:new({
    kind = "default!",
    instruction = Instructions.DEFAULT,
    selection = ChatSelection.visual_or_buffer,
  })))
  assert(vim.inspect(Config.options.chats["explain"]) == vim.inspect(ChatConfig:new({
    kind = "explain",
    instruction = Instructions.EXPLAIN,
    selection = ChatSelection.visual_or_none,
  })))
  assert(vim.inspect(Config.options.chats["explain!"]) == vim.inspect(ChatConfig:new({
    kind = "explain!",
    instruction = Instructions.EXPLAIN,
    selection = ChatSelection.visual_or_buffer,
  })))
  assert(vim.inspect(Config.options.chats["refactor"]) == vim.inspect(ChatConfig:new({
    kind = "refactor",
    instruction = Instructions.SENIOR,
    selection = ChatSelection.visual_or_none,
  })))
  assert(vim.inspect(Config.options.chats["refactor!"]) == vim.inspect(ChatConfig:new({
    kind = "refactor!",
    instruction = Instructions.SENIOR,
    selection = ChatSelection.visual_or_buffer,
  })))
  assert(vim.inspect(Config.options.chats["fix"]) == vim.inspect(ChatConfig:new({
    kind = "fix",
    instruction = Instructions.FIX,
    selection = ChatSelection.visual_or_none,
  })))
  assert(vim.inspect(Config.options.chats["fix!"]) == vim.inspect(ChatConfig:new({
    kind = "fix!",
    instruction = Instructions.FIX,
    selection = ChatSelection.visual_or_buffer,
  })))
  assert(
    vim.inspect(Config.options.chats["tests"])
      == vim.inspect(
        ChatConfig:new({
          kind = "tests",
          instruction = Instructions.TESTS,
          selection = ChatSelection.visual_or_none,
        })
      )
  )
  assert(
    vim.inspect(Config.options.chats["tests!"])
      == vim.inspect(
        ChatConfig:new({
          kind = "tests!",
          instruction = Instructions.TESTS,
          selection = ChatSelection.visual_or_buffer,
        })
      )
  )
  assert(vim.inspect(Config.options.chats["new"]) == vim.inspect(ChatConfig:new({
    kind = "new",
    instruction = Instructions.NEW,
    selection = ChatSelection.none,
    builder = CopilotChat.user_args,
  })))
  assert(vim.inspect(Config.options.chats["workspace"]) == vim.inspect(ChatConfig:new({
    kind = "workspace",
    instruction = Instructions.WORKSPACE,
    selection = ChatSelection.none,
    builder = CopilotChat.user_args,
  })))
  assert(vim.inspect(Config.options.chats["commit"]) == vim.inspect(ChatConfig:new({
    kind = "commit",
    instruction = Instructions.COMMIT,
    mode = ChatMode.insert,
    selection = ChatSelection.none,
    builder = CopilotChat.user_args,
  })))
end

describe("Config", function()
  it("uses_defaults", function()
    Config.setup()

    assert_default_chats()

    Config.reset()
  end)

  it("uses_custom", function()
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

    assert_default_chats()
    assert(vim.inspect(Config.options.chats["make-sandwich"]) == vim.inspect(ChatConfig:new({
      kind = "make-sandwich",
      instruction = "Make a sandwich",
      builder = CopilotChat.user_args,
    })))
    assert(vim.inspect(Config.options.chats["suggest-sandwich"]) == vim.inspect(ChatConfig:new({
      kind = "suggest-sandwich",
      instruction = "Suggest a sandwich from these ingredients",
    })))

    Config.reset()
  end)

  it("updates_default", function()
    Config.setup({
      chats = {
        {
          kind = "explain",
          mode = ChatMode.replace,
          selection = ChatSelection.visual_or_none,
        },
      },
    })

    local explain = Config.options.chats["explain"]
    assert(explain.__index)
    assert(explain.kind == "explain")
    assert(explain.instruction == Instructions.EXPLAIN)
    assert(explain.mode == ChatMode.replace)
    assert(explain.selection == ChatSelection.visual_or_none)

    Config.reset()
  end)
end)
