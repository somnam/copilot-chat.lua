---@class Position
---@field row number
---@field col number
local Position = {}

---@param row number
---@param col number
function Position:new(row, col)
  local object = { row = row, col = col }

  setmetatable(object, self)
  self.__index = self
  return object
end

---@return Position
function Position.cursor()
  local cursor = vim.fn.getpos("'>")
  return Position:new(cursor[2] - 1, cursor[3])
end

---@return Position
function Position.visual()
  local vpos = vim.fn.getpos("v")
  return Position:new(vpos[2] - 1, vpos[3] - 1)
end

---@return Position
function Position.buffer_end()
  local lastpos = vim.fn.getpos("$")
  local bufnr = vim.api.nvim_get_current_buf()
  local last_line = unpack(vim.api.nvim_buf_get_lines(bufnr, -2, -1, false))
  local last_col = #last_line > 0 and #last_line or 0
  return Position:new(lastpos[2] - 1, last_col)
end

---@return boolean
function Position:is_before(other)
  return self.row < other.row or (self.row == other.row and self.col < other.col)
end

---@return boolean
function Position:at_max_col()
  return self.col == vim.v.maxcol
end

---@return Position
function Position:move_to_next_line()
  return Position:new(self.row + 1, 0)
end

---@return Position
function Position:move_to_last_column()
  return Position:new(self.row, -1)
end

---@class Selection
---@field start Position
---@field stop Position
local Selection = {}

---@param start Position
---@param stop Position
function Selection:new(start, stop)
  local object = { start = start, stop = stop }

  setmetatable(object, self)
  self.__index = self
  return object
end

---@return Selection
function Selection.visual()
  local visual = Position.visual()
  local cursor = Position.cursor()

  if visual:is_before(cursor) then
    return Selection:new(visual, cursor)
  else
    return Selection:new(cursor, visual)
  end
end

local M = {
  Position = Position,
  Selection = Selection,
}

return M
