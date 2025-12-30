-- Minimal init for local testing
-- Run: nvim -u test_local.lua

vim.opt.runtimepath:prepend(".")
vim.opt.termguicolors = true

-- Setup the plugin
require("canary").setup({
  autostart = true,
  icon_style = "unicode", -- or "nerd" if you have nerd fonts
})

-- Open a test file
vim.cmd("edit tests/fixtures/package.json")
