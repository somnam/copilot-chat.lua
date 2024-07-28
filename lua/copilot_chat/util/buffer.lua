local ChatPosition = require("copilot_chat.enums").ChatPosition
local Position = require("copilot_chat.util.input").Position

local M = {}

---@param selection Selection
---@return table
function M.get_text(selection)
  local start = selection.start
  if start:at_max_col() then
    start = start:move_to_next_line()
  end

  local stop = selection.stop
  if stop:at_max_col() then
    stop = stop:move_to_last_column()
  end

  local bufnr = vim.api.nvim_get_current_buf()

  local ok, result =
    pcall(vim.api.nvim_buf_get_text, bufnr, start.row, start.col, stop.row, stop.col, {})

  return ok and result or {}
end

---@param text string
function M.append_text(text)
  local content = vim.split(text, "\n")
  if #content == 0 then
    return
  end

  local buffer_end = Position.buffer_end()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_text(
    bufnr,
    buffer_end.row,
    buffer_end.col,
    buffer_end.row,
    buffer_end.col,
    content
  )
end

---@param start integer
---@param stop integer
---@return table
function M.get_lines(start, stop)
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_lines(bufnr, start, stop, false)
end

---@return table
function M.all_lines()
  return M.get_lines(0, -1)
end

---@param start integer
---@param stop integer
---@param lines table
function M.set_lines(start, stop, lines)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, start, stop, false, lines)
end

---@param lines table
function M.overwrite(lines)
  M.set_lines(0, -1, lines)
end

function M.set_name(name)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(bufnr, name)
end

---@return string
function M.filetype()
  return vim.bo.filetype or ""
end

---@param position ChatPosition
---@param filetype string
function M.create_buffer(position, filetype)
  if position == ChatPosition.tab then
    vim.cmd.tabnew()
  elseif position == ChatPosition.horizontal then
    vim.cmd.new()
  else
    vim.cmd.vnew()
  end

  vim.o.ft = filetype
end

---@param position ChatPosition
function M.create_markdown_buffer(position)
  M.create_buffer(position, "markdown")

  vim.api.nvim_set_option_value("wrap", true, { scope = "local" })
  vim.api.nvim_set_option_value("linebreak", true, { scope = "local" })
end

---@param name string
---@return any
function M.get_var(name)
  local bufnr = vim.api.nvim_get_current_buf()
  local exists, value = pcall(vim.api.nvim_buf_get_var, bufnr, name)
  return exists and value or nil
end

---@param name string
---@param value any
function M.set_var(name, value)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_var(bufnr, name, value)
end

---@param name string
---@return boolean
function M.has_var(name)
  return M.get_var(name) ~= nil
end

function M.move_to_end()
  local buffer_end = Position.buffer_end()
  vim.api.nvim_win_set_cursor(
    vim.api.nvim_get_current_win(),
    { buffer_end.row + 1, buffer_end.col }
  )
end

return M
