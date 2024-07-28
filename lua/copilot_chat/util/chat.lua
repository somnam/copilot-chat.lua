local Config = require("copilot_chat.config")
local buffer = require("copilot_chat.util.buffer")
local log = require("plenary.log")
local markdown = require("copilot_chat.markdown")

local M = {}

---@param context Context
---@param messages Message[]
function M.create_markdown_buffer(context, messages)
  local chat_markdown = markdown.build_chat_sections(context.kind, messages)
  buffer.create_markdown_buffer(context.position)
  buffer.set_var(Config.consts.CHAT_KIND_VAR, context.kind)
  buffer.set_name(M.new_buffer_name())
  buffer.overwrite(chat_markdown)
  buffer.move_to_end()
end

---@param context Context
---@param messages Message[]
function M.update_markdown_buffer(context, messages)
  local chat_markdown = markdown.build_chat_sections(context.kind, messages)
  buffer.overwrite(chat_markdown)
  buffer.move_to_end()
end

---@return string
function M.new_buffer_name()
  local date = os.date("%Y-%m-%d %H:%M:%S")
  return string.format("chat started at %s.md", date)
end

function M.append_text(text_chunk)
  buffer.append_text(text_chunk)
  buffer.move_to_end()
end

function M.raise_error(err)
  local message = "chat error: " .. err
  log.error(message)
  error(message)
end

return M
