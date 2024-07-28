local Message = require("copilot_chat.message")
local Role = require("copilot_chat.enums").Role
local chat = require("copilot_chat.util.chat")
local log = require("plenary.log")

---@class CreateNewChat
---@field copilot_chat CopilotChat
local CreateNewChat = {}

---@param copilot_chat CopilotChat
function CreateNewChat:new(copilot_chat)
  local object = {
    copilot_chat = copilot_chat,
  }

  setmetatable(object, self)
  self.__index = self
  return object
end

---@param context Context
function CreateNewChat:execute(context)
  local chat_config = require("copilot_chat.config").get_chat_config(context.kind)
  local user_message = Message:new(Role.user, chat_config.builder(context))

  if user_message:is_empty() then
    chat.create_markdown_buffer(context, { user_message })
    return
  end

  local empty_assistant_response = Message:new(Role.assistant)
  chat.create_markdown_buffer(context, { user_message, empty_assistant_response })

  local system_prompt = Message:new(Role.system, chat_config.instruction)
  self.copilot_chat:complete(
    { model = chat_config.model, messages = { system_prompt, user_message } },
    chat.append_text,
    function(text, finish_reason)
      -- FIXME: `finish_reason` may indicate error
      log.debug("Chat finish reason: " .. finish_reason)

      local assistant_response = Message:new(Role.assistant, text)
      local empty_user_replay = Message:new()
      chat.update_markdown_buffer(context, { user_message, assistant_response, empty_user_replay })
    end,
    chat.raise_error
  )
end

return CreateNewChat
