vim.opt.rtp:append(".")
vim.opt.rtp:append("./deps/plenary.nvim/")
vim.cmd.runtime { "plugin/plenary.vim", bang = true }

vim.o.swapfile = false
vim.bo.swapfile = false
