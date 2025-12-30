local M = {}

local sources = {
  npm = require("canary.sources.npm"),
  cargo = require("canary.sources.cargo"),
}

function M.get(filetype)
  return sources[filetype]
end

return M
