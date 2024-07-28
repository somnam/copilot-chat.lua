local markdown = require("copilot_chat.markdown")
local Role = require("copilot_chat.enums").Role
local Message = require("copilot_chat.message")
local HeaderKind = require("copilot_chat.enums").HeaderKind

describe("Markdown", function()
  it("maps headers", function()
    assert(markdown.headers[HeaderKind.prompt] == "# Prompt")
    assert(markdown.headers[HeaderKind.user] == "# User")
    assert(markdown.headers[HeaderKind.system] == "# System")
    assert(markdown.headers[HeaderKind.assistant] == "# Assistant")
  end)
end)

describe("Markdown.messages_to_markdown", function()
  it("converts message w/o content", function()
    local results = markdown.message_sections({ Message:new(Role.user) })
    assert(vim.inspect(results) == vim.inspect({ "# User", "", "" }))
  end)

  it("converts message with content", function()
    local results = markdown.message_sections({ Message:new(Role.user, "Multiply six by seven") })
    assert(vim.inspect(results) == vim.inspect({ "# User", "", "Multiply six by seven", "" }))
  end)
end)
