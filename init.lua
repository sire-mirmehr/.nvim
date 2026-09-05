vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.expand("~/go/bin")

require("config.lazy")
vim.opt.termguicolors = true
require("config.keymaps")
require("config.options")
