local plugin = require("copilot_chat.init")

describe("plugin.setup", function()
  it("completes", function()
    plugin.setup()

    assert(plugin.setup_done == true)
    assert(plugin.config ~= nil)
    assert(plugin.user_commands ~= nil)
    assert(plugin.user_commands.created == true)
  end)
end)
