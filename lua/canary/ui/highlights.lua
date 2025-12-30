local M = {}

local function set_default_highlights()
  local hl = vim.api.nvim_set_hl

  hl(0, "CanaryUpToDate", { link = "DiagnosticHint", default = true })
  hl(0, "CanaryPatch", { link = "DiagnosticInfo", default = true })
  hl(0, "CanaryMinor", { link = "DiagnosticWarn", default = true })
  hl(0, "CanaryMajor", { link = "DiagnosticError", default = true })
  hl(0, "CanaryInvalid", { link = "DiagnosticError", default = true })
  hl(0, "CanaryLoading", { link = "Comment", default = true })
end

function M.setup()
  local config = require("canary.config").get()

  set_default_highlights()

  if config.highlights then
    for name, opts in pairs(config.highlights) do
      vim.api.nvim_set_hl(0, name, opts)
    end
  end

  if config.on_highlights then
    config.on_highlights({
      CanaryUpToDate = true,
      CanaryPatch = true,
      CanaryMinor = true,
      CanaryMajor = true,
      CanaryInvalid = true,
      CanaryLoading = true,
    }, {})
  end

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      set_default_highlights()
      if config.on_highlights then
        config.on_highlights({}, {})
      end
    end,
    group = vim.api.nvim_create_augroup("CanaryHighlights", { clear = true }),
    nested = true,
  })
end

return M
