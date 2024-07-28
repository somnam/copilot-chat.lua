if _G.YourPluginNameLoaded then
  return
end

if not pcall(require, "plenary") then
  error("[copilot_chat] Dependency 'plenary' is not installed.")
end

_G.YourPluginNameLoaded = true

require("copilot_chat").setup()
