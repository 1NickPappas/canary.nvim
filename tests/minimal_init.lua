vim.opt.runtimepath = vim.opt.runtimepath + "."

local plenary_path = os.getenv("PLENARY_PATH")
  or vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim")

if vim.fn.isdirectory(plenary_path) == 0 then
  plenary_path = vim.fn.expand("~/.local/share/nvim/site/pack/vendor/start/plenary.nvim")
end

vim.opt.runtimepath:append(plenary_path)

vim.cmd("runtime plugin/plenary.vim")

vim.o.swapfile = false
vim.bo.swapfile = false
