-- Rerun tests only if their modification time changed.
cache = true
codes = true

-- Options
max_line_length = 100

ignore = {
  "121", -- setting read-only global variable 'vim'
  "122", -- setting read-only field of global variable 'vim'
  "212", -- unused argument 'self'
}

files["lua/copilot_chat/copilot/instructions.lua"] = { ignore = { "631" } }

-- Global objects defined by the nvim code
read_globals = {
  "vim",
  "describe",
  "it",
}
