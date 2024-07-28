local Message = require("copilot_chat.message")
local Role = require("copilot_chat.enums").Role
local chat = require("copilot_chat.util.chat")
local log = require("plenary.log")
local markdown = require("copilot_chat.markdown")

---@class ContinueExistingChat
---@field copilot_chat CopilotChat
local ContinueExistingChat = {}

---@param copilot_chat CopilotChat
function ContinueExistingChat:new(copilot_chat)
  local object = {
    copilot_chat = copilot_chat,
  }

  setmetatable(object, self)
  self.__index = self
  return object
end

---@param context Context
function ContinueExistingChat:execute(context)
  local chat_messages = markdown.messsages_from_markdown()
  local last_message = chat_messages[#chat_messages]
  if last_message == nil or last_message:is_empty() then
    return
  end

  local empty_assistant_response = Message:new(Role.assistant)
  chat.update_markdown_buffer(
    context,
    vim.list_extend(vim.list_slice(chat_messages), { empty_assistant_response })
  )

  local chat_config = require("copilot_chat.config").get_chat_config(context.kind)
  local system_prompt = Message:new(Role.system, chat_config.instruction)

  self.copilot_chat:complete(
    { model = chat_config.model, messages = vim.list_extend({ system_prompt }, chat_messages) },
    chat.append_text,
    function(text, finish_reason)
      log.debug("Chat finish reason: " .. finish_reason)

      local assistant_response = Message:new(Role.assistant, text)
      local empty_user_replay = Message:new()
      chat.update_markdown_buffer(
        context,
        vim.list_extend(chat_messages, { assistant_response, empty_user_replay })
      )
    end,
    chat.raise_error
  )
end

return ContinueExistingChat
