local M = {}

M.defaults = {
  autostart = true,
  hide_up_to_date = false,

  sources = {
    npm = { enabled = true },
    cargo = { enabled = true },
  },

  icon_style = "auto",

  icons = {
    up_to_date = { nerd = "", unicode = "✓", ascii = "ok" },
    outdated = { nerd = "", unicode = "↑", ascii = "^" },
    major = { nerd = "", unicode = "⚠", ascii = "!" },
    invalid = { nerd = "", unicode = "✗", ascii = "x" },
    loading = { nerd = "", unicode = "…", ascii = "..." },
  },

  display_format = "full",

  keymaps = {
    show = "<leader>cs",
    hide = "<leader>ch",
    toggle = "<leader>ct",
    check = "<leader>cc",
    details = "K",
    filter = "<leader>cf",
    update = "<leader>cu",
    next_outdated = "]d",
    prev_outdated = "[d",
  },

  cache = {
    enabled = true,
    ttl = 3600,
    path = nil,
  },

  http = {
    timeout = 10000,
    user_agent = "canary.nvim",
  },

  highlights = {},
  on_highlights = nil,
}

M._config = nil

function M.setup(opts)
  M._config = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

function M.get()
  return M._config or M.defaults
end

function M.get_icon_style()
  local config = M.get()
  local style = config.icon_style

  if style == "auto" then
    if vim.env.NERD_FONT or vim.env.TERM_PROGRAM == "iTerm.app" or vim.env.KITTY_WINDOW_ID then
      return "nerd"
    end
    return "unicode"
  end

  return style
end

return M
