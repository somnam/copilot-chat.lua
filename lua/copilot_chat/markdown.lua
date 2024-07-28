local HeaderKind = require("copilot_chat.enums").HeaderKind
local Role = require("copilot_chat.enums").Role
local Message = require("copilot_chat.message")
local buffer = require("copilot_chat.util.buffer")

---@class Markdown
---@field active_selection_tmpl string
---@field git_diff_tmpl string
---@field separator string
---@field header_level table
---@field headers table
local M = {}

M.active_selection_tmpl = [[
Active selection:
```%s
%s
```
]]

M.git_diff_tmpl = [[
Git diff:
```
%s
```
]]

M.separator = ""

M.header_pattern = "^#+[%s%w]"


M.headers = {
  [HeaderKind.prompt] = "# Prompt",
  [HeaderKind.system] = "# System",
  [HeaderKind.user] = "# User",
  [HeaderKind.assistant] = "# Assistant",
}

function M.format_active_selection(input, filetype)
  return string.format(M.active_selection_tmpl, (filetype or ""), (input or ""))
end

function M.format_active_selection_list(lines, filetype)
  return M.format_active_selection(table.concat(lines, "\n"), filetype)
end

function M.format_git_diff(git_diff)
  return string.format(M.git_diff_tmpl, (git_diff or ""))
end

---@param chat_kind string
---@param messages Message[]
M.build_chat_sections = function(chat_kind, messages)
  return vim.list_extend(M.prompt_section(chat_kind), M.message_sections(messages))
end

M.prompt_section = function(chat_kind)
  return M.to_markdown_section(HeaderKind.prompt, chat_kind)
end

---@param messages Message[]
---@return string[]
M.message_sections = function(messages)
  local markdown = {}

  for _, message in ipairs(messages) do
    vim.list_extend(markdown, M.message_section(message))
  end

  return markdown
end

---@param message Message
---@return string[]
M.message_section = function(message)
  return M.to_markdown_section(message.role, message:content_into_list())
end

M.to_markdown_header = function(kind)
  return { M.headers[kind], M.separator }
end

---@param kind HeaderKind
---@param content string | table
---@return string[]
M.to_markdown_section = function(kind, content)
  local markdown = M.to_markdown_header(kind)

  content = content or ""
  if type(content) == "table" and vim.islist(content) then
    vim.list_extend(markdown, content)
  elseif #content > 0 then
    table.insert(markdown, content)
  end

  table.insert(markdown, M.separator)

  return markdown
end

---@param header_line string
---@return HeaderKind
M.header_line_to_kind = function(header_line)
  local maybe_header_kind = string.lower(string.gsub(header_line, M.header_pattern, ""))
  local header_kind = HeaderKind[maybe_header_kind]

  if header_kind == nil then
    error("Incorrect section header: " .. maybe_header_kind)
  end

  return header_kind
end

---@param section_lines table
---@return string
M.section_lines_to_kind = function(section_lines)
  local Config = require("copilot_chat.config")
  for _, maybe_kind in ipairs(section_lines) do
    if maybe_kind ~= nil and vim.tbl_contains(Config.options.kinds, maybe_kind) then
      return maybe_kind
    end
  end

  error("Could not find chat kind in chat file")
end

M.headers_idx_from_markdown = function(buf_lines)
  local headers_idx = {}
  for idx, buf_line in ipairs(buf_lines) do
    if buf_line:match(M.header_pattern) then
      table.insert(headers_idx, idx)
    end
  end

  return headers_idx
end

---@param section_lines table
---@return Message
M.prompt_from_section = function(section_lines)
  local kind = M.section_lines_to_kind(section_lines)
  local Config = require("copilot_chat.config")
  local chat = Config.options.chats[kind]
  return Message:new(Role.system, chat.instruction)
end

---@param section_lines table
---@param header_kind HeaderKind
---@return Message
M.chat_message_from_section = function(section_lines, header_kind)
  return Message:new(Role[header_kind], section_lines)
end

---@return Message[]
M.messsages_from_markdown = function()
  local buf_lines = buffer.all_lines()
  local headers_idx = M.headers_idx_from_markdown(buf_lines)

  local chat_messages = {}
  for idx, header_idx in ipairs(headers_idx) do
    local section_start = header_idx + 1
    local next_header_idx = headers_idx[idx + 1] and headers_idx[idx + 1] or #buf_lines
    local section_end = next_header_idx < #buf_lines and next_header_idx - 1 or #buf_lines

    local header_kind = M.header_line_to_kind(buf_lines[header_idx])
    local section_lines = { unpack(buf_lines, section_start, section_end) }

    if header_kind ~= HeaderKind.prompt then
      local message = M.chat_message_from_section(section_lines, header_kind)
      table.insert(chat_messages, message)
    end
  end

  return chat_messages
end

return M
