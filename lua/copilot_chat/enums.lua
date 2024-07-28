---@enum ChatMode
local ChatMode = {
  append = "append",
  buffer = "buffer",
  insert = "insert",
  replace = "replace",
}

---@enum ChatModel
local ChatModel = {
  ["copilot-chat"] = "copilot-chat",
  ["gpt-4"] = "gpt-4",
}

---@enum ChatPosition
local ChatPosition = {
  horizontal = "horizontal",
  vertical = "vertical",
  tab = "tab",
}

---@enum ChatSelection
local ChatSelection = {
  visual_or_buffer = "visual_or_buffer",
  visual_or_none = "visual_or_none",
  none = "none",
}

---@enum HeaderKind
local HeaderKind = {
  prompt = "prompt",
  system = "system",
  user = "user",
  assistant = "assistant",
}

---@enum Role
local Role = {
  system = "system",
  user = "user",
  assistant = "assistant",
}

return {
  ChatMode = ChatMode,
  ChatModel = ChatModel,
  ChatPosition = ChatPosition,
  ChatSelection = ChatSelection,
  HeaderKind = HeaderKind,
  Role = Role,
}
