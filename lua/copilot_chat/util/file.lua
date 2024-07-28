local json = require("copilot_chat.util.json")

local M = {}

---@param file string
---@return boolean
function M.file_exists(file)
  return vim.loop.fs_stat(file) ~= nil
end

---@param path string
---@return boolean
function M.dir_exists(path)
  return vim.fn.isdirectory(path) > 0
end

---@param file string
---@return string?
function M.read_file(file)
  if not M.file_exists(file) then
    return
  end

  local fd = assert(io.open(file, "r"))
  local content = fd:read("*a")
  fd:close()
  return content
end

---@param file string
---@return table?
---@return string?
function M.read_json_file(file)
  local content = M.read_file(file)
  if not content then
    return
  end

  return json.decode(content)
end

---@param file string
---@param content table
---@return string?
function M.write_json_file(file, content)
  local result, err = json.encode(content)
  if not result then
    error(string.format("Could not write json file %s due to: %s", file, err))
  end

  local fd = assert(io.open(file, "w+"))
  fd:write(result)
  fd:close()
end

return M
