local Copilot = require("copilot_chat.copilot")
local file = require("copilot_chat.util.file")
local luassert = require("luassert")
local mock = require("luassert.mock")

describe("Copilot", function()
  it("creates_new_instance", function()
    local copilot = Copilot:new()

    assert(copilot ~= nil)
  end)

  it("has_no_config_path", function()
    local copilot = Copilot:new()

    assert(copilot.config_path == nil)
  end)

  it("has_no_oauth_token", function()
    local copilot = Copilot:new()

    assert(copilot.oauth_token == nil)
  end)
end)

describe("Copilot:init", function()

  it("inits ok", function()
    local file_mock = mock(file, true)
    file_mock.dir_exists.returns(1)
    file_mock.read_json_file.returns({ ["github.com"] = { oauth_token = "12345" } }, "Oops")

    local copilot = Copilot:new()
    copilot:init()

    assert(copilot.config_path ~= nil)
    assert(copilot.oauth_token == "12345")

    mock.revert(file_mock)
  end)
end)

describe("Copilot:read_hosts_file", function()

  it("fails_to_find_hosts_file", function()
    local file_mock = mock(file, true)
    file_mock.read_json_file.returns(nil)

    local copilot = Copilot:new()
    copilot.config_path = "12345"
    copilot.hosts_file = "67890"

    luassert.error(function()
      copilot:read_hosts_file()
    end, "Could not find Github hosts file: 12345/67890")

    mock.revert(file_mock)
  end)

  it("fails_to_read_hosts_file", function()
    local file_mock = mock(file, true)
    file_mock.read_json_file.returns(nil, "Oops")

    local copilot = Copilot:new()
    copilot.config_path = "12345"
    copilot.hosts_file = "67890"

    luassert.error(function()
      copilot:read_hosts_file()
    end, "Could not read Github hosts file: Oops")

    mock.revert(file_mock)
  end)

  it("reads_hosts_file", function()
    local file_mock = mock(file, true)
    file_mock.read_json_file.returns({ ["github.com"] = {} }, "Oops")

    local copilot = Copilot:new()
    local content = copilot:read_hosts_file()

    assert(type(content) == "table")
    assert(type(content["github.com"]) == "table")

    mock.revert(file_mock)
  end)
end)

describe("Copilot:should_generate_new_api_key", function()
  it("checks_empty_api_key", function()
    local copilot = Copilot:new()

    assert(copilot:should_generate_new_api_key() == true)
  end)

  it("checks_api_key_with_empty_properties", function()
    local copilot = Copilot:new()
    copilot.api_key = { expires_at = nil, token = nil }

    assert(copilot:should_generate_new_api_key() == true)
  end)

  it("checks_expired_api_key", function()
    local copilot = Copilot:new()
    copilot.api_key = { expires_at = 1710101010, token = "token" }

    assert(copilot:should_generate_new_api_key() == true)
  end)

  it("checks_not_expired_api_key", function()
    local copilot = Copilot:new()
    copilot.api_key = { expires_at = os.time() + 1000, token = "token" }

    assert(copilot:should_generate_new_api_key() == false)
  end)
end)
