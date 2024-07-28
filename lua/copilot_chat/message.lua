local Role = require("copilot_chat.enums").Role

---@class Message
---@field role Role
---@field content string
local Message = {}

---@param role Role?
---@param content table | string?
function Message:new(role, content)
  vim.validate({
    ["Message.role"] = {
      role,
      function(value)
        return value and Role[value] ~= nil or true
      end,
    },
    ["Message.content"] = { content, { "string", "table" }, true },
  })

  local object = {
    role = role or Role.user,
    content = Message.normalize_content(content),
  }

  setmetatable(object, self)
  self.__index = self
  return object
end

---@return string[]
function Message:content_into_list()
  if #self.content > 0 then
    return vim.split(self.content, "\n")
  end
  return {}
end

---@param content table | string?
---@return string
function Message.normalize_content(content)
  if type(content) == "table" then
    local parsed_content = table.concat(content, "\n")
    parsed_content = string.gsub(parsed_content, "^%s+", "")
    parsed_content = string.gsub(parsed_content, "%s+$", "")
    return parsed_content
  end
  return content or ""
end

function Message:is_empty()
  return #self.content == 0
end

return Message
