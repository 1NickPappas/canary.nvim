local M = {}

local sources = {
  npm = require("canary.sources.npm"),
  cargo = require("canary.sources.cargo"),
  pypi = require("canary.sources.pypi"),
  go = require("canary.sources.goproxy"),
  composer = require("canary.sources.packagist"),
  rubygems = require("canary.sources.rubygems"),
}

function M.get(filetype)
  return sources[filetype]
end

return M
