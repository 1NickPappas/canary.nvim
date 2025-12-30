local M = {}

M.icons = {
  up_to_date = { nerd = "", unicode = "✓", ascii = "ok" },
  outdated = { nerd = "", unicode = "↑", ascii = "^" },
  major = { nerd = "", unicode = "⚠", ascii = "!" },
  invalid = { nerd = "", unicode = "✗", ascii = "x" },
  loading = { nerd = "", unicode = "…", ascii = "..." },
}

function M.get(name)
  local config = require("canary.config")
  local icon = M.icons[name]

  if not icon then
    return name
  end

  local style = config.get_icon_style()
  return icon[style] or icon.unicode
end

return M
