local ChatPosition = require("copilot_chat.enums").ChatPosition
local ChatSelection = require("copilot_chat.enums").ChatSelection
local Config = require("copilot_chat.config")
local buffer = require("copilot_chat.util.buffer")
local input = require("copilot_chat.util.input")

---@class Context
---@field kind string
---@field args string?
---@field kind_provided boolean
---@field position ChatPosition
---@field selection table?
---@field filetype string
local Context = {}

---@param opts table?
function Context:new(opts)
  opts = opts or {}
  vim.validate({
    ["Context.kind"] = { opts.kind, "string", false },
    ["Context.args"] = { opts.args, "string", true },
    ["Context.kind_provided"] = { opts.kind_provided, "string", true },
    ["Context.position"] = {
      opts.position,
      function(value)
        return ChatPosition[value] ~= nil
      end,
    },
    ["Context.selection"] = { opts.selection, "table", true },
    ["Context.filetype"] = { opts.filetype, "string", false },
  })

  local object = {
    kind = opts.kind,
    args = opts.args,
    kind_provided = opts.kind_provided,
    position = opts.position,
    selection = opts.selection,
    filetype = opts.filetype,
  }

  setmetatable(object, self)
  self.__index = self
  return object
end

---@param params table?
function Context.from_params(params)
  params = params or {}
  local fargs = params.fargs or {}
  local smods = params.smods or {}
  local kind_provided = Context.fargs_to_kind_provided(fargs)
  local kind, args = Context.fargs_to_kind_and_user_args(fargs)
  local position = Context.smods_to_position(smods)
  local selection = Context.params_to_selection(params)
  local filetype = buffer.filetype()

  return Context:new({
    kind = kind,
    args = args,
    kind_provided = kind_provided,
    position = position,
    selection = selection,
    filetype = filetype,
  })
end

function Context.chat_exists()
  return buffer.has_var(Config.consts.CHAT_KIND_VAR)
end

function Context:chat_exists_and_kind_provided()
  return Context.chat_exists() and self.kind_provided ~= nil
end

---@param fargs table
---@return string?
function Context.fargs_to_kind_provided(fargs)
  local maybe_kind = fargs[1]
  if maybe_kind ~= nil and vim.tbl_contains(Config.options.kinds, maybe_kind) then
    return maybe_kind
  end
end

---@param fargs table
---@return string, string?
function Context.fargs_to_kind_and_user_args(fargs)
  local args = nil
  local kind = nil
  local maybe_kind = Context.fargs_to_kind_provided(fargs)

  -- New chat with specified kind and optional args
  if maybe_kind then
    kind = fargs[1]
    args = Context.fargs_to_user_args(vim.list_slice(fargs, 2))
  -- Existing chat with optional args
  elseif Context.chat_exists() then
    kind = buffer.get_var(Config.consts.CHAT_KIND_VAR)
    args = Context.fargs_to_user_args(fargs)
  end

  -- New chat with optional args
  if kind == nil then
    kind = "default"
    args = Context.fargs_to_user_args(fargs)
  end

  return kind, args
end

---@param fargs table
---@return string
function Context.fargs_to_kind(fargs)
  local kind = nil
  local maybe_kind = Context.fargs_to_kind_provided(fargs)

  -- New chat with specified kind and optional args
  if maybe_kind then
    kind = fargs[1]
  -- Existing chat with optional args
  elseif Context.chat_exists() then
    kind = buffer.get_var(Config.consts.CHAT_KIND_VAR)
  end

  -- New chat with optional args
  if kind == nil then
    kind = "default"
  end

  return kind
end

---@param fargs table
---@return string?
function Context.fargs_to_user_args(fargs)
  if fargs ~= nil and #fargs > 0 then
    return table.concat(fargs, " ")
  end
end

---@param smods table
---@return ChatPosition
function Context.smods_to_position(smods)
  if smods.tab ~= nil and smods.tab > 0 then
    return ChatPosition.tab
  elseif smods.vertical then
    return ChatPosition.vertical
  end

  return ChatPosition.horizontal
end

---@param params table
---@return table?
function Context.params_to_selection(params)
  local fargs = params.fargs or {}
  local kind = Context.fargs_to_kind(fargs)
  local chat_config = require("copilot_chat.config").get_chat_config(kind)

  if chat_config.selection == ChatSelection.none then
    return nil
  end

  local is_visual = params.range ~= 0
  local visual_selection = is_visual and buffer.get_text(input.Selection.visual()) or nil

  if chat_config.selection == ChatSelection.visual_or_none then
    return visual_selection
  end

  if chat_config.selection == ChatSelection.visual_or_buffer then
    return visual_selection or buffer.all_lines()
  end
end

return Context
