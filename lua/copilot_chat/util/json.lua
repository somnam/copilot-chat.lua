local M = {}

---@param content string
---@return table?
---@return string?
function M.decode(content)
  local ok, result = pcall(vim.json.decode, content, {
    luanil = {
      object = true,
      array = true,
    },
  })

  if not ok then
    return nil, result
  end

  return result, nil
end

---@param content table
---@return string?
---@return string?
function M.encode(content)
  local ok, result = pcall(vim.json.encode, content)

  if not ok then
    return nil, result
  end

  return result, nil
end

return M
