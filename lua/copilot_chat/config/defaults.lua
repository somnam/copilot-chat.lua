local ChatConfig = require("copilot_chat.config.chat")
local CopilotChat = require("copilot_chat.copilot.chat")
local Instructions = require("copilot_chat.copilot.instructions")
local git = require("copilot_chat.util.git")
local markdown = require("copilot_chat.markdown")
local ChatMode = require("copilot_chat.enums").ChatMode
local ChatSelection = require("copilot_chat.enums").ChatSelection

---@class ConfigDefaults
---@field chats ChatConfig[]
return {
  chats = {
    ChatConfig:new({
      kind = "default",
      instruction = Instructions.DEFAULT,
      mode = ChatMode.buffer,
      selection = ChatSelection.visual_or_none,
      builder = CopilotChat.user_selection_and_args,
    }),
    ChatConfig:new({
      kind = "default!",
      instruction = Instructions.DEFAULT,
      mode = ChatMode.buffer,
      selection = ChatSelection.visual_or_buffer,
      builder = CopilotChat.user_selection_and_args,
    }),
    ChatConfig:new({
      kind = "explain",
      instruction = Instructions.EXPLAIN,
      mode = ChatMode.buffer,
      selection = ChatSelection.visual_or_none,
      builder = CopilotChat.user_selection_and_args,
    }),
    ChatConfig:new({
      kind = "explain!",
      instruction = Instructions.EXPLAIN,
      mode = ChatMode.buffer,
      selection = ChatSelection.visual_or_buffer,
      builder = CopilotChat.user_selection_and_args,
    }),
    ChatConfig:new({
      kind = "refactor",
      instruction = Instructions.SENIOR,
      mode = ChatMode.buffer,
      selection = ChatSelection.visual_or_none,
      builder = CopilotChat.user_selection_and_args,
    }),
    ChatConfig:new({
      kind = "refactor!",
      instruction = Instructions.SENIOR,
      mode = ChatMode.buffer,
      selection = ChatSelection.visual_or_buffer,
      builder = CopilotChat.user_selection_and_args,
    }),
    ChatConfig:new({
      kind = "fix",
      instruction = Instructions.FIX,
      mode = ChatMode.buffer,
      selection = ChatSelection.visual_or_none,
      builder = CopilotChat.user_selection_and_args,
    }),
    ChatConfig:new({
      kind = "fix!",
      instruction = Instructions.FIX,
      mode = ChatMode.buffer,
      selection = ChatSelection.visual_or_buffer,
      builder = CopilotChat.user_selection_and_args,
    }),
    ChatConfig:new({
      kind = "tests",
      instruction = Instructions.TESTS,
      mode = ChatMode.buffer,
      selection = ChatSelection.visual_or_none,
      builder = CopilotChat.user_selection_and_args,
    }),
    ChatConfig:new({
      kind = "tests!",
      instruction = Instructions.TESTS,
      mode = ChatMode.buffer,
      selection = ChatSelection.visual_or_buffer,
      builder = CopilotChat.user_selection_and_args,
    }),
    ChatConfig:new({
      kind = "new",
      instruction = Instructions.NEW,
      mode = ChatMode.buffer,
      selection = ChatSelection.none,
      builder = CopilotChat.user_args,
    }),
    ChatConfig:new({
      kind = "workspace",
      instruction = Instructions.WORKSPACE,
      mode = ChatMode.buffer,
      selection = ChatSelection.none,
      builder = CopilotChat.user_args,
    }),
    ChatConfig:new({
      kind = "commit",
      instruction = Instructions.COMMIT,
      mode = ChatMode.insert,
      selection = ChatSelection.none,
      builder = function()
        return markdown.format_git_diff(git.diff())
      end,
    }),
  },
}
