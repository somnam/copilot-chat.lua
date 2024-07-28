local Config = require("copilot_chat.config")
local Context = require("copilot_chat.context")
local buffer = require("copilot_chat.util.buffer")
local mock = require("luassert.mock")

describe("Context", function()
  it("is_created_without_args", function()
    Config.setup()
    local filetype = mock(buffer.filetype, true)
    filetype.returns("")

    local context = Context.from_params({ range = 0 })

    assert(context.kind == "default")
    assert(context.args == nil)
    assert(context.selection == nil)
    assert(context.filetype == "")

    mock.revert(filetype)
    Config.reset()
  end)
end)

describe("Context.get_kind_and_user_args", function()
  Config.setup()

  it("returns_default_kind", function()
    local kind, args = Context.fargs_to_kind_and_user_args({})

    assert(kind == "default")
    assert(args == nil)
  end)

  it("returns_given_kind", function()
    local kind, args = Context.fargs_to_kind_and_user_args({ "explain" })

    assert(kind == "explain")
    assert(args == nil)
  end)

  it("returns_given_kind_and_args", function()
    local kind, args = Context.fargs_to_kind_and_user_args({ "explain", "2 + 2" })

    assert(kind == "explain")
    assert(args == "2 + 2")
  end)

  it("falls_back_to_default", function()
    local kind, args = Context.fargs_to_kind_and_user_args({ "chat" })

    assert(kind == "default")
    assert(args == "chat")
  end)

  Config.reset()
end)
