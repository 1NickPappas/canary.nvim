local M = {}

function M.setup(opts)
  require("canary.config").setup(opts)
  require("canary.ui.highlights").setup()

  local config = require("canary.config").get()

  if config.autostart then
    local parsers = require("canary.parsers")
    local patterns = parsers.supported_files()

    vim.api.nvim_create_autocmd("BufReadPost", {
      pattern = patterns,
      callback = function(args)
        vim.defer_fn(function()
          M.check({ bufnr = args.buf })
        end, 100)
      end,
      group = vim.api.nvim_create_augroup("Canary", { clear = true }),
    })
  end

  M._setup_keymaps(config)
end

function M._setup_keymaps(config)
  local keymaps = config.keymaps
  if not keymaps then
    return
  end

  if keymaps.show then
    vim.keymap.set("n", keymaps.show, function()
      M.show()
    end, { desc = "Canary: Show hints" })
  end

  if keymaps.hide then
    vim.keymap.set("n", keymaps.hide, function()
      M.hide()
    end, { desc = "Canary: Hide hints" })
  end

  if keymaps.toggle then
    vim.keymap.set("n", keymaps.toggle, function()
      M.toggle()
    end, { desc = "Canary: Toggle hints" })
  end

  if keymaps.check then
    vim.keymap.set("n", keymaps.check, function()
      M.check()
    end, { desc = "Canary: Check versions" })
  end

  if keymaps.details then
    vim.keymap.set("n", keymaps.details, function()
      M.show_details()
    end, { desc = "Canary: Show details", buffer = false })
  end

  if keymaps.filter then
    vim.keymap.set("n", keymaps.filter, function()
      M.toggle_filter()
    end, { desc = "Canary: Toggle filter (hide up-to-date)" })
  end

  if keymaps.update then
    vim.keymap.set("n", keymaps.update, function()
      M.update_all()
    end, { desc = "Canary: Update all dependencies" })
  end

  if keymaps.update_line then
    vim.keymap.set("n", keymaps.update_line, function()
      M.update_line()
    end, { desc = "Canary: Update dependency at cursor" })
  end
end

function M.check(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  require("canary.core").check_buffer(bufnr, { force = opts.force })
end

function M.show()
  local bufnr = vim.api.nvim_get_current_buf()
  require("canary.ui.virtual_text").show(bufnr)
end

function M.hide()
  local bufnr = vim.api.nvim_get_current_buf()
  require("canary.ui.virtual_text").clear(bufnr)
end

function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()
  require("canary.ui.virtual_text").toggle(bufnr)
end

function M.refresh()
  M.check({ force = true })
end

function M.show_details()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.fn.line(".") - 1
  require("canary.ui.float").show_line_details(bufnr, line)
end

function M.toggle_filter()
  local bufnr = vim.api.nvim_get_current_buf()
  require("canary.core").toggle_filter(bufnr)
end

function M.update_all()
  local bufnr = vim.api.nvim_get_current_buf()
  require("canary.update").update_all(bufnr)
end

function M.update_line()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.fn.line(".") - 1
  require("canary.update").update_line(bufnr, line)
end

return M
