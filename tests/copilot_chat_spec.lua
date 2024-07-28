local CopilotChat = require("copilot_chat.copilot.chat")

describe("CopilotChat", function()
  local copilot = {}

  it("creates_new_instance", function()
    local copilot_chat = CopilotChat:new(copilot)

    assert(copilot_chat ~= nil)
    assert(copilot_chat.copilot == copilot)
  end)
end)

describe("CopilotChat:extract_chat_data", function()
  local copilot = {}

  it("has_no_data", function()
    local copilot_chat = CopilotChat:new(copilot)

    local result = copilot_chat:extract_chat_data({})

    assert(type(result) == "table")
    assert(vim.inspect(result) == vim.inspect({ content = nil, finish_reason = nil }))
  end)

  it("has_no_choices", function()
    local copilot_chat = CopilotChat:new(copilot)

    local result = copilot_chat:extract_chat_data({ choices = {} })

    assert(type(result) == "table")
    assert(vim.inspect(result) == vim.inspect({ content = nil, finish_reason = nil }))
  end)
end)
