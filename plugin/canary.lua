if vim.g.loaded_canary then
  return
end
vim.g.loaded_canary = true

vim.api.nvim_create_user_command("CanaryCheck", function()
  require("canary").check()
end, { desc = "Check dependency versions" })

vim.api.nvim_create_user_command("CanaryShow", function()
  require("canary").show()
end, { desc = "Show version hints" })

vim.api.nvim_create_user_command("CanaryHide", function()
  require("canary").hide()
end, { desc = "Hide version hints" })

vim.api.nvim_create_user_command("CanaryToggle", function()
  require("canary").toggle()
end, { desc = "Toggle version hints" })

vim.api.nvim_create_user_command("CanaryRefresh", function()
  require("canary").refresh()
end, { desc = "Force refresh (bypass cache)" })
