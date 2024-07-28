local M = {}

M.diff = function()
  if vim.fn.executable("git") == 1 then
    local output = vim.fn.system({ "git", "diff", "--staged" })
    if not output:match("^diff") then
      error("Git diff error: " .. output)
    end
    return output
  end
end

return M
