local M = {}

M.editor_version = function()
  local version = vim.version()

  return string.format("Neovim/%d.%d.%d", version.major, version.minor, version.patch)
end

return M
